FROM openjdk:8u181

RUN apt-get update \
  && apt-get install -y tree \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && useradd -ms /bin/bash orbeon


ENV ORBEON_HOME=/orbeon
ENV CATALINA_HOME=$ORBEON_HOME/apache-tomcat-8.5.35
ENV PATH=$CATALINA_HOME/bin:$PATH
ENV GOSU_VERSION 1.10
ENV GOSU_URL=https://github.com/tianon/gosu/releases/download/$GOSU_VERSION


COPY ./installers/ /tmp/

WORKDIR $ORBEON_HOME
RUN mkdir -p "$ORBEON_HOME" \
	&& set -x \
	&& tar -xvf /tmp/apache-tomcat-8.5.35.tar.gz -C $ORBEON_HOME \
	&& unzip /tmp/orbeon-2018.1.1.201809181825-CE.zip -d /tmp/ \
	&& mv /tmp/orbeon-2018.1.1.201809181825-CE/orbeon.war $CATALINA_HOME/webapps \
	&& rm /tmp/apache-tomcat-8.5.35.tar.gz \
	&& rm /tmp/orbeon-2018.1.1.201809181825-CE.zip \
	&& rm -rf /tmp/orbeon-2018.1.1.201809181825-CE \
	&& chown -R orbeon:orbeon $ORBEON_HOME

RUN wget -O /usr/local/bin/gosu "$GOSU_URL/gosu-$(dpkg --print-architecture)" \
	  && wget -O /usr/local/bin/gosu.asc "$GOSU_URL/gosu-$(dpkg --print-architecture).asc" \
	  && export GNUPGHOME="$(mktemp -d)"

RUN rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc
RUN chmod +x /usr/local/bin/gosu
RUN gosu nobody true


EXPOSE 8080/tcp

VOLUME /storage

CMD ["catalina.sh", "run"]