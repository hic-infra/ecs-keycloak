# https://www.keycloak.org/server/containers
FROM quay.io/keycloak/keycloak:26.3.3

ENV KC_DB=postgres
ENV KC_HOSTNAME=localhost
ENV KC_HEALTH_ENABLED=true

RUN /opt/keycloak/bin/kc.sh build

WORKDIR /opt/keycloak

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["start", "--optimized"]
