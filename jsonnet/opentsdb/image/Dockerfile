# Please use command below to build the image:
# docker build -f Dockerfile -t <image_name>:<version> .

ARG ARG_VERSION=0.1
ARG ARG_PREFIX=127.0.0.1:29006/tools
FROM ${ARG_PREFIX}/he2-centos7-jdk8:${ARG_VERSION}

ARG ARG_COMPONENT_VERSION=2.3.0

ENV OPENTSDB_VERSION ${ARG_COMPONENT_VERSION}

RUN yum -y install gnuplot

RUN curl -o /opt/opentsdb-${OPENTSDB_VERSION}.rpm -L -C - https://github.com/OpenTSDB/opentsdb/releases/download/v${OPENTSDB_VERSION}/opentsdb-${OPENTSDB_VERSION}.rpm && \
	 rpm -ivh /opt/opentsdb-${OPENTSDB_VERSION}.rpm && \
	 rm /opt/opentsdb-${OPENTSDB_VERSION}.rpm

ENV PATH $PATH:/usr/share/opentsdb/bin

ENTRYPOINT ["/opt/entrypoint.sh"]
