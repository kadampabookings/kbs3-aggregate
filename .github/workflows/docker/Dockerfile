FROM azul/zulu-openjdk:19

RUN set -eux; \
        mkdir -p /opt/kbs/conf

COPY kbs-server-application-vertx-1.0.0-SNAPSHOT-fat.jar /opt/kbs
COPY kbs-backoffice-application-gwt-1.0.0-SNAPSHOT.war /opt/kbs
COPY kbs-frontoffice-application-gwt-1.0.0-SNAPSHOT.war /opt/kbs
COPY public-variables.properties secret-variables.properties override@webfx.stack.http.options.json override@webfx.stack.http.routes.json override@modality.base.server.datasource.properties /opt/kbs/conf

WORKDIR /opt/kbs

EXPOSE 80

CMD ["java", "-jar", "kbs-server-application-vertx-1.0.0-SNAPSHOT-fat.jar"]