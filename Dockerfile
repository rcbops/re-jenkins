FROM jenkins/jenkins:2.137-alpine

LABEL vendor="Rackspace Inc." \
      vendor.url="http://www.rackspace.com/" \
      version="0.0.1" \
      description="This is a Jenkins docker image for the release engineering team."

# Install a few tools
USER root
RUN apk --no-cache upgrade && \
  apk add --no-cache bash zsh vim curl wget bind-tools openssl git jq file diffutils nmap python3 gnupg tar gzip docker && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  python3 -m ensurepip --upgrade && \
  rm -r /usr/lib/python*/ensurepip && \
  if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
  if [ -f /root/.cache ]; then rm -r /root/.cache ; fi

USER jenkins
COPY plugins/plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt
COPY groovy/*.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY config/* /usr/share/jenkins/ref/

EXPOSE 8080/tcp
EXPOSE 50000/tcp
