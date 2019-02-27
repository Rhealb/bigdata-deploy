#!/bin/bash
set -e
AMAH_HOME=/opt/amah-opentsdb
AMAH_CONF=${AMAH_HOME}/conf
AMAH_LIBS=${AMAH_HOME}/libs
CONF_FILE_NAME="opentsdb.properties"
AMAH_CONF_FILE=${AMAH_CONF}/${CONF_FILE_NAME}

if [ -z "$BD_OPENTSDB_SERVERS" ]; then
    echo "\$BD_OPENTSDB_SERVERS not set"
    exit 1
fi
function replacePrefix {
  sed -i "s/%BD_OPENTSDB_SERVERS%/${BD_OPENTSDB_SERVERS}/g" ${AMAH_CONF_FILE}
}
cp -f /opt/mntcephutils/conf/${CONF_FILE_NAME} ${AMAH_CONF}
replacePrefix
java -Xmx512m -cp "${AMAH_LIBS}/*" io.helium.amah.cli.CliMain ${AMAH_CONF_FILE}
