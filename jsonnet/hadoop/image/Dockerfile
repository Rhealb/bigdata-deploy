# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

ARG ARG_COMPONENT_VERSION=2.7.4

# HADOOP
ENV HADOOP_VERSION ${ARG_COMPONENT_VERSION}
RUN curl -L -C - http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-$HADOOP_VERSION.tar.gz | \
         tar -xz -C /opt && \
    cd /opt && \
    ln -s hadoop-$HADOOP_VERSION hadoop

ENV HADOOP_HOME /opt/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_HOME/etc/hadoop

WORKDIR /opt

CMD ["/opt/entrypoint.sh"]
