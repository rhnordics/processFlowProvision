#!/bin/sh

export command=$1
export serverConfig=$2
export cliPort=$2
export jbossServerBaseDir=$3
export jbossSocketBindingPortOffset=$4

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
    echo -en $"stopping jboss daemon: "
    cd $JBOSS_HOME
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
        $1
        ;;
    *)
    echo 1>&2 $"Usage: $0 {start|stop|restart}"
    exit 1
esac
