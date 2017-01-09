# Copyright (c) 2001-2011 Convertigo SA.
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

FROM ubuntu:16.04

MAINTAINER Nicolas Albert nicolasa@convertigo.com

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    bzip2 \
  && rm -rf /var/lib/apt/lists/* \
    /usr/share/man \
    /usr/share/doc

# grab gosu for easy step-down from root and tini for signal handling
RUN export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
  && curl -o /usr/local/bin/tini -fSL "https://github.com/krallin/tini/releases/download/v0.9.0/tini" \
  && curl -o /usr/local/bin/tini.asc -fSL "https://github.com/krallin/tini/releases/download/v0.9.0/tini.asc" \
  && gpg --verify /usr/local/bin/tini.asc \
  && rm /usr/local/bin/tini.asc \
  && chmod +x /usr/local/bin/tini \
  && rm -rf /tmp/*

ARG C8O_PROC
RUN if [ "${C8O_PROC}" = "32" ]; then \
    dpkg --add-architecture i386 && \
    apt-get update -y && apt-get install -y --no-install-recommends \    
      lib32z1 \
      libgtk2.0-0:i386 \
      libstdc++6:i386 \
      libxft2:i386 \
      libxt6:i386 \
      libxtst6:i386 \
    && rm -rf /var/lib/apt/lists/* \
      /usr/share/man \
      /usr/share/doc; \
  elif [ "${C8O_PROC}" = "64" ]; then \
    echo "64 bit version, skip 32 bit dependences"; \
  else echo "nor 32 bit or 64 bit, build failed"; exit 1; \
  fi

WORKDIR /tmp

ARG C8O_BASE_VERSION

RUN export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6A7779BB78FE368DF74B708FD4DA8FBEB64BF75F \
    && C8O_REVISION=`curl -sL -r 0-200 http://downloads.sourceforge.net/project/convertigo/${C8O_BASE_VERSION}/readme.txt | sed -nr "s/.*build ([0-9]+).*/\1/p"` \
    && curl -SL -o /tmp/convertigo.zip \
        http://downloads.sourceforge.net/project/convertigo/${C8O_BASE_VERSION}/convertigo-server-${C8O_BASE_VERSION}-v${C8O_REVISION}-linux${C8O_PROC}.run.zip \
    && curl -SL -o /tmp/convertigo.zip.asc \
        http://downloads.sourceforge.net/project/convertigo/${C8O_BASE_VERSION}/convertigo-server-${C8O_BASE_VERSION}-v${C8O_REVISION}-linux${C8O_PROC}.run.zip.asc \
    && gpg --batch --verify /tmp/convertigo.zip.asc /tmp/convertigo.zip \
    && unzip convertigo.zip \
    && chmod u+x *.run \
    && ./*.run -- -al -du -dp -nrc -ns \
    && (cd /opt/convertigoMobilityPlatform/tomcat/webapps && rm -rf * && mkdir ROOT convertigo) \
    && rm -rf /tmp/* \
    && ln -s /home/convertigoMobilityPlatform/convertigo /workspace
COPY ./root-index.html /opt/convertigoMobilityPlatform/tomcat/webapps/ROOT/index.html

ARG C8O_VERSION

RUN export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6A7779BB78FE368DF74B708FD4DA8FBEB64BF75F \
    && C8O_REVISION=`curl -sL -r 0-200 http://downloads.sourceforge.net/project/convertigo/${C8O_VERSION}/readme.txt | sed -nr "s/.*build ([0-9]+).*/\1/p"` \
    && curl -SL -o /tmp/convertigo.war \
        http://downloads.sourceforge.net/project/convertigo/${C8O_VERSION}/convertigo-${C8O_VERSION}-v${C8O_REVISION}-linux${C8O_PROC}.war \
    && curl -SL -o /tmp/convertigo.war.asc \
        http://downloads.sourceforge.net/project/convertigo/${C8O_VERSION}/convertigo-${C8O_VERSION}-v${C8O_REVISION}-linux${C8O_PROC}.war.asc \
    && gpg --batch --verify /tmp/convertigo.war.asc /tmp/convertigo.war \
    && (cd /opt/convertigoMobilityPlatform/tomcat/webapps/convertigo/ && unzip /tmp/convertigo.war && rm -rf templates) \
    && rm -rf /tmp/* \
    && if [ "${C8O_PROC}" = "64" ]; then \
         (cd /opt/convertigoMobilityPlatform/tomcat/webapps/convertigo/WEB-INF && rm -rf xulrunner xvnc); \
       else \
         chmod o+x /opt/convertigoMobilityPlatform/tomcat/webapps/convertigo/WEB-INF/xvnc/*; \
       fi

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh && echo "export C8O_BASE_VERSION=${C8O_BASE_VERSION} C8O_VERSION=${C8O_VERSION} C8O_PROC=${C8O_PROC}" >/c8o-env.sh

VOLUME ["/workspace"]
EXPOSE 28080

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["convertigo"]