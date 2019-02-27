#!/bin/bash
set -e
AMAH_HOME=/opt/amah-clickhouse
AMAH_CONF=${AMAH_HOME}/conf
AMAH_LIBS=${AMAH_HOME}/libs
CONF_FILE_NAME="clickhouse.properties"
AMAH_CONF_FILE=${AMAH_CONF}/${CONF_FILE_NAME}

if [ -z "$BD_CLICKHOUSE_SERVERS" ]; then
    echo "\$BD_CLICKHOUSE_SERVERS not set"
    exit 1
fi
if [ -z "$BD_CLICKHOUSE_USERS" ]; then
    echo "\$BD_CLICKHOUSE_USERS not set"
    exit 1
fi
if [ -z "$BD_CLICKHOUSE_PASSWORDS" ]; then
    echo "\$BD_CLICKHOUSE_PASSWORDS not set"
    exit 1
fi
function replacePrefix {
  sed -i "s#%BD_CLICKHOUSE_SERVERS%#${BD_CLICKHOUSE_SERVERS}#g" ${AMAH_CONF_FILE}
  sed -i "s#%BD_CLICKHOUSE_USERS%#${BD_CLICKHOUSE_USERS}#g" ${AMAH_CONF_FILE}
  sed -i "s#%BD_CLICKHOUSE_PASSWORDS%#${BD_CLICKHOUSE_PASSWORDS}#g" ${AMAH_CONF_FILE}
}

cp -f /opt/mntcephutils/conf/${CONF_FILE_NAME} ${AMAH_CONF}
replacePrefix
java -Xmx512m -cp "${AMAH_LIBS}/*" io.helium.amah.cli.CliMain ${AMAH_CONF_FILE}
