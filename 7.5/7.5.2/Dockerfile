# Copyright (c) 2001-2018 Convertigo SA.
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
## convertigo have an annoying bug with tomcat 7.0.88
FROM openjdk:8-jre


MAINTAINER Nicolas Albert nicolasa@convertigo.com

ENV CATALINA_HOME /usr/local/tomcat
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dirmngr \
    gnupg \
    unzip \
  && rm -rf /var/lib/apt/lists/*


## grab gosu for easy step-down from root and tini for signal handling
ENV GOSU_VERSION 1.10
ENV GOSU_GPG_KEYS B42F6819007F00F88E364FD4036A9C25BF357DD4
ENV TINI_VERSION 0.16.1
ENV TINI_GPG_KEYS 6380DC428747F6C393FEACA59A84159D7001A4E5

RUN export GNUPGHOME="$(mktemp -d)" \
  && ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GOSU_GPG_KEYS" \
  || gpg --keyserver pgp.mit.edu --recv-keys "$GOSU_GPG_KEYS" \
  || gpg --keyserver keyserver.ubuntu.com --recv-keys "$GOSU_GPG_KEYS" \
  || gpg --keyserver keyserver.pgp.com --recv-keys "$GOSU_GPG_KEYS" ) \
  && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc" \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$TINI_GPG_KEYS" \
  || gpg --keyserver pgp.mit.edu --recv-keys "$TINI_GPG_KEYS" \
  || gpg --keyserver keyserver.ubuntu.com --recv-keys "$TINI_GPG_KEYS" \
  || gpg --keyserver keyserver.pgp.com --recv-keys "$TINI_GPG_KEYS" ) \
  && curl -o /usr/local/bin/tini -fSL "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/tini.asc -fSL "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-$(dpkg --print-architecture).asc" \
  && gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
  && rm /usr/local/bin/tini.asc \
  && chmod +x /usr/local/bin/tini \
  && rm -rf /tmp/*


## download tomcat 7.0.86 because the 7.0.88 cause an annoying bug
ENV TOMCAT_MAJOR=7
ENV TOMCAT_VERSION=7.0.86

ENV TOMCAT_TGZ_URL https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

ENV TOMCAT_GPG_KEYS 05AB33110949707C93A279E3D3EFE6B686867BA6 07E48665A34DCAFAE522E5E6266191C37C037D42 47309207D818FFD8DCD3F83F1931D684307A10A5 541FBE7D8F78B25E055DDEE13C370389288584E7 61B832AC2F1C5A90F0F9B00A1C506407564C17A3 713DA88BE50911535FE716F5208B0AB1D63011C7 79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED 9BA44C2621385CB966EBA586F72C284D731FABEE A27677289986DB50844682F8ACB77FC2E86E29AC A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23
RUN export GNUPGHOME="$(mktemp -d)" \
    && for key in $TOMCAT_GPG_KEYS; do \
         gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
       done; \
    curl -fSL -o /tmp/tomcat.tar.gz $TOMCAT_TGZ_URL \
    && curl -fSL -o /tmp/tomcat.tar.gz.asc $TOMCAT_TGZ_URL.asc \
    && gpg --batch --verify /tmp/tomcat.tar.gz.asc /tmp/tomcat.tar.gz \
    && tar -xvf /tmp/tomcat.tar.gz --strip-components=1

## create a 'convertigo' user and fix some rights

RUN useradd -s /bin/false -m convertigo \
    && mkdir -p /workspace/lib /workspace/classes \
    && chown -R convertigo:convertigo /workspace


## disable unused AJP, APR and Jasper features
## change HTTP port the historic Convertigo port 28080

RUN sed -i.bak \
        -e '/protocol="AJP/d' \
        -e '/AprLifecycleListener/d' \
        -e '/JasperListener/d' \
        -e 's/port="8080"/port="28080" maxThreads="64000"/' \
        conf/server.xml \
    && rm -rf webapps/* bin/*.bat conf/server.xml.bak /tmp/* \
    && chown -R convertigo:convertigo conf temp work logs \
    && chmod -w conf/*


ENV CONVERTIGO_VERSION 7.5.2
ENV CONVERTIGO_REVISION 44730

ENV CONVERTIGO_WAR_URL https://devplatform.s3.amazonaws.com/refbin/cems/$CONVERTIGO_VERSION/convertigo-$CONVERTIGO_VERSION-v$CONVERTIGO_REVISION-linux32.war

ENV CONVERTIGO_GPG_KEYS 6A7779BB78FE368DF74B708FD4DA8FBEB64BF75F


## download and extract the convertigo webapps
## and remove unnecessary components for the mbaas version

RUN export GNUPGHOME="$(mktemp -d)" \
    && ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$CONVERTIGO_GPG_KEYS" \
    || gpg --keyserver pgp.mit.edu --recv-keys "$CONVERTIGO_GPG_KEYS" \
    || gpg --keyserver keyserver.ubuntu.com --recv-keys "$CONVERTIGO_GPG_KEYS" \
    || gpg --keyserver keyserver.pgp.com --recv-keys "$CONVERTIGO_GPG_KEYS" ) \
    && curl -fSL -o /tmp/convertigo.war $CONVERTIGO_WAR_URL \
    && curl -fSL -o /tmp/convertigo.war.asc $CONVERTIGO_WAR_URL.asc \
    && gpg --batch --verify /tmp/convertigo.war.asc /tmp/convertigo.war \
    && mkdir webapps/ROOT webapps/convertigo \
    && (cd webapps/convertigo \
        && unzip -q /tmp/convertigo.war \
        && chmod a+x WEB-INF/xvnc/* \
        && (test "$(dpkg --print-architecture)" != "i386" && rm -rf WEB-INF/xulrunner WEB-INF/xvnc WEB-INF/lib/swt_* || true) \
        && rm -rf /tmp/*)


## copy the ROOT index that redirect to the 'convertigo' webapps

COPY ./alpine/root-index.html webapps/ROOT/index.html
COPY ./alpine/docker-entrypoint.sh /

## force SWT to use GTK2 instead of GTK3 (no Xulrunner support)

ENV SWT_GTK3 0

WORKDIR /workspace
VOLUME ["/workspace"]
EXPOSE 28080

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["convertigo"]