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
grep $registry ~/.docker/config.json || die "Not logged into docker registry. For openshift registry try: docker login -u $(oc whoami) -p \"$(oc whoami -t)\" docker-registry-default.devapps.rsi.rackspace.net/rcbops/re-jenkins"

# Our build tag without version
build_tag="${registry}/${namespace}/${project}"

log "Publishing image with tag: ${_Y}${build_tag}:${version}${_W}..."
docker push "${build_tag}:${version}"

log "Publishing image with tag: ${_Y}${build_tag}:latest${_W}..."
docker push "${build_tag}:latest"
