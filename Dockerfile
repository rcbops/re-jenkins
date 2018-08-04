#FROM jenkins:2.60.3-alpine
FROM jenkinsci/blueocean

LABEL vendor="Rackspace Inc." \
      vendor.url="http://www.rackspace.com/" \
      version="0.0.1" \
      description="This is a Jenkins docker image for the release engineering team."

# Install a few tools
USER root
RUN apk add --no-cache vim

USER jenkins
COPY groovy/*.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY plugins/plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

EXPOSE 8080/tcp
