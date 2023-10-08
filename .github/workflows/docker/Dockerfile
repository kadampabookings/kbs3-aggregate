FROM azul/zulu-openjdk:19

RUN set -eux; \
        mkdir -p /opt/kbsx/conf

COPY kbs-server-application-vertx-1.0.0-SNAPSHOT-fat.jar /opt/kbsx
COPY kbsx-backoffice-application-gwt-1.0.0-SNAPSHOT.war /opt/kbsx
COPY kbsx-frontoffice-application-gwt-1.0.0-SNAPSHOT.war /opt/kbsx
COPY public-variables.properties secret-variables.properties override@webfx.stack.http.options.json override@modality.base.server.datasource.properties /opt/kbsx/conf

WORKDIR /opt/kbsx

EXPOSE 80

CMD ["java", "-jar", "kbs-server-application-vertx-1.0.0-SNAPSHOT-fat.jar"]