#!/bin/bash
set -e
if [ -z "${BD_SUITE_PREFIX}" ]; then
    echo "\${BD_SUITE_PREFIX} not set"
    exit 1
fi

if [ -z "${BD_DRUID_PREFIX}" ]; then
    echo "\${BD_DRUID_PREFIX} not set, set BD_DRUID_PREFIX to ${BD_SUITE_PREFIX}"
    BD_DRUID_PREFIX=${BD_SUITE_PREFIX}
fi

echo "/opt/plyql/bin/plyql -h ${BD_DRUID_PREFIX}-broker:8082 --experimental-mysql-gateway 3306"
/opt/plyql/bin/plyql -h ${BD_DRUID_PREFIX}-broker:8082 --experimental-mysql-gateway 3306
