FROM certbot/certbot:v0.19.0

RUN apk update; apk upgrade; apk add dcron
ADD certbot_renew.sh /etc/periodic/daily/

ENTRYPOINT []
CMD run-parts --test /etc/periodic/daily; crond -f
