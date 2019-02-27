# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

ARG ARG_COMPONENT_VERSION=3.6.4

ENV MONGODB_VERSION ${ARG_COMPONENT_VERSION}
ENV MONGODB_NAME mongodb-linux-x86_64-rhel70-${MONGODB_VERSION}
ENV MONGODB_HOEM /opt/mongodb

# Download mongodb, untar and clean up
RUN set -x && \
    curl -L -C - http://downloads.mongodb.org/linux/${MONGODB_NAME}.tgz | \
         tar -xz -C /opt && \
    cd /opt && \
    ln -s ${MONGODB_NAME} mongodb && \
    rm -f ${MONGODB_NAME}.tgz && \
    mkdir /opt/mongodb/conf
WORKDIR /opt
CMD ["/opt/entrypoint.sh"]
