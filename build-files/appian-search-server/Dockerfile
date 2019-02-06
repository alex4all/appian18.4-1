FROM appian-base

CMD [ \
      "--log=$APPIAN_HOME/logs/search-server/search-server.log", \
      "--stop=$APPIAN_HOME/search-server/bin/stop.sh", \
      "--", "$APPIAN_HOME/search-server/bin/start.sh" ]
