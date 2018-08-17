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
REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPTS_DIR="${REPO_ROOT}/scripts"
for i in colors utils logger; do . ${SCRIPTS_DIR}/${i}.sh; done

for chart in ${REPO_ROOT}/deployment/charts/*
do
    helm_docker lint $chart
done
