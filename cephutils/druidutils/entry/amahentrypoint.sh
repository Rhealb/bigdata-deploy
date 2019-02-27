#!/bin/bash
set -e
AMAH_HOME=/opt/amah-druid
AMAH_CONF=${AMAH_HOME}/conf
AMAH_LIBS=${AMAH_HOME}/libs
CONF_FILE_NAME="druid.properties"
AMAH_CONF_FILE=${AMAH_CONF}/${CONF_FILE_NAME}


function replacePrefix {
  sed -i "s/%BD_BROKER_SERVERS%/${BD_BROKER_SERVERS}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_COORDINATOR_SERVERS%/${BD_COORDINATOR_SERVERS}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_OVERLORD_SERVERS%/${BD_OVERLORD_SERVERS}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_MYSQL_SERVERS%/${BD_MYSQL_SERVERS}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_MYSQL_USERNAME%/${BD_MYSQL_USERNAME}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_MYSQL_PASSWD%/${BD_MYSQL_PASSWD}/g" ${AMAH_CONF_FILE}
}
cp -f /opt/mntcephutils/conf/amah/${CONF_FILE_NAME} ${AMAH_CONF}
replacePrefix
java -Xmx512m -cp "${AMAH_LIBS}/*" io.helium.amah.cli.CliMain ${AMAH_CONF_FILE}
