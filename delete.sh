#!/usr/bin/env bash

###############################################################################
# Script options
#
# Reference: http://redsymbol.net/articles/unofficial-bash-strict-mode/
###############################################################################
#set -e # exit on error
set -o pipefail # exit on pipe fails
set -u # fail on unset
#set -x # activate debugging from here down
#set +x # disable debugging from here down
# First set bash option to avoid
# unmatched patterns expand as result values
#shopt -s nullglob

###############################################################################
# Check the bash version - we use a modern version of the 'read' command
###############################################################################
if ((BASH_VERSINFO[0] < 4)); then
  echo "Sorry, you need at least bash-4.0 to run this script."
  exit 1
fi

###############################################################################
# It's all about location location location
###############################################################################
declare -r PROJ_DIR="$(git rev-parse --show-toplevel)"
declare -r SCRIPTS_DIR="${PROJ_DIR}/scripts"
declare -r CHART_DIR="${PROJ_DIR}/deployment/charts/jenkins-master"

###############################################################################
# A couple of custom color definitions along with logger and utility functions.
###############################################################################
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
# Helper function to delete everything on the cluster
###############################################################################
function cleanup-jenkins-master() {
    declare -r context="re"

    log "Deleting components for ${_Y}${project}${_W} with context ${_Y}${context}${_W}..."
    log "Deleting the helm chart ${_Y}${project}${_W}..."
    helm delete ${project} --purge

    for i in statefulsets configmap service routes pods pvc; do
        log "Deleting ${_Y}${i}${_W}..."
        oc -n ${namespace} delete ${i} -l "app.kubernetes.io/component=${project},app.kubernetes.io/context=${context}"
    done

    declare -r secret_resource_name="jenkins-master-image-secret"
    log "Deleting secret ${_Y}${secret_resource_name}${_W}..."
    oc -n ${namespace} delete secret ${secret_resource_name}

    # If we have the --all flag, then delete/cleanup all the helm deployments
    if [[ $# -ge 1 ]] && [[ ${1} == "--all" ]]; then
        for i in `helm list --namespace rpc-re | grep -v NAME | awk '{print $1}'`; do
            log "Deleting ${_Y}${i}${_W}...";
            helm delete --purge ${i};
        done
    else
        log "${_C}Hint${_W}: Use the ${_Y}--all${_W} flag to remove all helm charts from the ${_Y}${namespace}${_W} namespace."
    fi
}

cleanup-jenkins-master $@