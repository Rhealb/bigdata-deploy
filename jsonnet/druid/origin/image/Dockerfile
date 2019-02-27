# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

ARG ARG_COMPONENT_VERSION=0.10.0

# DRUID
ENV DRUID_VERSION ${ARG_COMPONENT_VERSION}
ENV DRUID_DIR=druid-${DRUID_VERSION}
ENV DRUID_PACKAGE=${DRUID_DIR}-bin

# Download druid, untar and clean up
RUN set -x && \
    curl -L -C - "http://static.druid.io/artifacts/releases/${DRUID_PACKAGE}.tar.gz" | \
         tar -xz -C /opt && \
    cd /opt && \
    ln -s ${DRUID_DIR} druid

ENV DRUID_HOME /opt/druid
ENV PATH $PATH:${DRUID_HOME}/bin
ENV DRUID_CONF_DIR ${DRUID_HOME}/conf

ENV MYSQL_META_STORAGE=mysql-metadata-storage
ENV MYSQL_META_STORAGE_PACKAGE=${MYSQL_META_STORAGE}-${DRUID_VERSION}
# Download mysql-metadata-storage
RUN set -x && \
    curl -L -C - "http://static.druid.io/artifacts/releases/${MYSQL_META_STORAGE_PACKAGE}.tar.gz" | \
         tar -xz -C ${DRUID_HOME}/extensions/

RUN yum install -y maven && \
    yum clean all && \
    rm -rf /var/cache/yum/*
RUN mkdir ${DRUID_HOME}/tmp
COPY pom.xml ${DRUID_HOME}/tmp/
RUN cd ${DRUID_HOME}/tmp && \
    mvn dependency:copy-dependencies && \
    mkdir -p ${DRUID_HOME}/hadoop-dependencies/hadoop-client/2.7.4 && \
    mv target/dependency/* ${DRUID_HOME}/hadoop-dependencies/hadoop-client/2.7.4/ && \
    cd ${DRUID_HOME} && \
    rm -rf ${DRUID_HOME}/tmp

WORKDIR /opt

CMD ["tail", "-f", "/var/log/lastlog"]
