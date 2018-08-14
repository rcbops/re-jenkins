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
# A couple of custom color definitions and logger functions.
###############################################################################
if [[ -f scripts/colors.sh ]]; then
    source scripts/colors.sh
else
    echo "Unable to read scripts/colors.sh."
    exit 1
fi
if [[ -f scripts/logger.sh ]]; then
    source scripts/logger.sh
else
    echo "Unable to read scripts/logger.sh."
    exit 1
fi
if [[ -f scripts/utils.sh ]]; then
    source scripts/utils.sh
else
    echo "Unable to read scripts/utils.sh."
    exit 1
fi

###############################################################################
# Load the docker tag and version info
###############################################################################
declare -r docker_tag_file="versions.sh"
if [[ -f ${docker_tag_file} ]]; then
    source ${docker_tag_file}
else
    die "Unable to read ${_Y}${docker_tag_file}{$_W} file."
fi

log "Publishing image with tag: ${_Y}${tag}${_W}..."
docker push "${owner}/${project}:${version}"

log "Publishing image with tag: ${_Y}latest${_W}..."
docker push "${owner}/${project}:latest"
