#!/bin/bash

############################################################################
# IMPORTANT NOTE: If you change the DNs in configuration of this file, you #
# should also change them in templates/opensearch.yml.j2                #
############################################################################

# This files creates (if not exist):
#  - Root certificate for OpenSearch
#  - Admin certificate for OpenSearch
#  - N node certificates for OpenSearch

set -euxo pipefail

readonly __DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OPENSEARCH_KEYS_PATH="${OPENSEARCH_KEYS_PATH:-${__DIR}/certs}"
readonly NODES_NUMBER="${NODES_NUMBER:-2}"
readonly CERT_DN="${CERT_DN:-/C=EU/ST=Any/L=All/O=Dis/CN=opensearch}"
readonly ADMIN_DN="${ADMIN_DN:-/C=EU/ST=Any/L=All/O=Dis/CN=admin}"

mkdir -p "$OPENSEARCH_KEYS_PATH"
cd "$OPENSEARCH_KEYS_PATH" || exit 1

if [ ! -f root-ca-key.pem ] || [ ! -f root-ca.pem ]; then
    echo "==> Generating root certificate for OpenSearch"
    openssl genrsa -out root-ca-key.pem 4096
    openssl req -new -x509 -sha256 -days 3650 -key root-ca-key.pem -out root-ca.pem -subj "${CERT_DN}"
else
    echo "==> Root certificate for OpenSearch exists ($OPENSEARCH_KEYS_PATH/root-ca*.pem)"
fi
echo

if [ ! -f admin-key.pem ] || [ ! -f admin.pem ]; then
    echo "==> Generating admin certificate for OpenSearch"
    openssl genrsa -out admin-key-temp.pem 4096
    openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
    openssl req -new -key admin-key.pem -out admin-temp.csr -subj "${ADMIN_DN}"
    openssl x509 -req -days 3650 -in admin-temp.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem
    rm admin-key-temp.pem
    rm admin-temp.csr
else
    echo "==> Admin certificate for OpenSearch exists ($OPENSEARCH_KEYS_PATH/admin*.pem)"
fi
echo

for i in $(seq 0 $(( NODES_NUMBER - 1 ))); do
    if [ ! -f "node-${i}-key.pem" ] || [ ! -f "node-${i}.pem" ]; then
        echo "==> Generating node ${i} certificate for OpenSearch"
        openssl genrsa -out "node-${i}-key-temp.pem" 4096
        openssl pkcs8 -inform PEM -outform PEM -in "node-${i}-key-temp.pem" -topk8 -nocrypt -v1 PBE-SHA1-3DES -out "node-${i}-key.pem"
        openssl req -new -key "node-${i}-key.pem" -out "node-${i}-temp.csr" -subj "${CERT_DN}"
        openssl x509 -req -days 3650 -in "node-${i}-temp.csr" -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out "node-${i}.pem"
        rm "node-${i}-key-temp.pem"
        rm "node-${i}-temp.csr"
    else
        echo "==> Node-${i} certificate for OpenSearch exists ($OPENSEARCH_KEYS_PATH/node-${i}*.pem)"
    fi
    echo
done

# Show expiration dates
echo ""
echo "Expiration dates for the certificates:"
echo -n "root: "
openssl x509 -enddate -noout -in "root-ca.pem"
echo -n "admin: "
openssl x509 -enddate -noout -in "admin.pem"
for i in $(seq 0 $(( NODES_NUMBER - 1 ))); do
    echo -n "node-${i}: "
    openssl x509 -enddate -noout -in "node-${i}.pem"
done
echo

# Show cert subjects
echo ""
echo "Certificate subjects, that should match the values in opensearch.yml"
echo -n "admin_dn: "
openssl x509 -subject -nameopt RFC2253 -noout -in "admin.pem"
echo -n "nodes_dn: "
openssl x509 -subject -nameopt RFC2253 -noout -in "node-0.pem"
echo
