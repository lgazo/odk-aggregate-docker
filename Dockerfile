FROM tomcat:6-jre7
MAINTAINER OpenLMIS

RUN apt-get update && apt-get install default-jdk -y --no-install-recommends
# jdk is needed for exploding and reassembling jars and wars

RUN mkdir -p /opt/flyway/ \
  && cd /opt/flyway/ \
  && wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/4.0.3/flyway-commandline-4.0.3-linux-x64.tar.gz \
  && tar -xvzf flyway-commandline-4.0.3-linux-x64.tar.gz -C . --strip-components=1 \
  && rm flyway-commandline-4.0.3-linux-x64.tar.gz
# flyway is used to create odk's schema, ODK assumes a schema is already in place for it to create tables in

COPY ODKAggregate_1.4.12.war /ODKAggregate_1.4.12.war
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080

ENTRYPOINT ["/run.sh"]
