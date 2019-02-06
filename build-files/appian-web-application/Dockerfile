FROM appian-base

WORKDIR /tmp

# environment variables
ENV MYSQL_CONN mysql-connector-java-*-bin.jar
ENV TOMCAT_LOG_FILE ${APPIAN_HOME}/logs/tomcat-stdOut.log
ENV TOMCAT_CONTEXT_DIR $CATALINA_HOME/conf/Catalina/localhost

# datasources setup
COPY /installers/$MYSQL_CONN $CATALINA_HOME/lib
COPY /build-conf/tomcatResources.xml /tmp
RUN TOMCAT_CONTEXT_FILENAME=`ls $TOMCAT_CONTEXT_DIR | head -1` && \
    TOMCAT_CONTEXT_PATH="$TOMCAT_CONTEXT_DIR/$TOMCAT_CONTEXT_FILENAME" && \
    context=$(<$TOMCAT_CONTEXT_PATH) && \
    datasources=$(<tomcatResources.xml) && \
    echo "${context//<!-- BEGIN DATASOURCES -->[[:space:]]*<!-- END DATASOURCES -->/<!-- BEGIN DATASOURCES -->$'\n'$datasources$'\n'  <!-- END DATASOURCES -->}" > $TOMCAT_CONTEXT_PATH

# Ensure that, when built on Windows, certain files have executable permission
RUN find $APPIAN_HOME -type f -name '*.sh' -exec chmod +x {} \+ && \
    find $APPIAN_HOME -type f -name '*.sh' -exec dos2unix {} \+

WORKDIR $APPIAN_HOME

# expose Tomcat port
EXPOSE 8080

HEALTHCHECK --interval=3s --timeout=2s --retries=300 \
  CMD \
    APPLICATION_CONTEXT=`ls $TOMCAT_CONTEXT_DIR | head -1 | cut -d. -f1` \
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/$APPLICATION_CONTEXT) \
    if [ "$HTTP_STATUS" == "200" ] || [ "$HTTP_STATUS" == "302" ]; then \
      printf "startup completed: $HTTP_STATUS"; exit 0; \
    else \
      printf "startup in progress: $HTTP_STATUS"; exit 1; \
    fi

CMD [ \
      "--stop=$CATALINA_HOME/bin/stop-appserver.sh", \
      "--", \
      " ${CATALINA_HOME}/bin/catalina.sh run 2>&1 | tee ${TOMCAT_LOG_FILE} && tail -f ${TOMCAT_LOG_FILE}"]
