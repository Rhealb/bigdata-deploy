#!/bin/bash
set -e

if [ -z "${BD_ZK_PREFIX}" ]; then
    echo "\${BD_ZK_PREFIX} not set"
    exit 1
fi

if [ -z "${BD_ZK_INSTANCE_COUNT}" ]; then
    echo "\${BD_ZK_INSTANCE_COUNT} not set"
    exit 1
fi

num=${BD_ZK_INSTANCE_COUNT}
res=""
for (( i = 1; i <= ${num}; i++ )); do
  res=${res}"\n\t<node index=\"${i}\"> <host>${BD_ZK_PREFIX}-zookeeper${i}</host> <port>2181</port> </node>"
done
cp /opt/mntcephutils/conf/config.xml ${CLICKHOUSE_CONFIG}
sed -i "s|#BD_ZOOKEEPER_SERVER#|${res}|g" ${CLICKHOUSE_CONFIG}
sed -i "s/#SERVER_ID#/${SERVER_ID}/g" ${CLICKHOUSE_CONFIG}
sed -i "s/#clickhouse_in_zk#/${BD_ZK_PREFIX}_clickhouse/g" ${CLICKHOUSE_CONFIG}
/usr/bin/clickhouse-server --config=${CLICKHOUSE_CONFIG}
