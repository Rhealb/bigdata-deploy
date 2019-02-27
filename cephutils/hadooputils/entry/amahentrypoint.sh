#!/bin/bash
set -e
AMAH_HOME=/opt/amah-hadoop
AMAH_CONF=${AMAH_HOME}/conf
AMAH_LIBS=${AMAH_HOME}/libs
CONF_FILE_NAME="hadoop.properties"
AMAH_CONF_FILE=${AMAH_CONF}/${CONF_FILE_NAME}

if [ -z "$BD_HDFS_URL" ]; then
    echo "\$BD_HDFS_URL not set"
    exit 1
fi

if [ -z "$BD_YARN_URL" ]; then
    echo "\$BD_YARN_URL not set"
    exit 1
fi

if [ -z "$BD_MONITOR_CLUSTER_TYPE" ]; then
    echo "\$BD_MONITOR_CLUSTER_TYPE not set"
    exit 1
fi

function replacePrefix {
  sed -i "s/%BD_HDFS_URL%/${BD_HDFS_URL}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_YARN_URL%/${BD_YARN_URL}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_MONITOR_CLUSTER_TYPE%/${BD_MONITOR_CLUSTER_TYPE}/g" ${AMAH_CONF_FILE}
}
cp -f /opt/mntcephutils/conf/${CONF_FILE_NAME} ${AMAH_CONF}
replacePrefix
java -Xmx512m -cp "${AMAH_LIBS}/*" io.helium.amah.cli.CliMain ${AMAH_CONF_FILE}
