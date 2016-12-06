FROM tomcat:6-jre7
MAINTAINER OpenLMIS

RUN apt-get update && apt-get install default-jdk -y --no-install-recommends

COPY ODKAggregate_1.4.12.war /ODKAggregate_1.4.12.war
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080

ENTRYPOINT ["/run.sh"]
