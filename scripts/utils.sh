#!/usr/bin/env bash

###############################################################################
# What to do if we die
###############################################################################
die() {
  log_warn "$@"
  exit 1
}

###############################################################################
# Formatted date/time string
###############################################################################
get_logger_timestamp() {
  declare -r date_format='%Y-%m-%dT%T%z'
  echo -e "`date +${date_format}`"
}


###############################################################################
# Helm Docker
# Check if helm is available, if not, run it from docker.
###############################################################################
helm_docker(){
    if which helm > /dev/null
    then
      log_debug "Using local helm to execute ${@}"
      helm $@
    else
      log_debug "Using helm from docker to execute ${@}"
      [[ -n $WORKSPACE ]] || die "Workspace not defined, running outside Jenkins?"
      export HELM_HOME="${WORKSPACE}/.helm"
      sudo docker run \
          -v $WORKSPACE:$WORKSPACE \
          -w $WORKSPACE \
          -e HELM_HOME="${HELM_HOME}" \
          "lachlanevenson/k8s-helm" $@
    fi
}

###############################################################################
# Functions for handling secrets
###############################################################################
export KEY_ID="A08C1137033A80B12016F29B958EC98E276DF75E"
export ENC_SECRETS_FILE="secrets.yaml.gpg"
export CLEAR_SECRETS_FILE="secrets.yaml"
check_gpg_available(){
  gpg --version >/dev/null || die "gpg not available, please install"
  log_debug "Found gpg binary"
}

check_key_available(){
  gpg --list-secret-keys \
    |grep "${KEY_ID}" >/dev/null \
    ||die "Key $KEY_ID not found, please import from the corporate creds store."
  log_debug "Found required key"
}

decrypt_secrets(){
  check_gpg_available
  check_key_available
  pushd $(git rev-parse --show-toplevel)/deployment/charts/jenkins-master >/dev/null
    [[ -f ${ENC_SECRETS_FILE} ]] || die "encrypted secrets file (${ENC_SECRETS_FILE}) not found"
    [[ -f ${CLEAR_SECRETS_FILE} ]] && die "unencrypted secrets file (${CLEAR_SECRETS_FILE}) found, please remove before decrypting"
    gpg -d ${ENC_SECRETS_FILE} > ${CLEAR_SECRETS_FILE}
  popd >/dev/null
  log "${ENC_SECRETS_FILE} decrypted to ${CLEAR_SECRETS_FILE}"
}

encrypt_secrets(){
  check_gpg_available
  check_key_available
  pushd $(git rev-parse --show-toplevel)/deployment/charts/jenkins-master >/dev/null
    [[ -f ${CLEAR_SECRETS_FILE} ]] || die "unencrypted secrets file (${CLEAR_SECRETS_FILE}) not found"
    gpg -r "$KEY_ID" --batch --yes -e ${CLEAR_SECRETS_FILE}
  popd > /dev/null
  log "${CLEAR_SECRETS_FILE} encrypted to ${ENC_SECRETS_FILE}"
}
