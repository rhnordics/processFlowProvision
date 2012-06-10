#!/bin/sh

export command=$1
export JBOSS_HOME=$2
export serverConfig=$3
export cliPort=$3
export jbossServerBaseDir=$4
export jbossSocketBindingPortOffset=$5

start() {
    echo -en $"Starting jboss daemon w/ following command line args: \n\tserver-config = $serverConfig\n\tjboss.server.base.dir = $jbossServerBaseDir \n\tjboss.socket.binding.port-offset = $jbossSocketBindingPortOffset \n\t"
    cd $JBOSS_HOME
    if [ "$jbossServerBaseDir" = "standalone" ]; then
        #  defining jboss.server.base.dir causes problems when deploying SOAP service on AS7.1.1    :   http://pastebin.com/qyX1crrT 
        #  "standalone" server will be reserved for core functionality that needs SOAP
        echo -en $"\nwill start standalone server base dir\n"
        nohup ./bin/standalone.sh -b=$HOSTNAME -bmanagement=$HOSTNAME --server-config=$serverConfig -Djboss.socket.binding.port-offset=$jbossSocketBindingPortOffset &
    else
        nohup ./bin/standalone.sh -b=$HOSTNAME -bmanagement=$HOSTNAME --server-config=$serverConfig -Djboss.server.base.dir=$jbossServerBaseDir -Djboss.socket.binding.port-offset=$jbossSocketBindingPortOffset &
    fi
   
     sleep 10 
}

stop() {
    echo -en $"stopping jboss daemon: \n"
    ./bin/jboss-cli.sh --connect --controller=$HOSTNAME:$cliPort --command=:shutdown
    echo
    rm nohup.out
    sleep 2
}

restart() {
    stop
    start
}

case "$1" in
    start|stop|restart)
        cd $JBOSS_HOME
        chmod 755 bin/*.sh
        $1
        ;;
    *)
    echo 1>&2 $"Usage: $0 {start|stop|restart}"
    exit 1
esac
