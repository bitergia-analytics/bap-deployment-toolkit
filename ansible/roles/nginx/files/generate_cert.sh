#!/bin/bash
#
# Copyright (C) 2021 Bitergia
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Authors:
#   Angel Jara <ajara@bitergia.com>
#
# Creates a TLS self-signed certificate for NGINX

set -o errexit
set -o nounset
set -o pipefail
# uncomment for debugging
# set -o xtrace

readonly __DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __FILE="${__DIR}/$(basename "${BASH_SOURCE[0]}")"
readonly __BASE="$(basename "${__FILE}")"
readonly BASE_SUBJECT="/C=ES/ST=Madrid/L=Madrid/O=Bitergia/CN="

#######################################
# Usage message
# Globals:
#   __BASE
# Arguments:
#   None
# Returns:
#   Usage
#######################################
function usage {
    cat << USAGE >&2
usage: ${__BASE} common_name

positional arguments:
  common_name          FQDN of the host that the cert will with
USAGE
  exit 1
}

#######################################
# Arguments parser
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
function args_parser {
  # Option -h
  while getopts ":h" opt; do
    case "${opt}" in
      h)
        usage
        ;;
      :)
        echo "Invalid Option: -${OPTARG} requires an argument" 1>&2
        usage
        ;;
      *)
        echo "Invalid Option: -${OPTARG}" 1>&2
        usage
        ;;
    esac
  done
  shift "$((OPTIND-1))"

  # Exactly 1 arguments (common_name)
  [[ ${#} -ne 1 ]] && usage

  export COMMON_NAME=${1}
}

#######################################
# Generate certificate
# Globals:
#   BASE_SUBJECT
# Arguments:
#   common_name
# Returns:
#   None
#######################################
function generate_cert {
  local -r common_name="${1}"
  local -r cert_subject="${BASE_SUBJECT}${common_name}"

  if [ ! -f cert.key ] || [ ! -f cert.crt ]; then
      echo "==> Generating certificate for NGINX"
      openssl req -x509 -nodes -days 1095 -newkey rsa:4096 \
              -keyout cert.key -out cert.crt -subj "${cert_subject}"
  else
      echo "==> Certificate already exists (cert.crt)"
  fi

  # Show expiration date
  echo ""
  echo -n "Expiration date:"
  openssl x509 -enddate -noout -in cert.crt

  # Show cert subject
  echo -n "Certificate subject:"
  openssl x509 -subject -nameopt RFC2253 -noout -in cert.crt
  echo
}

function main {
  args_parser "$@"
  generate_cert "${COMMON_NAME}"
}

main "$@"
