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
for i in colors utils logger; do . scripts/${i}.sh; done

# Ensure decrypted secrets are available.
CHART_DIR="$(git rev-parse --show-toplevel)/deployment/charts/jenkins-master"
[[ -f ${CHART_DIR}/secrets.yaml ]] || decrypt_secrets

NAMESPACE="rpc-re"
export TILLER_NAMESPACE="tesla-staging"
HELM_OPTS="--debug \
    --tiller-namespace ${TILLER_NAMESPACE} \
    --namespace ${NAMESPACE} \
    -f ${CHART_DIR}/values.yaml \
    -f ${CHART_DIR}/secrets.yaml"

# lint the charts
helm lint ${CHART_DIR}

# Helm dry run
helm install $HELM_OPTS --dry-run ${CHART_DIR}

# For Real this time.
helm install $HELM_OPTS ${CHART_DIR}
