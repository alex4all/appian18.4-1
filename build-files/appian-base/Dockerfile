FROM centos:7 as installer-base

ARG APPIAN_USER_ID
RUN if [ -z ${APPIAN_USER_ID} ]; then \
  echo "ERROR: Uncomment the lines 'args' and 'APPIAN_USER_ID' in docker-compose.yml under the 'base' service"; \
  echo "On Linux, set 'APPIAN_USER_ID' to be the uid of the 'appian' user on the host machine"; \
  echo "On Mac and Windows, set 'APPIAN_USER_ID' to 9999"; \
  exit 1; fi

WORKDIR /tmp

# environment variables for build
ENV APPIAN_HOME /usr/local/appian/ae
ENV APPIAN_INSTALLER_LINUX setupLinux64_appian-*.bin
ENV HOTFIX_PACKAGE *_Hotfix_Package_*.zip

RUN yum -y install unzip \
  && yum clean all \
  && rm -rf /var/cache/yum

COPY /installers /tmp

#install Appian
RUN if [[ $(echo $APPIAN_INSTALLER_LINUX) =~ \  ]]; then \
    echo "ERROR: More than one installer exists in appian-base/installers/"; \
    exit 1; fi \
  && chmod +x $APPIAN_INSTALLER_LINUX \
  && mkdir -p $APPIAN_HOME \
  && mkdir -p $APPIAN_HOME/services/data/data-server \
  && mkdir -p $APPIAN_HOME/services/data/kafka-logs \
  && echo "Installing Appian (this could take up to a few minutes)" \
  && ./$APPIAN_INSTALLER_LINUX --mode silent --prefix $APPIAN_HOME --temp /tmp \
  && rm $APPIAN_INSTALLER_LINUX \
  && echo "Installation finished" \
# apply Hotfix conditionally: Note, this can be removed once
# we know the installer will contain the latest Hotfix
  && if [[ "0" -eq $(find . -name $HOTFIX_PACKAGE | wc -l) ]]; then \
    echo "WARN: No hotfix found, skipping"; \
  else \
    echo "Hotfix found, applying (this could take up to a few minutes)" \
    && unzip -oqd $APPIAN_HOME $HOTFIX_PACKAGE \
    && cd $APPIAN_HOME \
    && ./deleteFiles.sh \
    && unzip -oqd $APPIAN_HOME $APPIAN_HOME/updates.zip \
    && rm /tmp/$HOTFIX_PACKAGE \
    && rm $APPIAN_HOME/deleteFiles.bat \
    && rm $APPIAN_HOME/deleteFiles.sh \
    && rm $APPIAN_HOME/updates.zip \
    && echo "Hotfix applied"; \
  fi \
  && echo "Creating image layer"

FROM centos:7

# environment variables
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk
ENV JDK_PACKAGE java-1.8.0-openjdk-devel
ENV APPIAN_HOME /usr/local/appian/ae
ENV CATALINA_HOME=${APPIAN_HOME}/tomcat/apache-tomcat
ENV PATH $JAVA_HOME/bin:$CATALINA_HOME/bin:$PATH
ENV READY_PORT 9355
ENV READY_TEXT ready

ARG APPIAN_USER_ID

# install required packages and add appian user
RUN yum -y install $JDK_PACKAGE unzip \
  && yum -y install nc \
  && yum -y install dos2unix \
  && yum -y install cronie \
  && yum clean all \
  && crond start \
  && rm -rf /var/cache/yum \
  && groupadd appian \
  && useradd -u ${APPIAN_USER_ID} -g appian appian

USER appian

COPY --from=installer-base --chown=appian $APPIAN_HOME $APPIAN_HOME
COPY --from=installer-base --chown=appian $CATALINA_HOME $CATALINA_HOME

WORKDIR $APPIAN_HOME

COPY --chown=appian dockerize.sh $APPIAN_HOME
RUN dos2unix $APPIAN_HOME/dockerize.sh && \
    chmod +x $APPIAN_HOME/dockerize.sh

HEALTHCHECK --interval=3s --timeout=2s --retries=300 \
  CMD ncat --recv-only localhost $READY_PORT | grep -q $READY_TEXT || exit 1

ENTRYPOINT [ "/usr/local/appian/ae/dockerize.sh" ]
