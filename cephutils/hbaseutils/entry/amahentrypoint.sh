#!/bin/bash
set -e
AMAH_HOME=/opt/amah-hbase
AMAH_CONF=${AMAH_HOME}/conf
AMAH_LIBS=${AMAH_HOME}/libs
CONF_FILE_NAME="hbase.properties"
AMAH_CONF_FILE=${AMAH_CONF}/${CONF_FILE_NAME}

if [ -z "$BD_HBASE_MASTER_SERVERS" ]; then
    echo "\$BD_HBASE_MASTER_SERVERS not set"
    exit 1
fi
function replacePrefix {
  sed -i "s/%BD_HBASE_MASTER_SERVERS%/${BD_HBASE_MASTER_SERVERS}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_SUITE_PREFIX%/${BD_SUITE_PREFIX}/g" $AMAH_CONF/hdfs-site.xml
  sed -i -e "s/%ZKNAME%/${ZKNAME}/g"  $AMAH_CONF/hbase-site.xml
  sed -i -e "s/%HOSTNAME%/${HOSTNAME}/g" $AMAH_CONF/hbase-site.xml
}
cp -f /opt/mntcephutils/conf/* ${AMAH_CONF}
replacePrefix
java -Xmx512m -cp "${AMAH_LIBS}/*:${AMAH_CONF}" io.helium.amah.cli.CliMain ${AMAH_CONF_FILE}
