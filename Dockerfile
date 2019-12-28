FROM alpine:3.11.2
MAINTAINER Sebastian Braun <sebastian.braun@fh-aachen.de>
# base alpine template

# Download requirements
RUN apk add --no-cache mysql \
 && addgroup mysql mysql \
 && mkdir /startup

COPY mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

VOLUME ["/var/lib/mysql"]

COPY run.sh /startup/run.sh
RUN chmod +x /startup/run.sh

EXPOSE 3306/tcp

ENTRYPOINT ["/startup/run.sh"]
