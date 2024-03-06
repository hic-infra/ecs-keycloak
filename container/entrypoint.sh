#!/bin/sh
set -eu

# Self-signed certificate. This is fine for AWS LB <-> ECS communication.
# If you're connecting directly then you'll need to generate a production certificate.
cd /opt/keycloak
keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=$KC_HOSTNAME" -alias server -ext "SAN:c=DNS:$KC_HOSTNAME,DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore

# If KC_DB has been overridden then need to rebuild the config
if [ "$KC_DB" != postgres ]; then
  echo "KC_DB has been overridden to $KC_DB, rebuilding"
  /opt/keycloak/bin/kc.sh build
fi

exec /opt/keycloak/bin/kc.sh "$@"
