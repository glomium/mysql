ARG UBUNTU=rolling
FROM ubuntu:$UBUNTU
MAINTAINER Sebastian Braun <sebastian.braun@fh-aachen.de>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
    gettext-base \
    mariadb-server \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# COPY mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

COPY entrypoint.sh entrypoint.sql /
RUN \ 
    sed -i 's/bind-address.*//' /etc/mysql/mariadb.conf.d/50-server.cnf && \
    chmod +x /entrypoint.sh

EXPOSE 3306/tcp

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/entrypoint.sh"]
