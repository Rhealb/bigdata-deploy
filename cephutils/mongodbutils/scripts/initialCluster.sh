#!/bin/bash
set -e
sleep 10
initcmdfile=$1
if [ ! -f ${initcmdfile} ]; then 
  echo "initail mongodb cluster config file:${initcmdfile} not exist..."
  exit 1
fi
success=0
while [ ${success} -eq 0 ]; do
  sleep 1
  success=$(/opt/mongodb/bin/mongo < ${initcmdfile} 2>&1 | grep -E "\"ok\" : 1|\"errmsg\" : \"already initialized\"" | wc -l)
  echo ${success}
done 
