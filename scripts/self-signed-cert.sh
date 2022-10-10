#!/bin/sh
# https://medium.com/@chamilad/adding-a-self-signed-ssl-certificate-to-aws-acm-88a123a04301

set -eu

OWNER=/L=HIC/O=HIC-infra
CN=localhost

PREFIX=aws-self-signed

if [ ! -f ${PREFIX}-key.pem ]; then
  echo "Generating private key..."
  openssl genrsa 2048 > "${PREFIX}-private.key"
fi

openssl req -new -x509 \
  -subj "${OWNER}/CN=${CN}" \
  -nodes \
  -sha1 \
  -days 365 \
  -extensions v3_ca \
  -addext "subjectAltName = DNS:localhost" \
  -key "${PREFIX}-private.key" \
  -out "${PREFIX}-public.crt"

echo "Run 'aws acm import-certificate --certificate fileb://${PREFIX}-public.crt --private-key fileb://${PREFIX}-private.key'"
