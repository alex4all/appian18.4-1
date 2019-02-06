FROM mysql:5.7.21

EXPOSE 3306

ENV MYSQL_ALLOW_EMPTY_PASSWORD yes
ENV MYSQL_USER appian
ENV MYSQL_PASSWORD appian

HEALTHCHECK --interval=3s --timeout=2s --retries=30 \
 CMD mysqladmin -u $MYSQL_USER --password=$MYSQL_PASSWORD ping -h localhost || exit 1
