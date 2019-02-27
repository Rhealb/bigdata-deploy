#!/bin/bash
# This script is use to build bigdata and amah images, then push to repo. The repo address is optional, if not specified, it is used to by default(10.19.248.12:29006)
# Note: If you wanted to build amah iamges, you should git clone amah source code from gitlab to path "/tmp/amah" first, like this:
#       git clone ssh://git@gitlab.cloud.enndata.cn:10885/kubernetes/amah.git /tmp/amah
#

function display_help() {
  echo
  echo "Usage: ./build_and_push_bigdata_image.sh {component or amah} {repo_url} {version}"
  echo
  echo "component: [basis zookeeper kafka hadoop spark hbase kafka-manager druid mongodb mysql opentsdb ping redis elasticsearch haproxy]"
  echo "amah: [amah-zookeeper amah-kafka amah-hadoop amah-spark amah-hbase amah-druid amah-druid amah-mysql amah-redis amah-elasticsearch amah-mongodb]"
  echo "repo_url: 10.19.248.12:29006(default)"
  echo "version: 0.0.0(default)"
  echo
  echo "For Example:"
  echo "  ./build_and_push_bigdata_image.sh zookeeper 10.19.248.12:29006 0.0.3-snapshot"
  echo "  ./build_and_push_bigdata_image.sh amah-zookeeper 10.19.248.12:29006 0.0.3-snapshot"
  echo
  echo "Note:"
  echo "  If you wanted to build amah iamges, you should git clone amah source code from gitlab to path "/tmp/amah" first, like this: "
  echo "      git clone ssh://git@gitlab.cloud.enndata.cn:10885/kubernetes/amah.git /tmp/amah"
}

if [[ $# -eq 0 ]]; then
  echo "Error:Image name is empty, please input image name first"
  display_help
  exit 1
fi
for parameter in $@; do
  case ${parameter} in
    -h | --help )
      display_help
      exit 1
      ;;
  esac
done

# Usage: ./build_component_or_amah_image.sh {component or amah} {repo_url} {version}

# component: basis zookeeper kafka hadoop spark hbase kafka-manager druid mongodb mysql opentsdb ping redis elasticsearch haproxy
# amah: amah-zookeeper amah-kafka amah-hadoop amah-spark amah-hbase amah-druid amah-druid amah-mysql amah-redis amah-elasticsearch amah-mongodb

# component image list
# base_image=${REPO_PREFIX}/he2-centos7-jdk8:${VERSION}
# zookeeper_image=${REPO_PREFIX}/dep-centos7-zookeeper-3.5.3-beta:${VERSION}
# kafka_image=${REPO_PREFIX}/dep-centos7-kafka-2.11-0.10.1.1:${VERSION}
# hadoop_image=${REPO_PREFIX}/dep-centos7-hadoop-2.7.4:${VERSION}
# spark_image=${REPO_PREFIX}/dep-centos7-spark-2.1.1-hadoop2.7:${VERSION}
# hbase_image=${REPO_PREFIX}/dep-centos7-hbase-1.2.6:${VERSION}
# opentsdb_image=${REPO_PREFIX}/dep-centos7-opentsdb-2.3.0:${VERSION}
# elasticsearch_image=${REPO_PREFIX}/dep-centos7-elasticsearch-6.1.0:${VERSION}
# druid_image=${REPO_PREFIX}/dep-centos7-druid-0.10.0:${VERSION}
# plyql_image=${REPO_PREFIX}/dep-centos7-plyql-0.11.2:${VERSION}
# kafkamanager_image=${REPO_PREFIX}/dep-centos7-kafka-manager1.3.3.8:${VERSION}
# mongodb_image=${REPO_PREFIX}/dep-centos7-mongodb-3.6.4:${VERSION}
# ping_image=${REPO_PREFIX}/dep-centos7-ping-0.0.1:${VERSION}
# mysql_image=${REPO_PREFIX}/dep-debian-mysql-5.7.18:${VERSION}
# redis_image=${REPO_PREFIX}/dep-redis4.0.2-redis:${VERSION}
# haproxy_image=${REPO_PREFIX}/haproxy-1.7.0:${VERSION}

# amah image list
# amah-zookeeper-image=${REPO_PREFIX}/amah-zookeeper-3.5.3:${VERSION}
# amah-kafka-image=${REPO_PREFIX}/amah-kafka-2.11-0.10.1.1:${VERSION}
# amah-hadoop-image=${REPO_PREFIX}/amah-hadoop-2.7.4:${VERSION}
# amah-spark-image=${REPO_PREFIX}/amah-spark-2.1.1-hadoop-2.7:${VERSION}
# amah-hbase-image=${REPO_PREFIX}/amah-hbase-1.2.6:${VERSION}
# amah-opentsdb-image=${REPO_PREFIX}/amah-opentsdb-2.3.0:${VERSION}
# amah-elasticsearch-image=${REPO_PREFIX}/amah-elasticsearch-6.1.0:${VERSION}
# amah-druid-image=${REPO_PREFIX}/amah-druid-0.10.0:${VERSION}
# amah-mongodb-image=${REPO_PREFIX}/amah-mongodb-3.6.4:${VERSION}
# amah-ping-image=${REPO_PREFIX}/amah-ping:${VERSION}
# amah-mysql-image=${REPO_PREFIX}/amah-mysql-5.7.18:${VERSION}
# amah-redis-image=${REPO_PREFIX}/amah-redis-4.0.2{VERSION}
gitlab_redis_tag=4.0.2-1.0.0
gitlab_ping_tag=1.0.1
component_or_amah=$1
repo_url_default="127.0.0.1:29006"
repo_url=${2:-${repo_url_default}}
version_default="0.0.0"
version=${3:-${version_default}}
repo_prefix="${repo_url}/tools"
if [[ "x${component_or_amah}" = "x" ]]; then
  echo "please input component or amah name"
  exit 1
fi
workdir=$(cd `dirname $0`; pwd)
basis_image_version=`cat ${workdir}/bigdata_image.conf | grep "basis_version" | awk -F "=" '{print $2}'`
basis_image_name=`cat ${workdir}/bigdata_image.conf | grep "basis_image" | awk -F "=" '{print $2}'`

docker=`command -v docker`
if [[ -z ${docker} ]]; then
  echo "please install docker"
  exit 1
fi

# pull debian:jessie for mysql
function pull_debian_for_mysql() {
  if [[ $(${docker} images | grep debian | awk '{print $2}' | grep -c ^jessie$) -eq 0 ]]; then
    ${docker} pull debian:jessie
  else
    echo "image debian:jessie already exist"
    echo
  fi
}

# download redis project from gitlab, and build entrypoint-0.2.0.jar for redis image
function build_jar_for_redis() {
  suffix=`date +%Y%m%d-%H%M%S`
  if [ -d /tmp/redis-${suffix} ]; then
    rm -rf /tmp/redis-${suffix}
  fi
  git clone ssh://git@gitlab.cloud.enndata.cn:10885/enncloud/redis-cluster.git /tmp/redis-${suffix}
  cd /tmp/redis-${suffix}/entrypoint
  git checkout ${gitlab_redis_tag}
  maven=`command -v  mvn`
  if [[ -z ${maven} ]]; then
    echo "please install mvn"
    exit 1
  fi
  ${maven} package
  if [ $? -ne 0 ]; then
    echo "Error: build jar for redis failed......"
    exit 1
  fi
  cp target/entrypoint-*.jar ${workdir}/jsonnet/redis/image/entrypoint.jar
  rm -rf /tmp/redis-${suffix}
}

# download ping project from gitlab, and build kafka2hdfs.jar for ping image
function build_jar_for_ping() {
  suffix=`date +%Y%m%d-%H%M%S`
  if [[ -d /tmp/ping-${suffix} ]]; then
    rm -rf /tmp/ping-${suffix}
  fi
  git clone ssh://git@gitlab.cloud.enndata.cn:10885/enncloud/ping.git /tmp/ping-${suffix}
  cd /tmp/ping-${suffix}
  git checkout ${gitlab_ping_tag}
  maven=`command -v mvn`
  if [[ -z ${maven} ]]; then
    echo "please install mvn"
    exit 1
  fi
  ${maven} package
  if [ $? -ne 0 ]; then
    echo "Error: build jar for redis failed......"
    exit 1
  fi
  cd target
  tar -zcf ping.tar.gz conf sbin lib kafka2hdfs.jar
  cp ping.tar.gz ${workdir}/jsonnet/ping/image
  rm -rf /tmp/ping-${suffix}
}

# download dependency project from gitlab, and build binary check for base image
function build_check_binary() {
  GO=`command -v go`
  if [ -z ${GO} ]; then
    echo "please install go"
    exit 1
  fi
  if [ "x${GOPATH}" = "x" ] || [ "x${GOROOT}" = "x" ]; then
    echo "\${GOPATH} or \${GOROOT} not set..."
    exit 1
  fi
  baseImageDockerfilePath=$1
  suffix=`date +%Y%m%d-%H%M%S`
  if [ ! -f ${baseImageDockerfilePath}/check ]; then
    if [ -d /tmp/check-${suffix} ]; then
      rm -rf /tmp/check-${suffix}
    else
      mkdir -p /tmp/check-${suffix}
    fi
    git clone ssh://git@gitlab.cloud.enndata.cn:10885/kubernetes/dependency.git /tmp/check-${suffix}
    go get github.com/spf13/pflag
    go build -o ${baseImageDockerfilePath}/check /tmp/check-${suffix}/test-ip/testIP.go
    if [ ! -f ${baseImageDockerfilePath}/check ]; then
      echo "build check binary error"
      exit 1
    fi
    if [ -d /tmp/check-${suffix} ]; then
      rm -rf /tmp/check-${suffix}
    fi
  else
    echo "binary check already exist"
  fi
}

# dokcer pull haproxy:1.7.0-alpine
function pull_haproxy() {
  if [[ $(${docker} images | grep haproxy | awk '{print $2}' | grep -c ^1.7.0-alpine$) -eq 0 ]]; then
    ${docker} pull haproxy:1.7.0-alpine
  else
    echo "image haproxy:1.7.0-alpine already exist"
    echo
  fi
}

# download amah project from gitlab, build amah image and push to repo
function build_and_push_amah_image() {
  amah=$1
  amah_version=$2
  # git clone ssh://git@gitlab.cloud.enndata.cn:10885/kubernetes/amah.git /tmp/amah
  if [[ ! -d /tmp/amah ]]; then
    echo "amah source code path /tmp/amah not exist"
    exit 1
  fi
  cd /tmp/amah
  ./docker/build.sh ${version} ${repo_url} ${amah} ${amah_version} ${basis_image_version}
  cd ${workdir}
}

# build component image by Dockerfile and push to repo
function build_and_push_component_image() {
  image_name=$1
  component=$2
  if [[ ${component} != "common" ]]; then
    component_version=$3
  fi
  if [[ ${component} = "common" ]]; then
    dockerfile_path=${workdir}/jsonnet/${component}/image/centos/centos-jdk-dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)
    echo "----------build check binary----------"
    build_check_binary ${dockerfile_dir}

  elif [[ ${component} = "druid" ]]; then
    dockerfile_path=${workdir}/jsonnet/${component}/origin/image/Dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)

  elif [[ ${component} = "plyql" ]]; then
    dockerfile_path=${workdir}/jsonnet/druid/${component}/image/Dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)

  elif [[ ${component} = "ping" ]]; then
    echo "--------- build ping.jar for ping ----------"
    build_jar_for_ping
    dockerfile_path=${workdir}/jsonnet/${component}/image/Dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)

  elif [[ ${component} = "redis" ]]; then
    build_jar_for_redis
    echo "${workdir}/jsonnet/${component}/image/Dockerfile"
    dockerfile_path=${workdir}/jsonnet/${component}/image/Dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)

  elif [[ ${component} = "mysql" ]]; then
    echo
    echo "---------- pull image debian:jessie for mysql ----------"
    pull_debian_for_mysql
    dockerfile_path=${workdir}/jsonnet/${component}/image/Dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)

  elif [[ ${component} = "haproxy" ]]; then
    echo
    echo "---------- pull image haproxy:1.7.0-alpine for haproxy ----------"
    pull_haproxy
    dockerfile_path=${workdir}/jsonnet/${component}/image/Dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)

  elif [[ ${component} = "kafka" ]]; then
    echo
    echo "---------- split kafka verion: ${component_version} for kafka Dockfile ----------"
    dockerfile_path=${workdir}/jsonnet/${component}/image/Dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)
    scala_version=$(echo ${component_version} | awk -F "-" '{print $1}')
    kafka_version=$(echo ${component_version} | awk -F "-" '{print $2}')
    echo "----------build ${image_name}----------"
    ${docker} build --build-arg ARG_SCALA_VERSION=${scala_version} --build-arg ARG_KAFKA_VERSION=${kafka_version} --build-arg ARG_VERSION=${basis_image_version} --build-arg ARG_PREFIX=${repo_prefix} -t ${image_name} -f ${dockerfile_path} ${dockerfile_dir}
    echo
    echo
    echo "----------push ${image_name} ----------"
    ${docker} push ${image_name}
    exit 0

  elif [[ ${component} = "spark" ]]; then
    echo
    echo "---------- split spark version: ${component_version} for spark Dockfile ----------"
    spark_version=$(echo ${component_version} | awk -F "-" '{print $1}')
    hadoop_version=$(echo ${component_version} | awk -F "-" '{print $2}')
    dockerfile_path=${workdir}/jsonnet/${component}/image/Dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)
    echo "----------build ${image_name}----------"
    ${docker} build --build-arg ARG_SPARK_VERSION=${spark_version} --build-arg ARG_HADOOP_VERSION=${hadoop_version} --build-arg ARG_VERSION=${basis_image_version} --build-arg ARG_PREFIX=${repo_prefix} -t ${image_name} -f ${dockerfile_path} ${dockerfile_dir}
    echo
    echo
    echo "----------push ${image_name} ----------"
    ${docker} push ${image_name}
    exit 0
  else
    dockerfile_path=${workdir}/jsonnet/${component}/image/Dockerfile
    dockerfile_dir=$(cd `dirname ${dockerfile_path}`; pwd)
  fi
  echo "----------build ${image_name}----------"
  ${docker} build --build-arg ARG_COMPONENT_VERSION=${component_version} --build-arg ARG_VERSION=${basis_image_version} --build-arg ARG_PREFIX=${repo_prefix} -t ${image_name} -f ${dockerfile_path} ${dockerfile_dir}
  echo
  echo
  echo "----------push ${image_name} ----------"
  ${docker} push ${image_name}
}

# build and push component or amah image
function build_and_push_image() {
  component_or_amah=$1
  if [ $(echo ${component_or_amah} | grep ^amah- | wc -l) -ne 0 ]; then
    # build and push amah image
    amah_version=`cat ${workdir}/bigdata_image.conf | grep ${component_or_amah:5}_version | awk -F "=" '{print $2}'`
    if [[ "x${amah_version}" = "x" ]]; then
      echo "Sorry! ${component_or_amah} is currently not support"
      exit 1
    fi
    build_and_push_amah_image ${component_or_amah} ${amah_version}
  else
    # build and push component image
    component_name=`cat ${workdir}/bigdata_image.conf | grep ${component_or_amah}_image | awk -F "=" '{print $2}'`
    if [[ "x${component_name}" = "x" ]]; then
      echo "Sorry! ${component_or_amah} is currently not support"
      exit 1
    fi
    component_version=`cat ${workdir}/bigdata_image.conf | grep ${component_or_amah}_version | awk -F "=" '{print $2}'`
    if [ ${component_name} = ${basis_image_name} ]; then
      version=${component_version}
    fi
    image_name=${repo_prefix}/${component_name}:${version}
    if [ $(echo ${image_name} | grep -c ${basis_image_name}) -eq 1 ]; then
      build_and_push_component_image ${image_name} "common"
    else
      build_and_push_component_image ${image_name} ${component_or_amah} ${component_version}
    fi
  fi
}

build_and_push_image ${component_or_amah}
