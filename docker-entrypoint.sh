#!/bin/sh

if [ "$1" = "convertigo" ]; then
    . /c8o-env.sh

    if [ "$(getent hosts couchdb)" != "" ];then
        export JAVA_OPTS="-Dconvertigo.engine.fullsync.couch.url=http://couchdb:5984 $JAVA_OPTS"
    fi
        
    mkdir -p /workspace/lib /workspace/classes
    cp -r /workspace/lib/* /opt/convertigoMobilityPlatform/tomcat/webapps/convertigo/WEB-INF/lib/ 2>/dev/null
    cp -r /workspace/classes/* /opt/convertigoMobilityPlatform/tomcat/webapps/convertigo/WEB-INF/classes/ 2>/dev/null
    
    ## Disable SSL and AJP connectors
    sed -i.bak -e '/port="28443/d' -e '/SSLEnabled/d' -e '/sslProtocol/d' -e '/28009/d' /opt/convertigoMobilityPlatform/tomcat/conf/server.xml
    
    export JAVA_HOME=/opt/convertigoMobilityPlatform/jre  
    export JAVA_OPTS="\
        -Xms128m \
        -Xmx2048m \
        -Xdebug \
        -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n \
        -Dconvertigo.cems.user_workspace_path=/workspace \
        -Dconvertigo.engine.application_server.convertigo.url=http://localhost:28080/convertigo \
        $JAVA_OPTS"
    
    if [ "$C8O_PROC" = "32" ]; then
        export DISPLAY=${DISPLAY:-:0}
        chmod o+x /opt/convertigoMobilityPlatform/tomcat/webapps/convertigo/WEB-INF/xvnc/*
    else
        unset DISPLAY
    fi
    
    exec gosu convertigoMobilityPlatform /opt/convertigoMobilityPlatform/tomcat/bin/catalina.sh run
fi

exec "$@"