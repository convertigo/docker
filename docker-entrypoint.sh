#!/bin/sh

if [ "$1" = "convertigo" ]; then    
    if [ "$(getent hosts couchdb)" != "" ];then
        export JAVA_OPTS="-Dconvertigo.engine.fullsync.couch.url=http://couchdb:5984 $JAVA_OPTS"
    fi
    
    cp -r /workspace/lib/* $CATALINA_HOME/webapps/convertigo/WEB-INF/lib/ 2>/dev/null
    cp -r /workspace/classes/* $CATALINA_HOME/webapps/convertigo/WEB-INF/classes/ 2>/dev/null
    
    export JAVA_OPTS="\
        -Xms128m \
        -Xmx2048m \
        -Xdebug \
        -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n \
        -Dconvertigo.cems.user_workspace_path=/workspace \
        $JAVA_OPTS"
    
    if [ -d $CATALINA_HOME/webapps/convertigo/WEB-INF/xvnc ]; then
        export DISPLAY=${DISPLAY:-:0}
    else
        unset DISPLAY
    fi
    
    exec gosu convertigo $CATALINA_HOME/bin/catalina.sh run
fi

exec "$@"