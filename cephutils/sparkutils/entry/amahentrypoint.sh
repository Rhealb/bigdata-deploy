#!/bin/bash
set -e
AMAH_HOME=/opt/amah-spark
AMAH_CONF=${AMAH_HOME}/conf
AMAH_LIBS=${AMAH_HOME}/libs
CONF_FILE_NAME="spark.properties"
AMAH_CONF_FILE=${AMAH_CONF}/${CONF_FILE_NAME}

if [ -z "$BD_SPARK_MASTER_URL" ]; then
    echo "\$BD_SPARK_MASTER_URL not set"
    exit 1
fi
function replacePrefix {
  sed -i "s/%BD_SPARK_MASTER_URL%/${BD_SPARK_MASTER_URL}/g" ${AMAH_CONF_FILE}
}
cp -f /opt/mntcephutils/conf/${CONF_FILE_NAME} ${AMAH_CONF}
replacePrefix
java -Xmx512m -cp "${AMAH_LIBS}/*" io.helium.amah.cli.CliMain ${AMAH_CONF_FILE}
