#!/bin/bash

set -eu

if [ ! -f /finished-setup ]; then

  echo "---- Updating ODK Aggregate configuration ----"
  mkdir -p /odktmp
  mkdir -p /odksettingstmp
  pushd /odktmp
  jar -xvf /ODKAggregate_1.4.12.war
  pushd /odksettingstmp
  jar -xvf /odktmp/WEB-INF/lib/ODKAggregate-settings.jar

  echo "---- Environment Variables ----"
  echo "ODK_PORT=$ODK_PORT"
  echo "ODK_PORT_SECURE=$ODK_PORT_SECURE"
  echo "ODK_HOSTNAME=$ODK_HOSTNAME"
  echo "ODK_ADMIN_USER=$ODK_ADMIN_USER"
  echo "ODK_ADMIN_USERNAME=$ODK_ADMIN_USERNAME"
  echo "ODK_AUTH_REALM=$ODK_AUTH_REALM"
  echo "ODK_CHANNEL_TYPE=$ODK_CHANNEL_TYPE"
  echo "DATABASE_URL=$DATABASE_URL"
  echo "POSTGRES_USER=$POSTGRES_USER"
  echo "CATALINA_HOME=$CATALINA_HOME"

  echo "---- Modifying ODK Aggregate security.properties ----"
  [[ ! -z $ODK_PORT ]] && echo "Updating security.server.port" && sed -i -E "s|^(security.server.port=)([0-9]+)|\1$ODK_PORT|gm" security.properties
  [[ ! -z $ODK_PORT_SECURE ]] && echo "Updating security.server.securePort" && sed -i -E "s|^(security.server.securePort=)([0-9]+)|\1$ODK_PORT_SECURE|gm" security.properties
  [[ ! -z $ODK_HOSTNAME ]] && echo "Updating security.server.hostname" && sed -i -E "s|^(security.server.hostname=)([A-Za-z\.0-9_]+)|\1$ODK_HOSTNAME|gm" security.properties
  [[ ! -z $ODK_ADMIN_USER ]] && echo "Updating security.server.superUser" && sed -i -E "s|^(security.server.superUser=).*|\1$ODK_ADMIN_USER|gm" security.properties
  [[ ! -z $ODK_ADMIN_USERNAME ]] && echo "Updating security.server.superUserUsername" && sed -i -E "s|^(security.server.superUserUsername=).*|\1$ODK_ADMIN_USERNAME|gm" security.properties
  [[ ! -z $ODK_AUTH_REALM ]] && echo "Updating security.server.realm.realmString" && sed -i -E "s|^(security.server.realm.realmString=).*|\1$ODK_AUTH_REALM|gm" security.properties
  [[ ! -z $ODK_CHANNEL_TYPE ]] && echo "Updating security.server.channelType" && sed -i -E "s|^(security.server.channelType=).*|\1$ODK_CHANNEL_TYPE|gm" security.properties
  cp security.properties ~/

  echo "---- Modifying ODK Aggregate jdbc.properties ----"
  sed -i -E "s|^(jdbc.url=).+(\?autoDeserialize=true)|\1$DATABASE_URL\2|gm" jdbc.properties
  sed -i -E "s|^(jdbc.schema=).*|\1odk|gm" jdbc.properties
  sed -i -E "s|^(jdbc.username=).*|\1$POSTGRES_USER|gm" jdbc.properties
  sed -i -E "s|^(jdbc.password=).*|\1$POSTGRES_PASSWORD|gm" jdbc.properties
  cp jdbc.properties ~/

  echo "---- Rebuilding ODKAggregate-settings.jar ----"
  jar cvf /ODKAggregate-settings.jar ./*
  popd

  mv -f /ODKAggregate-settings.jar /odktmp/WEB-INF/lib/ODKAggregate-settings.jar
  echo "---- Rebuilding ODKAggregate_1.4.12.war ----"
  jar cvf /ODKAggregate_1.4.12.war ./*
  popd

  echo "---- Deploying ODKAggregate_1.4.12.war to $CATALINA_HOME/webapps/ROOT.war ----"
  rm -rf $CATALINA_HOME/webapps
  [ -d /var/lib/tomcat6/webapps ] || mkdir -p $CATALINA_HOME/webapps
  cp /ODKAggregate_1.4.12.war $CATALINA_HOME/webapps/ROOT.war

  touch /finished-setup

  echo "---- Init DB schema ---"

# the following will create a schema called odk, so that ODK can run its sql
  /opt/flyway/flyway \
    -url=$DATABASE_URL \
    -schemas=odk \
    -user=$POSTGRES_USER \
    -password=$POSTGRES_PASSWORD \
    -table=odk_init_migration \
    migrate

  echo "---- Tomcat & ODK Aggregate Setup Complete ---"
fi

exec $CATALINA_HOME/bin/catalina.sh run "$@"
