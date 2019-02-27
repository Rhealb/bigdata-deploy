# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

ARG ARG_COMPONENT_VERSION=1.2.6

# HBASE
ENV HBASE_VERSION ${ARG_COMPONENT_VERSION}
ENV HBASE_PACKAGE hbase-$HBASE_VERSION-bin

RUN curl -L -C - http://archive.apache.org/dist/hbase/$HBASE_VERSION/$HBASE_PACKAGE.tar.gz | \
         tar -zx -C /opt  && \
    cd /opt && \
    ln -s hbase-$HBASE_VERSION hbase

ENV HBASE_HOME /opt/hbase
ENV PATH $PATH:$HBASE_HOME/bin

ENTRYPOINT ["/opt/entrypoint.sh"]
