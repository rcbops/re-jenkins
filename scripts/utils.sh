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
