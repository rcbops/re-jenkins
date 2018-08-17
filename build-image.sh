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

# Our build tag without version
build_tag="${registry}/${namespace}/${project}"

log "Building Jenkins image with tag: ${_Y}${build_tag}:${version}${_W}..."
docker build -t="${build_tag}:${version}" .

log "Adding latest tag: ${_Y}${build_tag}:latest${_W}..."
docker tag ${build_tag}:${version} ${build_tag}:latest
