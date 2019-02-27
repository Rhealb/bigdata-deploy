#!/bin/bash
clickhouse-client -h 127.0.0.1 -m -n --query "`cat /opt/mntcephutils/scripts/kafka-sql.txt`"
