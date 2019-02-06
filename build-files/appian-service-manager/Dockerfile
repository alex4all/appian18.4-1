FROM appian-base

ARG CRONSTRING
ARG KEEP

WORKDIR $APPIAN_HOME

COPY --chown=appian appian-service-manager/passwordWrapper.sh $APPIAN_HOME/passwordWrapper.sh

RUN chmod +x passwordWrapper.sh && dos2unix passwordWrapper.sh \
  && (crontab -l 2>/dev/null; echo "${CRONSTRING} ${APPIAN_HOME}/services/bin/cleanupArchives.sh --keep ${KEEP}") | crontab -

CMD [ \
      "--log=$APPIAN_HOME/logs/service_manager.log", \
      "--stop=$APPIAN_HOME/passwordWrapper.sh stop.sh -s all", \
      "--", "$APPIAN_HOME/passwordWrapper.sh start.sh -s all" ]
