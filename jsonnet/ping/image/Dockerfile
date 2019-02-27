# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

RUN mkdir /opt/ping
COPY ping.tar.gz /opt/ping/
RUN cd /opt/ping && tar zxf ping.tar.gz && rm ping.tar.gz
ENTRYPOINT /opt/entrypoint.sh
