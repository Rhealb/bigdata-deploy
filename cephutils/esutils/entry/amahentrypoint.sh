#!/bin/bash
set -e
AMAH_HOME=/opt/amah-elasticsearch
AMAH_CONF=${AMAH_HOME}/conf
AMAH_LIBS=${AMAH_HOME}/libs
CONF_FILE_NAME="elasticsearch.properties"
AMAH_CONF_FILE=${AMAH_CONF}/${CONF_FILE_NAME}

function replacePrefix {
  sed -i "s/%BD_ESCLIENT_SERVER%/${BD_ESCLIENT_SERVER}/g" ${AMAH_CONF_FILE}
}
cp -f /opt/mntcephutils/conf/${CONF_FILE_NAME} ${AMAH_CONF}
replacePrefix
java -Xmx512m -cp "${AMAH_LIBS}/*" io.helium.amah.cli.CliMain ${AMAH_CONF_FILE}
