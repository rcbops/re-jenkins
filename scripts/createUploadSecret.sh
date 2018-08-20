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
if [[ -f ${PROJ_DIR}/${versions_file} ]]; then
    source ${PROJ_DIR}/${versions_file}
else
    die "Unable to read ${_Y}${PROJ_DIR}/${versions_file}{$_W} file."
fi

###############################################################################
# Function to create a secret resource file
###############################################################################
generate_secret_resource() {
  cat <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: "docker-registry-deal"
  namespace: "rpc-re"
  labels:
    app.kubernetes.io/name: "jenkins-master"
    app.kubernetes.io/context: "re"
    app.kubernetes.io/chart: "jenkins-master"
    app.kubernetes.io/version: "0.0.6"
    app.kubernetes.io/component: "jenkins-master"
    app.kubernetes.io/part-of: "jenkins"
    app.kubernetes.io/managed-by: "helm"
type: kubernetes.io/dockercfg
data:
  .dockercfg: >-
    ${1}
YAML
}

# Ask for user input
read -e -p "Docker Username? " -i `whoami` username
read -e -p "Docker Password? " -i "123456" password
read -e -p "Docker e-mail? " -i "david.deal@rackspace.com" email

# Start encoding things per:
declare -r encoded_username_password=`echo -n "${username}:${password}" | base64`
#log_debug "Encoded username and password is:"
#log_debug "${encoded_username_password}"

declare -r json="{\"https://docker-registry-default.devapps.rsi.rackspace.net\":{\"username\":\"${username}\",\"password\":\"${password}\",\"email\":\"${email}\",\"auth\":\"${encoded_username_password}\"}}"
#log_debug "Raw JSON is:"
#log_debug "${json}"
declare -r encoded_json=`echo -n ${json} | base64`
#log_debug "Encoded JSON is:"
#log_debug "${encoded_json}"

declare -r MY_TMP_DIR=$(mktemp -d)
declare -r secrets_file="${MY_TMP_DIR}/secrets_resource.yaml"
echo "$(generate_secret_resource ${encoded_json})" > ${MY_TMP_DIR}/secrets_resource.yaml
# echo "YAML is:"
# cat ${secrets_file}

# Update the resource - apply the changes
oc apply -n ${namespace} -f ${secrets_file}

# Make sure we clean up any temp files
trap "rm -rf ${MY_TMP_DIR}" EXIT
