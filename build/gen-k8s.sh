#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# * Call gen-yaml.sh script

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"
templates="${SCRIPT_FOLDER}/../templates"

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

config="${instance}/target/config.json"

target="${instance}/target/k8s"
mkdir -p "${target}"

## Jenkins CaC config map filling
echo "# GENERATED FILE - DO NOT EDIT" >> "${target}/configmap-jenkins-config.yml"
hbs -s -D "${config}" -P "${templates}"'/k8s/partials/*.hbs' -P "${instance}"'/target/jenkins/*.yml' "${templates}/k8s/configmap-jenkins-config.yml.hbs" > "${target}/configmap-jenkins-config.yml"
