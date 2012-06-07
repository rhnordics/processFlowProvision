#!/bin/sh

export command=$1
export serverConfig=$2
export cliPort=$2
export jbossServerBaseDir=$3
export jbossSocketBindingPortOffset=$4

start() {
    echo -en $"Starting jboss daemon w/ following command line args: \n\tserver-config = $serverConfig\n\tjboss.server.base.dir = $jbossServerBaseDir \n\tjboss.socket.binding.port-offset = $jbossSocketBindingPortOffset \n\t"
     cd $JBOSS_HOME
    nohup ./bin/standalone.sh -b=$HOSTNAME -bmanagement=$HOSTNAME --server-config=$serverConfig -Djboss.server.base.dir=$jbossServerBaseDir -Djboss.socket.binding.port-offset=$jbossSocketBindingPortOffset &
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
