# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

# TRANQUILITY
ENV TRANQUILITY_VERSION 0.8.2
ENV TRANQUILITY_DIR=tranquility-distribution-${TRANQUILITY_VERSION}
ENV TRANQUILITY_PACKAGE=${TRANQUILITY_DIR}

# Download tranquility, untar and clean up
RUN set -x && \
    curl -L -C - "http://static.druid.io/tranquility/releases/${TRANQUILITY_PACKAGE}.tgz" | \
         tar -xz -C /opt && \
    cd /opt && \
    ln -s ${TRANQUILITY_DIR} tranquility

ENV TRANQUILITY_HOME /opt/tranquility
ENV PATH $PATH:${TRANQUILITY_HOME}/bin
ENV TRANQUILITY_CONF_DIR ${TRANQUILITY_HOME}/conf

WORKDIR /opt

ENTRYPOINT ["tail", "-f", "/var/log/lastlog"]
