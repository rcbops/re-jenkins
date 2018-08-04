#!/usr/bin/env bash

# A couple of custom color definitions and logger functions.
[[ -f $HOME/colors.sh ]] && source $HOME/colors.sh
[[ -f $HOME/logger.sh ]] && source $HOME/logger.sh
[[ -f $HOME/utils.sh ]] && source $HOME/utils.sh

# Load the docker tag and version info
declare -r docker_tag_file="docker-tag.txt"
if [[ -f ${docker_tag_file} ]]; then
    source ${docker_tag_file}
else
    die "Unable to read ${_Y}${docker_tag_file}{$_W} file."
fi

# Create a Jenkins work folder and place the logging.properties file there
mkdir -p work
cp config/logging.properties work/

# Launch!
docker run \
    --name jenkins-master \
    -d \
    -p 8080:8080 \
    -p 50000:50000 \
    --env JAVA_OPTS=-Dhudson.footerURL=http://www.rackspace.com \
    --env JAVA_OPTS="-Djava.awt.headless=true -Djava.util.logging.config.file=/var/jenkins_home/logging.properties" \
    -v `pwd`/work:/var/jenkins_home \
    ${tag}
