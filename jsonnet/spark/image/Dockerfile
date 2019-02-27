# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

ARG ARG_SPARK_VERSION=2.1.1
ARG ARG_HADOOP_VERSION=hadoop2.7

ENV SPARK_VERSION ${ARG_SPARK_VERSION} 
ENV HADOOP_VERSION ${ARG_HADOOP_VERSION}
ENV SPARK_PREFIX spark-${SPARK_VERSION}
ENV SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-${HADOOP_VERSION}

# Download Apache Spark, untar and clean up
RUN set -x && \
    curl -L -C - "http://archive.apache.org/dist/spark/${SPARK_PREFIX}/${SPARK_PACKAGE}.tgz" | \
         tar -xz -C /opt && \
    cd /opt && \
    ln -s ${SPARK_PACKAGE} spark

ENV SPARK_HOME /opt/spark
ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
ENV SPARK_CONF_DIR ${SPARK_HOME}/conf

WORKDIR /opt

ENTRYPOINT ["tail", "-f", "/var/log/lastlog"]
