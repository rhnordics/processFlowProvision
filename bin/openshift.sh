#!/bin/sh

command=$1
socketIsOpen=2
remoteJbossHome=jbossas-7/jbossas-7
fileSize=0

for var in $@
do
    case $var in
        -localJbossHome=*)
            localJbossHome=`echo $var | cut -f2 -d\=`
            ;;
        -serverIpAddr=*)
            hostName=`echo $var | cut -f2 -d\=`
            ;;
        -managementPort=*)
            cliPort=`echo $var | cut -f2 -d\=`
            ;;
        -sshUrl=*)
            sshUrl=`echo $var | cut -f2 -d\=`
            ;;
        -fileToCopy=*)
            fileToCopy=`echo $var | cut -f2 -d\=`
            ;;
    esac
done

#echo "localJbossHome = $localJbossHome";
#echo "hostName = $hostName";
#echo "cliPort = $cliPort";
#echo "sshUrl = $sshUrl";

stopJboss() {
    checkRemotePort
    if [ $socketIsOpen -ne 0 ]; then
        createTunnel
        checkRemotePort
        if [ $socketIsOpen -ne 0 ]; then
            echo -en "\n unable to create tunnel.  see previous errors"
            exit 1
        fi
    fi

    echo -en $"\nstopping jboss daemon using script at: $localJbossHome/bin/jboss-cli.sh \n"
    cd $localJbossHome
    ./bin/jboss-cli.sh --connect --controller=$hostName:$cliPort --command=:shutdown
    sleep 2
}

# Test remote host:port availability (TCP-only as UDP does not reply)
function checkRemotePort() {
    (echo >/dev/tcp/$hostName/$cliPort) &>/dev/null
    if [ $? -eq 0 ]; then
        echo -en "\n$hostName:$cliPort is open."
        socketIsOpen=0
    else
        echo -en "\n$hostName:$cliPort is closed."
        socketIsOpen=1
    fi
}

#$1 = relative path (from ~/app-root directory) to remote file
function getRemoteFileSize() {
    ssh $sshUrl "
        mkdir -p app-root/target/tmp
        fileSize=$(ls -nl app-root/$1 | awk '{print $5}')
    "
    echo -ne "remote file size of $1 = $fileSize"
}

function copyArchiveToRemote() {
    getRemoteFileSize fileToCopy
    localFileSize=$(ls -nl $fileToCopy | awk '{print $5}')
    if [ $fileSize -eq $localFileSize ]; then
        echo -en "\nno need to copy $fileToCopy"
    else
        echo -en "\nupdate to $fileToCopy is needed.  local=$localFileSize : remote=$fileSize"
    fi
}

function createTunnel() {
    echo -en "\nattempting to create ssh tunnel"
    ssh -N -L $hostName:$cliPort:$hostName:$cliPort $sshUrl &
    #echo -en "createTunnel() response = $? "
    sleep 5
}

startJboss() {
    echo -en "\nattempting to start jboss using sshUrl = $sshUrl"
    ssh $sshUrl "
        cd $remoteJbossHome;
        rm standalone/log/server.log;
        ./bin/standalone.sh 1>standalone/log/stdio.log 2>&1 &
    "
    sleep 25;
    ssh $sshUrl "
        cd $remoteJbossHome;
        cat standalone/log/server.log
    "
}


case "$1" in
    startJboss|stopJboss|copyArchiveToRemote)
        $1
        ;;
    *)
    echo 1>&2 $"Usage: $0 {startJboss|stopJboss|copyArchiveToRemote}"
    exit 1
esac
