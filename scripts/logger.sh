#!/usr/bin/env bash

###############################################################################
# Logger definitions
###############################################################################
debug_enabled=1

function log() {
  declare -r date_format='%Y-%m-%dT%T%z'
  #echo -e "${_W}[${_N}${_Y}`date +${date_format}`${_N}${_W}][${_N}${_GREEN}INFO${_N}${_W}]${_N} ${_W}$@${_N}"
  printf "${_W}[${_N}${_Y}`date +${date_format}`${_N}${_W}][${_N}${_GREEN}INFO${_N}${_W}]${_N} ${_W}$@${_N}\n"
}

function log_warn() {
  declare -r date_format='%Y-%m-%dT%T%z'
  #echo -e "${_W}[${_N}${_Y}`date +${date_format}`${_N}${_W}][${_N}${_RED}WARN${_N}${_W}]${_N} ${_W}$@${_N}"
  printf "${_W}[${_N}${_Y}`date +${date_format}`${_N}${_W}][${_N}${_RED}WARN${_N}${_W}]${_N} ${_W}$@${_N}\n"
}

function log_debug() {
  declare -r date_format='%Y-%m-%dT%T%z'
  if [ ${debug_enabled} -ne 0 ]; then
    echo -e "${_W}[${_N}${_Y}`date +${date_format}`${_N}${_W}][${_N}${_BLUE}DEBUG${_N}${_W}]${_N} ${_W}$@${_N}"
  fi
}

# Export to allow other programs to access it
#export -f log
#export -f log_warn
#export -f log_debug
