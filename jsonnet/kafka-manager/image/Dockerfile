# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

ARG ARG_COMPONENT_VERSION=1.3.3.8

ENV KAFKAMANAGER_VERSION ${ARG_COMPONENT_VERSION}

# Download Apache Kafka-manager, build and cleanup
# wget https://github.com/yahoo/kafka-manager/archive/${KAFKAMANAGER_VERSION}.tar.gz
RUN mkdir /root/.sbt/
COPY repositories /root/.sbt/repositories 

RUN set -x && \
    curl -L -C - "https://github.com/yahoo/kafka-manager/archive/${KAFKAMANAGER_VERSION}.tar.gz" | tar -xz -C /opt && \
	cd /opt && \
    cd kafka-manager-${KAFKAMANAGER_VERSION} && \
    ./sbt clean dist && \
    yum -y update && \
    yum install -y unzip && \
    yum clean all && \
    rm -rf /var/cache/yum/* && \
    mv /opt/kafka-manager-${KAFKAMANAGER_VERSION}/target/universal/kafka-manager-${KAFKAMANAGER_VERSION}.zip /opt && \
    rm /opt/kafka-manager-${KAFKAMANAGER_VERSION} /root/.sbt /root/.ivy2 -rf && \
    cd /opt && \
    unzip kafka-manager-${KAFKAMANAGER_VERSION}.zip && \
    rm kafka-manager-${KAFKAMANAGER_VERSION}.zip && \
    ln -s kafka-manager-${KAFKAMANAGER_VERSION} kafka-manager && \
    rm -rf /opt/kafka-manager/share && \
    yum -y remove unzip

ENV KAFKAMANAGER_HOME /opt/kafka-manager
ENV PATH $PATH:${KAFKAMANAGER_HOME}/bin

WORKDIR /opt

ENTRYPOINT ["/opt/entry/entrypoint.sh"]
