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

FROM tomcat:7-jre8


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


ENV CONVERTIGO_VERSION 7.5.0
ENV CONVERTIGO_REVISION 44235

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