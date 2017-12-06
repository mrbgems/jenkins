require 'psych'
require 'rexml/document'
require 'uri'

BASE_GEM = 'master-mruby-marshal'
MRUBY_RELEASES = %w[1.3.0 1.2.0 master]

def base_url; ENV['MGEM_LIST_UPDATER_BASE'] end

def crumb
  `curl -s '#{base_url}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'`
end

downloader_base_xml_body = `curl '#{base_url}/job/release-downloader-master/config.xml'`
MRUBY_RELEASES.each do |rel|
  next if rel == 'master'
  p "Configuring: release-downloader-#{rel}"

  config_xml = REXML::Document.new(downloader_base_xml_body)
  REXML::XPath.each(config_xml, '//hudson.tasks.Shell/command') do |nd|
    nd.text = "wget -O mruby-#{rel}.tar.gz 'https://github.com/mruby/mruby/archive/#{rel}.tar.gz'"
  end
  REXML::XPath.each(config_xml, '//upstreamProjects') do |nd|
    nd.text = ''
  end

  res = ''
  config_xml.write(res)
  p res
  File.open('./tmp.xml', 'w'){|f| config_xml.write(f) }

  config_url = URI("#{base_url}/job/release-downloader-#{rel}/config.xml")
  if `curl -s -o /dev/null -w '%{http_code}' '#{config_url}'`.strip == '404'
    raise "cannot create job: #{rel}" unless
      system("curl -X POST -H #{crumb} -d 'name=release-downloader-#{rel}&mode=copy&from=release-downloader-master' '#{base_url}/createItem'")
  end
  raise "cannot update job: #{rel}" unless
    system("curl -X POST --data-binary @- -H #{crumb} -H 'Content-Type: text/xml' '#{config_url}' < ./tmp.xml")
end

gem_names = []
p "#{base_url}/job/#{BASE_GEM}/config.xml"
base_xml_body = `curl '#{base_url}/job/#{BASE_GEM}/config.xml'`
p base_xml_body

# 各mgemをmruby-marshalベースで設定
Dir.glob("#{ENV['WORKSPACE']}/*.gem") do |file|
  info = Psych.load_file(file)
  name = info['name']
  gem_names << name
  p "Configuring: #{name}"

  MRUBY_RELEASES.each do |rel|
    config_xml = REXML::Document.new(base_xml_body)
    REXML::XPath.each(config_xml, '/project/description'){|nd| nd.text = info['description'] }
    REXML::XPath.each(config_xml, '//projectUrl'){|nd| nd.text = info['website'] }
    REXML::XPath.each(config_xml, '//hudson.plugins.git.UserRemoteConfig/url'){|nd| nd.text = info['repository'] }
    REXML::XPath.each(config_xml, '//jenkins.triggers.ReverseBuildTrigger/upstreamProjects'){|nd| nd.text = "release-downloader-#{rel}" }
    REXML::XPath.each(config_xml, '//hudson.tasks.Shell/command') do |nd|
      nd.text = <<EOS
cat <<EOF > "$WORKSPACE/mgem_build_config.rb"
{ gcc: 'host', clang: 'clang'}.each do |tool, name|
  MRuby::Build.new(name) do |conf|
    conf.toolchain tool
    enable_test if conf.respond_to? :enable_test
    enable_debug
    conf.cc.command = "sccache \#{conf.cc.command}"
    conf.cxx.command = "sccache \#{conf.cxx.command}"
    conf.linker.command = "sccache \#{conf.cxx.command}"
    conf.cxx.flags << '-std=c++11'
    [conf.cxx, conf.cc, conf.linker].each{|c| c.flags << '-fsanitize=address,leak,undefined' }
    gem core: 'mruby-print'
    gem "${WORKSPACE}"
  end
end
EOF

tar xf $WORKSPACE/../release-downloader-#{rel}/mruby-#{rel}.tar.gz
cd mruby-#{rel}
MRUBY_CONFIG="$WORKSPACE/mgem_build_config.rb" script -e -c "./minirake all test" /dev/null
EOS
    end
    File.open('./tmp.xml', 'w'){|f| config_xml.write(f) }

    config_url = URI("#{base_url}/job/#{rel}-#{name}/config.xml")
    if `curl -s -o /dev/null -w '%{http_code}' '#{config_url}'`.strip == '404'
      raise "cannot create job: #{rel}-#{name}" unless
        system("curl -X POST -H #{crumb} -d 'name=#{rel}-#{name}&mode=copy&from=#{BASE_GEM}' '#{base_url}/createItem'")
    end
    raise "cannot update job: #{rel}-#{name}" unless
      system("curl -X POST --data-binary @- -H #{crumb} -H 'Content-Type: text/xml' '#{config_url}' < ./tmp.xml")
  end
end
