FROM openshift/jenkins-2-centos7

LABEL vendor="Rackspace Inc." \
      vendor.url="http://www.rackspace.com/" \
      version="0.0.6" \
      description="This is a Jenkins docker image for the release engineering team."

ARG JENKINS_HOME=/var/lib/jenkins
ENV JENKINS_HOME $JENKINS_HOME

# Install a few tools
USER root
RUN yum install -y bash zsh vim curl wget jq file diffutils python3 gnupg gzip docker && \
  yum clean all

COPY plugins/plugins.txt ${JENKINS_HOME}/
RUN /usr/local/bin/install-plugins.sh ${JENKINS_HOME}/plugins.txt
COPY groovy/*.groovy /opt/openshift/configuration/init.groovy.d/
COPY config/* ${JENKINS_HOME}/ 
RUN chown -R 1001:0 /opt/openshift && \
    /usr/local/bin/fix-permissions /opt/openshift && \
    /usr/local/bin/fix-permissions /opt/openshift/configuration/init.groovy.d && \
    /usr/local/bin/fix-permissions ${JENKINS_HOME} && \
    /usr/local/bin/fix-permissions /var/log

USER 1001
