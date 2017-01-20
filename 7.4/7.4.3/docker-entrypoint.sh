#!/bin/sh

if [ "$1" = "convertigo" ]; then

    ## add the linked couchdb container as the fullsync couchdb
    
    if [ "$(getent hosts couchdb)" != "" ];then
        export JAVA_OPTS="-Dconvertigo.engine.fullsync.couch.url=http://couchdb:5984 $JAVA_OPTS"
    fi
    
    
    ## add custom jar or class to the convertigo server
    
    cp -r /workspace/lib/* $CATALINA_HOME/webapps/convertigo/WEB-INF/lib/ 2>/dev/null
    cp -r /workspace/classes/* $CATALINA_HOME/webapps/convertigo/WEB-INF/classes/ 2>/dev/null
    
    
    ## default common JAVA_OPTS, can be extended with "docker run -e JAVA_OPTS=-custom" 
    
    export JAVA_OPTS="\
        -Xms128m \
        -Xmx2048m \
        -Xdebug \
        -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n \
        -Dconvertigo.cems.user_workspace_path=/workspace \
        $JAVA_OPTS"
    
    
    ## the web-connector version need can use an existing DISPLAY or declare one
    ## the mbaas version need to be headless and remove the DISPLAY variable
    
    if [ -d $CATALINA_HOME/webapps/convertigo/WEB-INF/xvnc ]; then
        export DISPLAY=${DISPLAY:-:0}
    else
        unset DISPLAY
    fi
    
    exec gosu convertigo $CATALINA_HOME/bin/catalina.sh run
fi

exec "$@"