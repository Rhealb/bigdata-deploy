# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

ARG ARG_COMPONENT_VERSION=6.1.0

ENV ES_VERSION ${ARG_COMPONENT_VERSION}
ENV ES_NAME elasticsearch-$ES_VERSION

RUN \
  cd /opt && \
  curl -L https://artifacts.elastic.co/downloads/elasticsearch/$ES_NAME.tar.gz -o $ES_NAME.tar.gz && \
  tar xvzf $ES_NAME.tar.gz && \
  rm -f $ES_NAME.tar.gz && \
  ln -s $ES_NAME elasticsearch && \
  rm -rf /opt/$ES_NAME/lib/guava-18.0.jar && \
  /opt/$ES_NAME/bin/elasticsearch-plugin install \
  https://github.com/NLPchina/elasticsearch-sql/releases/download/${ES_VERSION}.0/elasticsearch-sql-${ES_VERSION}.0.zip

ENV ES_HOME /opt/elasticsearch
ENV ES_CONF_DIR /ES_HOME/config

WORKDIR /opt

ENTRYPOINT ["/opt/entrypoint.sh"]
