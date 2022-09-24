#!/usr/bin/env bash

# shellcheck disable=SC2046
# shellcheck disable=SC2164
SCRIPT_PATH="$(cd $(dirname "$0") > /dev/null 2>&1; pwd -P)"

if test -f "${SCRIPT_PATH}"/red_nebula_rsa; then
  echo "[Warning] Keys seem to already exist.  Skipping key generation"
  exit
fi

if ! ssh-keygen -b 4096 -t rsa -f "${SCRIPT_PATH}"/red_nebula_rsa -q -N ""; then
  echo "[Error] There was an error generating the SSH key for Terraform"
  exit
fi