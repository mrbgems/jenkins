require 'psych'
require 'rexml/document'
require 'uri'

BASE_GEM = 'mruby-marshal'

base_url = ENV['MGEM_LIST_UPDATER_BASE']
p "#{base_url}/job/#{BASE_GEM}/config.xml"
base_xml_body = `curl '#{base_url}/job/#{BASE_GEM}/config.xml'`

gem_names = []

def crumb
  `curl -s '#{ENV['MGEM_LIST_UPDATER_BASE']}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'`
end

# 各mgemをmruby-marshalベースで設定
Dir.glob("#{ENV['WORKSPACE']}/*.gem") do |file|
  info = Psych.load_file(file)
  name = info['name']
  gem_names << name

  config_xml = REXML::Document.new(base_xml_body)
  REXML::XPath.each(config_xml, '/project/description'){|nd| nd.text = info['description'] }
  REXML::XPath.each(config_xml, '//projectUrl'){|nd| nd.text = info['website'] }
  REXML::XPath.each(config_xml, '//hudson.plugins.git.UserRemoteConfig/url'){|nd| nd.text = info['repository'] }
  File.open('./tmp.xml', 'w'){|f| config_xml.write(f) }

  config_url = URI("#{base_url}/job/#{name}/config.xml")
  if `curl -s -o /dev/null -w '%{http_code}' '#{config_url}'`.strip == '404'
    raise "cannot create job: #{name}" unless
      system("curl -X POST -H #{crumb} -d 'name=#{name}&mode=copy&from=#{BASE_GEM}' '#{base_url}/createItem'")
  end
  raise "cannot update job: #{name}" unless
    system("curl -X POST -d @- -H #{crumb} -H 'Content-Type: text/xml' '#{config_url}' < ./tmp.xml")
end

# mruby-masterの事後ビルド設定
mruby_master_xml = REXML::Document.new(`curl '#{base_url}/job/mruby-master/config.xml'`)
REXML::XPath.each(mruby_master_xml, '//hudson.tasks.BuildTrigger/childProjects') do |nd|
  nd.text = gem_names.join(', ')
end
File.open('./tmp.xml', 'w'){|f| mruby_master_xml.write(f) }
p File.read('tmp.xml')
raise "cannot update mruby-master" unless
  system("curl -X POST -d @- -H #{crumb} -H 'Content-Type: text/xml' '#{base_url}/job/mruby-master/config.xml' < ./tmp.xml")
