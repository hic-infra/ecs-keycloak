# https://www.keycloak.org/server/containers

ARG KEYCLOAK_VERSION=22.0.5
FROM quay.io/keycloak/keycloak:$KEYCLOAK_VERSION as builder

ENV KC_DB=postgres
ENV KC_HOSTNAME=localhost

RUN /opt/keycloak/bin/kc.sh build

WORKDIR /opt/keycloak

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["start", "--optimized"]
