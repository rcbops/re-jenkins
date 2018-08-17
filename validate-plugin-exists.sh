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

###############################################################################
# Make sure the plugins file exists and we can load it
###############################################################################
PLUGINS_DIR="$(git rev-parse --show-toplevel)/plugins"
declare -r plugin_file="${PLUGINS_DIR}/plugins.txt"
#declare -r plugin_file="plugins/plugins-test.txt"
if [[ -f ${plugin_file} ]]; then
    log "Using plugins file: ${_Y}${plugin_file}${_W}..."
else
    die "Plugin file ${_Y}${plugin_file}${_W} does not exist."
fi

JENKINS_UC="https://updates.jenkins.io"
REF_DIR=${REF:-tmp}
FAILED="$REF_DIR/failed-plugins.txt"
rm -Rf ${FAILED}

mkdir -p "$REF_DIR" || exit 1

while read spec || [ -n "$spec" ]; do
    plugin=(${spec//:/ });
    [[ ${plugin[0]} =~ ^# ]] && continue
    [[ ${plugin[0]} =~ ^\s*$ ]] && continue
    [[ -z ${plugin[1]} ]] && plugin[1]="latest"
    #log "Testing if plugin exists: ${_Y}${plugin[0]}:${plugin[1]}${_W}..."

    if [ -z "$JENKINS_UC_DOWNLOAD" ]; then
      JENKINS_UC_DOWNLOAD=$JENKINS_UC/download
    fi

    url="${JENKINS_UC_DOWNLOAD}/plugins/${plugin[0]}/${plugin[1]}/${plugin[0]}.hpi"
    #curl -sSL -f ${JENKINS_UC_DOWNLOAD}/plugins/${plugin[0]}/${plugin[1]}/${plugin[0]}.hpi -o $REF_DIR/${plugin[0]}.jpi
    wget --spider "$url" 2>/dev/null
    exit_code=$?

    if [[ ${exit_code} -ne 0 ]]; then
        log_warn "${EKS} Plugin not found: ${_Y}${plugin[0]}:${plugin[1]}${_W}"
        echo -e "Plugin not found: ${_Y}${plugin[0]}:${plugin[1]}${_W}. Tried url: ${_Y}${url}${_NC}" >> ${FAILED}
    else
        log "${CHK} Plugin exists: ${_Y}${plugin[0]}:${plugin[1]}${_W}"
    fi
done < ${plugin_file}

if [[ -f ${FAILED} ]]; then
    log_warn "One or more plugins were not available:"
    cat ${FAILED}
fi
