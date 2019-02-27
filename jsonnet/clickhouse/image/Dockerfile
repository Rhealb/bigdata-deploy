FROM centos:centos7.0.1406
#需要预先准备好clickhouse的二进制执行文件,可以从如下地址下载：https://owncloud.cloud.enndata.cn/index.php/s/O7I8YSOHt4MXhZs，该二进制文件对应的源码为：https://gitlab.cloud.enndata.cn/liuyangkuan/ClickHouse.git，branch为isLocal， commit SHA1值为：24587446c1ce220322e91e5115156f3e342a4ae3
RUN yum makecache && \
    yum install -y libiodbc.x86_64 libtool-ltdl libicu gdb-7.6.1-94.el7.x86_64 && \
    yum clean all && \
    mkdir /etc/clickhouse-server && \
    mkdir /var/log/clickhouse-server
COPY config.xml /etc/clickhouse-server/config.xml
COPY clickhouse /usr/bin/clickhouse
RUN ln -s /usr/bin/clickhouse /usr/bin/clickhouse-server && ln -s /usr/bin/clickhouse /usr/bin/clickhouse-client

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod a+x /opt/entrypoint.sh

EXPOSE 9000 8123 9009
VOLUME /var/lib/clickhouse

ENV CLICKHOUSE_CONFIG /etc/clickhouse-server/config.xml
ENV SERVER_ID unknow

ENTRYPOINT ["tail", "-f", "/var/log/lastlog"]
#ENTRYPOINT sed -i "s/#SERVER_ID#/${SERVER_ID}/g" ${CLICKHOUSE_CONFIG} && exec /usr/bin/clickhouse-server --config=${CLICKHOUSE_CONFIG}
