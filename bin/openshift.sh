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
            serverIpAddr=`echo $var | cut -f2 -d\=`
            ;;
        -user=*)
            user=`echo $var | cut -f2 -d\=`
            ;;
        -password=*)
            password=`echo $var | cut -f2 -d\=`
            ;;
        -managementPort=*)
            port=`echo $var | cut -f2 -d\=`
            ;;
        -sshUrl=*)
            sshUrl=`echo $var | cut -f2 -d\=`
            ;;
        -file=*)
            file=`echo $var | cut -f2 -d\=`
            ;;
        -appName=*)
            apName=`echo $var | cut -f2 -d\=`
            ;;
        -localDir=*)
            localDir=`echo $var | cut -f2 -d\=`
            ;;
        -remoteDir=*)
            remoteDir=`echo $var | cut -f2 -d\=`
            ;;
    esac
done

#echo "localJbossHome = $localJbossHome";
#echo "serverIpAddr = $serverIpAddr";
#echo "port = $port";
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
    ./bin/jboss-cli.sh --connect --controller=$serverIpAddr:$port --command=:shutdown
    sleep 2
}

# Test remote host:port availability (TCP-only as UDP does not reply)
function checkRemotePort() {
    (echo >/dev/tcp/$serverIpAddr/$port) &>/dev/null
    if [ $? -eq 0 ]; then
        echo -en "\n$serverIpAddr:$port is open."
        socketIsOpen=0
    else
        echo -en "\n$serverIpAddr:$port is closed."
        socketIsOpen=1
    fi
}

function getRemoteFileSize() {
    fileSize=$(ssh $sshUrl "
        wc -c < $remoteDir/$file;
    ")
    echo -ne "remote file size of $file = $fileSize"
}


# what's the problem with using rsync 
# rsync -avz <deployments directory> <ssh-key of your application>@<application url>:~<application name>/repo/deployments
function copyFileToRemote() {
    getRemoteFileSize
    localFileSize=$(ls -nl $localDir/$file | awk '{print $5}')
    if [ $fileSize -eq $localFileSize ]; then
        echo -en "\nno need to copy $file"
    else
        echo -en "\nupdate to $file is needed.  local=$localFileSize : remote=$fileSize"
        ssh $sshUrl "
            cd $remoteDir;
            rm $file*;
        "
        scp $localDir/$file $sshUrl:$remoteDir
    fi
}

function createTunnel() {
    echo -en "\nattempting to create ssh tunnel"
    ssh -N -L $serverIpAddr:$port:$serverIpAddr:$port $sshUrl &
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

executeMysqlScript() {
    checkRemotePort
    if [ $socketIsOpen -ne 0 ]; then
        createTunnel
        checkRemotePort
        if [ $socketIsOpen -ne 0 ]; then
            echo -en "\n unable to create tunnel.  see previous errors"
            exit 1
        fi
    fi

    mysql -u$user -p$password -h$serverIpAddr < $file
}

executePostgresqlScript() {
    checkRemotePort
    if [ $socketIsOpen -ne 0 ]; then
        createTunnel
        checkRemotePort
        if [ $socketIsOpen -ne 0 ]; then
            echo -en "\n unable to create tunnel.  see previous errors"
            exit 1
        fi
    fi

    scp $localDir/$file $sshUrl:/$remoteDir
    ssh $sshUrl "
        createdb guvnor;
        createdb jbpm;
        createdb jbpm_bam;

        psql -d postgres -f $remoteDir/$file
    "
}

refreshGuvnor() {
    ssh $sshUrl "
        rm -rf $OPENSHIFT_DATA_DIR/guvnor;
        mkdir $OPENSHIFT_DATA_DIR/guvnor;
    "
    echo -en "\nabout to copy target/tmp/repository.xml to $sshUrl:$remoteDir"
    scp target/tmp/repository.xml $sshUrl:$remoteDir
}


case "$1" in
    startJboss|stopJboss|copyFileToRemote|executeMysqlScript|executePostgresqlScript|refreshGuvnor)
        $1
        ;;
    *)
    echo 1>&2 $"Usage: $0 {startJboss|stopJboss|copyFileToRemote|executeMysqlScript|executePostgresqlScript|refreshGuvnor}"
    exit 1
esac
