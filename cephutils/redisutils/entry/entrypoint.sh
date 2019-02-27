#!/bin/bash
set -e
if [ -z ${BD_ZK_SERVERS} ]; then
  echo "env BD_ZK_SERVERS not set "
  exit 1
fi

WORKDIR=`cd $(dirname $0) && pwd`
echo $WORKDIR

echo hostname=$HOSTNAME
if [ ! -d "/redis-cluster-data/$HOSTNAME" ]; then
  mkdir -p /redis-cluster-data/$HOSTNAME
fi
if [ ! -f "/redis-cluster-data/$HOSTNAME/redis.conf" ]; then
  cp /opt/mntcephutils/conf/redis.conf /redis-cluster-data/$HOSTNAME/redis.conf
  sed -i "s/#HOSTNAME#/$HOSTNAME/g" /redis-cluster-data/$HOSTNAME/redis.conf
fi

cd $WORKDIR && java -jar /opt/entrypoint.jar ${BD_ZK_SERVERS} /usr/bin/ redis-server /redis-cluster-data/$HOSTNAME/redis.conf
