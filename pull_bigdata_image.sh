#!/bin/bash
# Usage: ./pull_component_or_amah_image.sh [component_or_amah name] [repo_url] [version] [save_dir]
# This script is used to pull image from repo, and save image to tar package in local

function display_help() {
  echo
  echo "Usage: ./pull_bigdata_image.sh [component or amah] [repo_url] [version] [save_dir]"
  echo
  echo "component: [basis zookeeper kafka hadoop spark hbase kafka-manager druid mongodb mysql opentsdb ping redis elasticsearch haproxy]"
  echo "amah: [amah-zookeeper amah-kafka amah-hadoop amah-spark amah-hbase amah-druid amah-druid amah-mysql amah-redis amah-elasticsearch amah-mongodb]"
  echo "repo_url: 10.19.248.12:29006(default)"
  echo "version: 0.0.0(default)"
  echo "save_dir: local directory in you host, which is used to storage image compression package. if save_dir is empty, the script just pull image to local repo, do not save to tar package"
  echo
  echo "For Example:"
  echo "  ./pull_bigdata_image.sh zookeeper  10.19.248.12:29006 0.0.3-snapshot /tmp/imagetar"
  echo "  ./pull_bigdata_image.sh zookeeper  10.19.248.12:29006 0.0.3-snapshot"
  echo "  ./pull_bigdata_image.sh amah-zookeeper 10.19.248.12:29006 0.0.3-snapshot /tmp/imagetar"
  echo "  ./pull_bigdata_image.sh amah-zookeeper 10.19.248.12:29006 0.0.3-snapshot"
  echo
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

component_or_amah=$1
if [ -z ${component_or_amah} ]; then
  echo "Error: please input component or amah name"
  exit 1
fi

repo_url=${2:-10.19.248.12:29006}
repo_prefix=${repo_url}/tools
repo_url_port=`echo ${repo_url} | awk -F ":" '{print $2}'`
tag_prefix=127.0.0.1:${repo_url_port}/tools
version=${3:-0.0.0}
save_dir=${4:-""}
workdir=$(cd `dirname $0`; pwd)
DOCKER=`command -v docker`
if [[ "x${DOCKER}" = "x" ]]; then
  echo "please install docker"
  exit 1
fi

if [[ $(echo ${component_or_amah} | grep -c ^amah-) -eq 1 ]]; then
  # pull amah image
  image_version=`cat ${workdir}/bigdata_image.conf | grep ${component_or_amah:5}_version | awk -F "=" '{print $2}'`
  if [[ "x${image_version}" = "x" ]]; then
    echo "Sorry! ${component_or_amah} is currently not support"
    exit 1
  else
    image_name=${repo_prefix}/${component_or_amah}-${image_version}:${version}
    tag_image_name=${tag_prefix}/${component_or_amah}-${image_version}:${version}
    ${DOCKER} pull ${image_name}
    ${DOCKER} tag ${image_name} ${tag_image_name}
    if [[ "x${save_dir}" != "x" ]]; then
      if [ ! -d ${save_dir} ]; then
        mkdir -p ${save_dir}
      fi
      # save image to local dir
      image_tgz=${component_or_amah}-${image_version}
      ${DOCKER} save ${tag_image_name} | gzip > ${save_dir}/${image_tgz}.tgz
    fi
  fi
else
  # pull component image
  component_name=`cat ${workdir}/bigdata_image.conf | grep ${component_or_amah}_image | awk -F "=" '{print $2}'`
  if [[ "x${component_name}" = "x" ]]; then
    echo "Sorry! ${component_or_amah} is currently not support"
    exit 1
  fi
  if [[ ${component_or_amah} = "basis" ]]; then
    version=`cat ${workdir}/bigdata_image.conf | grep ${component_or_amah}_version | awk -F "=" '{print $2}'`
  fi
  image_name=${repo_prefix}/${component_name}:${version}
  echo "${DOCKER} pull ${image_name}"
  ${DOCKER} pull ${image_name}
  tag_image_name=${tag_prefix}/${component_name}:${version}
  ${DOCKER} tag ${image_name} ${tag_image_name}
  if [[ "x${save_dir}" != "x" ]]; then
    # save image to local dir
    if [ ! -d ${save_dir} ]; then
      mkdir -p ${save_dir}
    fi
    image_tgz=$(echo ${image_name} | awk -F ":" '{print $2}' | awk -F "/" '{print $NF}')
    ${DOCKER} save ${tag_image_name} | gzip > ${save_dir}/${image_tgz}.tgz
  fi
fi
