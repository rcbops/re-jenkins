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

# Ensure decrypted secrets are available.
CHART_DIR="$(git rev-parse --show-toplevel)/deployment/charts/jenkins-master"
[[ -f ${CHART_DIR}/secrets.yaml ]] || decrypt_secrets

NAMESPACE="${namespace}"
export TILLER_NAMESPACE="${namespace}"
HELM_OPTS="--debug \
    --tiller-namespace ${TILLER_NAMESPACE} \
    --name jenkins-master \
    --namespace ${NAMESPACE} \
    -f ${CHART_DIR}/values.yaml \
    -f ${CHART_DIR}/secrets.yaml"

# lint the charts
helm lint ${CHART_DIR} || die "helm lint failed.  See above errors."

# Helm dry run
helm install ${HELM_OPTS} --dry-run ${CHART_DIR} || die "helm dry-run failed.  See above errors."

# For Real this time.
helm install ${HELM_OPTS} ${CHART_DIR} || die "helm deploy failed. See above errors."
