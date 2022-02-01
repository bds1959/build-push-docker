FROM alpine:latest

RUN  apk add docker

COPY docker-run.sh /docker-run.sh

RUN chmod +x /docker-run.sh

ENTRYPOINT ["/docker-run.sh"]
