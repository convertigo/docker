# Copyright (c) 2001-2017 Convertigo SA.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, see<http://www.gnu.org/licenses/>.

## from openjdk instead of tomcat because
## convertigo have an annoying bug with tomcat 7.0.43

FROM tomcat:7.0.82-jre8


MAINTAINER Nicolas Albert nicolasa@convertigo.com

ENV CATALINA_HOME /usr/local/tomcat
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
  && rm -rf /var/lib/apt/lists/*


## grab gosu for easy step-down from root and tini for signal handling

RUN export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
  && curl -o /usr/local/bin/tini -fSL "https://github.com/krallin/tini/releases/download/v0.16.1/tini-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/tini.asc -fSL "https://github.com/krallin/tini/releases/download/v0.16.1/tini-$(dpkg --print-architecture).asc" \
  && gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
  && rm /usr/local/bin/tini.asc \
  && chmod +x /usr/local/bin/tini \
  && rm -rf /tmp/*


## create a 'convertigo' user and fix some rights

RUN useradd -s /bin/false -m convertigo \
    && mkdir -p /workspace/lib /workspace/classes \
    && chown -R convertigo:convertigo /workspace

RUN sed -i.bak \
        -e '/protocol="AJP/d' \
        -e '/AprLifecycleListener/d' \
        -e '/JasperListener/d' \
        -e 's/port="8080"/port="28080" maxThreads="64000"/' \
        conf/server.xml \
    && rm -rf webapps/* bin/*.bat conf/server.xml.bak /tmp/* \
    && chown -R convertigo:convertigo conf temp work logs \
    && chmod -w conf/*


ENV CONVERTIGO_VERSION=7.4.7
ENV CONVERTIGO_REVISION=43946

ENV CONVERTIGO_WAR_URL https://devplatform.s3.amazonaws.com/refbin/cems/$CONVERTIGO_VERSION/convertigo-$CONVERTIGO_VERSION-v$CONVERTIGO_REVISION-linux64.war

ENV CONVERTIGO_GPG_KEYS 6A7779BB78FE368DF74B708FD4DA8FBEB64BF75F


## download and extract the convertigo webapps
## and remove unnecessary components for the mbaas version

RUN export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$CONVERTIGO_GPG_KEYS" \
    && curl -fSL -o /tmp/convertigo.war $CONVERTIGO_WAR_URL \
    && curl -fSL -o /tmp/convertigo.war.asc $CONVERTIGO_WAR_URL.asc \
    && gpg --batch --verify /tmp/convertigo.war.asc /tmp/convertigo.war \
    && mkdir webapps/ROOT webapps/convertigo \
    && (cd webapps/convertigo \
        && unzip -q /tmp/convertigo.war \
        && rm -rf WEB-INF/xulrunner WEB-INF/xvnc WEB-INF/lib/swt_* /tmp/*)


## copy the ROOT index that redirect to the 'convertigo' webapps

COPY ./web-connector/root-index.html webapps/ROOT/index.html
COPY ./web-connector/docker-entrypoint.sh /


WORKDIR /workspace
VOLUME ["/workspace"]
EXPOSE 28080

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["convertigo"]
