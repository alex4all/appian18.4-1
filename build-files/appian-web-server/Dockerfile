FROM httpd:2.4.32

EXPOSE 8009

RUN apt-get update \
  && apt-get -y install curl \
  && apt-get -y install gcc \
  && apt-get -y install make \
  && apt-get -y install vim \
  && curl -O http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.40-src.tar.gz \
  && tar -xzvf tomcat-connectors-1.2.40-src.tar.gz \
  && cd tomcat-connectors-1.2.40-src/native \
  && ./configure --with-apxs=$(which apxs) \
  && make \
  && cp apache-2.0/mod_jk.so /usr/local/apache2/modules/
