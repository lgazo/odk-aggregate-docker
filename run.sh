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

  echo "---- Modifying ODK Aggregate security.properties ----"

  echo "Updating security.server.hostname"
  sed -i -E "s|^(security.server.hostname=).*|\1$ODK_HOSTNAME|gm" security.properties

  echo "Updating security.server.superUserUsername"
  sed -i -E "s|^(security.server.superUserUsername=).*|\1$ODK_ADMIN_USERNAME|gm" security.properties

  echo "Updating security.server.realm.realmString"
  sed -i -E "s|^(security.server.realm.realmString=).*|\1$ODK_AUTH_REALM|gm" security.properties

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
