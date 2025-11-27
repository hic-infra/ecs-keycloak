# https://www.keycloak.org/server/containers
FROM maven:3.9-eclipse-temurin-21-alpine AS otp-build

COPY keycloak-2fa-email-authenticator/ /otp-email/
RUN cd /otp-email && \
    mvn clean package

FROM quay.io/keycloak/keycloak:26.3.2 AS target

ENV KC_DB=postgres
ENV KC_HOSTNAME=localhost
ENV KC_HEALTH_ENABLED=true

COPY --from=otp-build /otp-email/target/keycloak-2fa-email-authenticator*.jar /opt/keycloak/providers/
RUN /opt/keycloak/bin/kc.sh build

WORKDIR /opt/keycloak

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["start", "--optimized"]
