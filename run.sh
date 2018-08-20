#!/usr/bin/env bash

###############################################################################
# Script options
#
# Reference: http://redsymbol.net/articles/unofficial-bash-strict-mode/
###############################################################################
set -e # exit on error
set -o pipefail # exit on pipe fails
set -u # fail on unset
#set -x # activate debugging from here down
#set +x # disable debugging from here down
# First set bash option to avoid
# unmatched patterns expand as result values
#shopt -s nullglob

###############################################################################
# A couple of custom color definitions along with logger and utility functions.
###############################################################################
SCRIPTS_DIR="$(git rev-parse --show-toplevel)/scripts"
for i in colors utils logger; do . ${SCRIPTS_DIR}/${i}.sh; done

###############################################################################
# Load the docker tag and version info
###############################################################################
declare -r versions_file="versions.sh"
if [[ -f ${versions_file} ]]; then
    source ${versions_file}
else
    die "Unable to read ${_Y}${versions_file}{$_W} file."
fi

# Check for registry login
grep -q $registry ~/.docker/config.json || die "Not logged into docker registry. For openshift registry try: docker login -u $(oc whoami) -p \"$(oc whoami -t)\" docker-registry-default.devapps.rsi.rackspace.net/rcbops/re-jenkins"

# Our build tag without version
build_tag="${registry}/${namespace}/${project}"

# Create a Jenkins work folder and place the logging.properties file there
mkdir -p work/.ssh
cp ~/.ssh/openstack_* work/.ssh/
#cp config/logging.properties work/

declare -r container_name="jenkins-master"

# Launch!
log "Starting docker image ${_Y}${build_tag}:${version}${_W} with container name ${_Y}${container_name}${_W}..."

docker run \
    --name ${container_name} \
    -d \
    -p 8080:8080 \
    -p 50000:50000 \
    --env JENKINS_ARGS="--prefix=/jenkins" \
    --env JENKINS_JAVA_OVERRIDES="-Dhudson.footerURL=http://www.rackspace.com -Djava.awt.headless=true -Djava.util.logging.config.file=/var/lib/jenkins/logging.properties" \
    -v `pwd`/work:/var/jenkins_home \
    ${build_tag}:${version}
