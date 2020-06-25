ARG UBUNTU=rolling
FROM ubuntu:$UBUNTU
MAINTAINER Sebastian Braun <sebastian.braun@fh-aachen.de>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
    gettext-base \
    mariadb-server \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# COPY mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

VOLUME ["/var/lib/mysql"]

COPY entrypoint.sh entrypoint.sql /
RUN chmod +x /entrypoint.sh

EXPOSE 3306/tcp

ENTRYPOINT ["/entrypoint.sh"]
