#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

SCRIPT_FOLDER="$(dirname $(readlink -f "${0}"))"

instance="${1:-}"

if [ -z "${instance}" ]; then
  echo "ERROR: you must provide an 'instance' name argument"
  exit 1
fi

if [ ! -d "${instance}" ]; then
  echo "ERROR: no 'instance' at '${instance}'"
  exit 1
fi

target="${instance}/target/jenkins"
mkdir -p "${target}"

if [[ -f "${instance}/jenkins/plugins-list" ]]; then
  echo "# GENERATED FILE - DO NOT EDIT" > "${target}/plugins-list"
  cat "${instance}/jenkins/plugins-list" >> "${target}/plugins-list"
fi

echo "/* GENERATED FILE - DO NOT EDIT */" > "${target}/quicksilver.css.override"
hbs -s -D "${instance}/config.json" "${SCRIPT_FOLDER}/../templates/jenkins/quicksilver.css.hbs" >> "${target}/quicksilver.css.override"

${SCRIPT_FOLDER}/gen-yaml.sh "${instance}/jenkins/configuration.yml" "${SCRIPT_FOLDER}/../templates/jenkins/configuration.yml.hbs" "${instance}/target/config.json" > "${target}/configuration.yml"