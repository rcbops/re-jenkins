FROM jenkins/jenkins:2.138-alpine

LABEL vendor="Rackspace Inc." \
      vendor.url="http://www.rackspace.com/" \
      version="0.0.4" \
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

# OSE checks to make sure an image isnt running as root (0), but the random uid it generates is added to the root (0)
# group.  So we give the group control of things it needs to be able to access and write to.
# g=u => recursively give group same permissions as user
USER root
COPY scripts/entrypoint.sh /
RUN chmod a+x /entrypoint.sh && \
 chgrp -R root /usr/share/jenkins /var/jenkins_home && \
 chmod -R ug+rwx /usr/share/jenkins /var/jenkins_home && \
 ls -la /usr/share/jenkins /var/jenkins_home
USER jenkins

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080/tcp
EXPOSE 50000/tcp
