FROM appian-base

ENV DATA_SERVER_HOME ${APPIAN_HOME}/data-server

COPY /build-conf/data-server-custom.properties $DATA_SERVER_HOME/conf/custom.properties

HEALTHCHECK --interval=3s --timeout=2s --retries=300 \
  CMD $DATA_SERVER_HOME/bin/status.sh | grep -q "health.*GREEN" || exit 1

CMD [ \
      "--", \
      "$DATA_SERVER_HOME/bin/start.sh -f" ]
