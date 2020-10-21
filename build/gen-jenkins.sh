#! /usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"

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

#jenkinsTemplateFolder="${SCRIPT_FOLDER}/../templates/jenkins"

#jenkinsTheme="$(jq -r '.jenkins.theme' "${instance}/target/config.json")"
#echo "/* GENERATED FILE - DO NOT EDIT */" > "${target}/${jenkinsTheme}.css.override"
#hbs -s -D "${instance}/target/config.json" "${jenkinsTemplateFolder}/${jenkinsTheme}.css.hbs" >> "${target}/${jenkinsTheme}.css.override"

displayName="$(jq -r '.project.displayName' "${instance}/target/config.json")"
cat <<EOF > "${target}/title.js"
document.title = "${displayName} - " + document.title;
EOF
