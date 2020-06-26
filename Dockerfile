ARG UBUNTU=rolling
FROM ubuntu:$UBUNTU
MAINTAINER Sebastian Braun <sebastian.braun@fh-aachen.de>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
    gettext-base \
    mariadb-server \
    vim \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /

RUN \ 
    sed -i 's/bind-address.*//' /etc/mysql/mariadb.conf.d/50-server.cnf && \
    sed -i -e "s/\(\[mysqld\]\)/\1\nskip-host-cache/g" /etc/mysql/mariadb.conf.d/50-server.cnf && \ 
    sed -i -e "s/\(\[mysqld\]\)/\1\nskip-name-resolve/g" /etc/mysql/mariadb.conf.d/50-server.cnf && \ 
    rm -rf /var/lib/mysql/* && \
    mkdir -p /var/lib/mysql /var/run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/log/mysql && \
    chmod +x /entrypoint.sh

EXPOSE 3306/tcp

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/mysqld_safe"]
