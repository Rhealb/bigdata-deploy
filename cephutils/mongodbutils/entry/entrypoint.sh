#!/bin/bash
set -e
MONGODB_HOME=/opt/mongodb
if [ -z ${BD_MONGODB_DATADIR} ]; then
  echo "env BD_MONGODB_DATADIR not set"
  exit 1
fi
if [ -z ${BD_MONGODB_LOGDIR} ]; then
  echo "env BD_MONGODB_LOGDIR not set"
  exit 1
fi
if [ -z ${BD_MONGODB_RS_NAME} ]; then
  echo "env BD_MONGODB_RS_NAME not set"
  exit 1
fi
if [ -z "${BD_MONGODB_SERVERS}" ]; then
  echo "env BD_MONGODB_SERVERS not set"
  exit 1
fi
if [ -z ${BD_MONGODB_SERVERS_COUNT} ]; then
  echo "env BD_MONGODB_SERVERS_COUNT not set"
  exit 1
fi
if [ -z ${BD_LIMIT_MEM} ]; then
  echo "env BD_LIMIT_MEM not set"
  exit 1
fi

MINCACHESIZE=0.25
if [ ${BD_LIMIT_MEM: -2 : 2} == "Gi" ] || [ ${BD_LIMIT_MEM: -1 : 1} == "G" ]; then
  BD_CACHESIZE=`awk 'BEGIN{printf "%0.2f\n",(('${BD_LIMIT_MEM%%G*}' - 1)) * 0.5}'`
elif [ ${BD_LIMIT_MEM: -2 : 2} == "Mi" ] || [ ${BD_LIMIT_MEM: -1 : 1} == "M" ]; then
  if [ ${BD_LIMIT_MEM: -1 : 1} == "M" ]; then
    divisor=1000
  else
    divisor=1024
  fi
  BD_CACHESIZE=`awk 'BEGIN{printf "%0.2f\n",(('${BD_LIMIT_MEM%%M*}' / '${divisor}' - 1)) * 0.5}'`
else
  echo "ERROR: limitmemory wrong format"
  BD_CACHESIZE=${MINCACHESIZE}
fi

tag=`echo "${BD_CACHESIZE} ${MINCACHESIZE}"|awk '$1<$2'`
if [ "${tag}" != "" ]; then
  echo "WARNING: set BD_CACHESIZE to ${MINCACHESIZE}"
  BD_CACHESIZE=${MINCACHESIZE}
fi

function relpaceVariable {
  sed -i "s|%BD_MONGODB_LOGDIR%|$BD_MONGODB_LOGDIR|g" ${MONGODB_HOME}/conf/mongo.conf
  sed -i "s|%BD_MONGODB_DATADIR%|$BD_MONGODB_DATADIR|g" ${MONGODB_HOME}/conf/mongo.conf
  sed -i "s|%MONGODB_HOME%|$MONGODB_HOME|g" ${MONGODB_HOME}/conf/mongo.conf
  sed -i "s|%BD_MONGODB_RS_NAME%|$BD_MONGODB_RS_NAME|g" ${MONGODB_HOME}/conf/mongo.conf
  sed -i "s|%BD_CACHESIZE%|$BD_CACHESIZE|g" ${MONGODB_HOME}/conf/mongo.conf
}
mkdir -p ${BD_MONGODB_DATADIR}
mkdir -p ${BD_MONGODB_LOGDIR}
touch ${BD_MONGODB_LOGDIR}/mongod.log
cp -f /opt/mntcephutils/conf/* ${MONGODB_HOME}/conf/
relpaceVariable
cp -rf /opt/mntcephutils/scripts /opt
chmod +x /opt/scripts/*
initcfg="{_id:\"${BD_MONGODB_RS_NAME}\",members:${BD_MONGODB_SERVERS}}"
echo "rs.initiate(${initcfg})" > /tmp/initcluster
if [ $(echo $HOSTNAME | grep mongodb1 | wc -l) -ne 0 ]; then
  nohup /opt/scripts/initialCluster.sh /tmp/initcluster &
fi

${MONGODB_HOME}/bin/mongod -f ${MONGODB_HOME}/conf/mongo.conf
