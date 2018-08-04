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

log "Publishing image with tag: ${_Y}${tag}${_W}..."
docker push "${tag}"
