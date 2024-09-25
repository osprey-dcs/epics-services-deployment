#!/bin/bash

# Sample startup script for the archiver appliance
# Please change the various environment variables to suit your environment.

# We assume that we inherit the EPICS environment variables from something that calls this script
# However, if this is a init.d startup script, this is not going to be the case and we'll need to add them here.
# This includes setting up the LD_LIBRARY_PATH to include the JCA .so file.
###
#source /opt/local/setEPICSEnv.sh
export EPICS_CA_AUTO_ADDR_LIST=no
export EPICS_CA_ADDR_LIST=192.168.83.255
export EPICS_CA_MAX_ARRAY_BYTES=1100000
###

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH=${JAVA_HOME}/bin:${PATH}

# We use a lot of memory; so be generous with the heap.
export JAVA_OPTS_ENGINE="-XX:+UseG1GC -Xmx10G -Xms4G -ea"
export JAVA_OPTS_RETRIEVAL="-XX:+UseG1GC -Xmx10G -Xms4G -ea"
export JAVA_OPTS_ETL="-XX:+UseG1GC -Xmx5G -Xms1G -ea"
export JAVA_OPTS_MGMT="-XX:+UseG1GC -Xmx5G -Xms1G -ea"

# Set up Tomcat home
export TOMCAT_HOME="/opt/epics-tools/services/nasa/aa/deploy/apache-tomcat-9.0.31"

# Set up the root folder of the individual Tomcat instances.
export ARCHAPPL_DEPLOY_DIR="/opt/epics-tools/services/nasa/aa/deploy"

# Set appliance.xml and the identity of this appliance
export ARCHAPPL_APPLIANCES="/opt/epics-tools/services/nasa/aa/deploy/appliances.xml"
export ARCHAPPL_MYIDENTITY="appliance0"

# If you have your own policies file, please change this line.
#export ARCHAPPL_POLICIES="{{ aa_install_location }}/conf/policies.py"

# Set the location of short term and long term stores; this is necessary only if your policy demands it
###
export ARCHAPPL_SHORT_TERM_FOLDER="/arch/sts/ArchiverStore"
export ARCHAPPL_MEDIUM_TERM_FOLDER="/arch/mts/ArchiverStore"
export ARCHAPPL_LONG_TERM_FOLDER="/arch/lts/ArchiverStore"
###

if [[ ! -d ${TOMCAT_HOME} ]]
then
    echo "Unable to determine the source of the tomcat distribution"
    exit 1
fi

if [[ ! -f ${ARCHAPPL_APPLIANCES} ]]
then
    echo "Unable to find appliances.xml at ${ARCHAPPL_APPLIANCES}"
    exit 1
fi

# Enable core dumps in case the JVM fails
###
#ulimit -c unlimited
###

function startTomcatAtLocation() {
    if [ -z "$1" ]; then echo "startTomcatAtLocation called without CATALINA_BASE argument"; exit 1; fi
    if [ -z "$2" ]; then echo "startTomcatAtLocation called without JAVA_OPTS argument"; exit 1; fi
    export CATALINA_HOME=$TOMCAT_HOME
    export CATALINA_BASE=$1
    export JAVA_OPTS=$2
    echo "Starting tomcat at location ${CATALINA_BASE}"

    ARCH=`uname -m`
    if [[ $ARCH == 'x86_64' || $ARCH == 'amd64' ]]
    then
      echo "Using 64 bit versions of libraries"
      export LD_LIBRARY_PATH=${CATALINA_BASE}/webapps/engine/WEB-INF/lib/native/linux-x86_64:${LD_LIBRARY_PATH}
    else
      echo "Using 32 bit versions of libraries"
      export LD_LIBRARY_PATH=${CATALINA_BASE}/webapps/engine/WEB-INF/lib/native/linux-x86:${LD_LIBRARY_PATH}
    fi

    pushd ${CATALINA_BASE}/logs
    ${CATALINA_HOME}/bin/jsvc \
        -server \
        -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar \
        ${JAVA_OPTS} \
        -Dcatalina.base=${CATALINA_BASE} \
        -Dcatalina.home=${CATALINA_HOME} \
        -cwd ${CATALINA_BASE}/logs \
        -outfile ${CATALINA_BASE}/logs/catalina.out \
        -errfile ${CATALINA_BASE}/logs/catalina.err \
        -pidfile ${CATALINA_BASE}/pid \
        org.apache.catalina.startup.Bootstrap start
     popd
}

function stopTomcatAtLocation() {
    if [ -z "$1" ]; then echo "stopTomcatAtLocation called without CATALINA_BASE argument"; exit 1; fi
    if [ -z "$2" ]; then echo "startTomcatAtLocation called without JAVA_OPTS argument"; exit 1; fi
    export CATALINA_HOME=$TOMCAT_HOME
    export CATALINA_BASE=$1
    export JAVA_OPTS=$2
    echo "Stopping tomcat at location ${CATALINA_BASE}"
    pushd ${CATALINA_BASE}/logs
    ${CATALINA_HOME}/bin/jsvc \
        -server \
        -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar \
        ${JAVA_OPTS} \
        -Dcatalina.base=${CATALINA_BASE} \
        -Dcatalina.home=${CATALINA_HOME} \
        -cwd ${CATALINA_BASE}/logs \
        -outfile ${CATALINA_BASE}/logs/catalina.out \
        -errfile ${CATALINA_BASE}/logs/catalina.err \
        -pidfile ${CATALINA_BASE}/pid \
        -stop \
        org.apache.catalina.startup.Bootstrap
     popd
}

function stop() {
	stopTomcatAtLocation ${ARCHAPPL_DEPLOY_DIR}/engine $JAVA_OPTS_ENGINE
	stopTomcatAtLocation ${ARCHAPPL_DEPLOY_DIR}/retrieval $JAVA_OPTS_RETRIEVAL
	stopTomcatAtLocation ${ARCHAPPL_DEPLOY_DIR}/etl $JAVA_OPTS_ETL
	stopTomcatAtLocation ${ARCHAPPL_DEPLOY_DIR}/mgmt $JAVA_OPTS_MGMT
}

function start() {
	startTomcatAtLocation ${ARCHAPPL_DEPLOY_DIR}/mgmt $JAVA_OPTS_MGMT
	startTomcatAtLocation ${ARCHAPPL_DEPLOY_DIR}/engine $JAVA_OPTS_ENGINE
	startTomcatAtLocation ${ARCHAPPL_DEPLOY_DIR}/etl $JAVA_OPTS_ETL
	startTomcatAtLocation ${ARCHAPPL_DEPLOY_DIR}/retrieval $JAVA_OPTS_RETRIEVAL
}


# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  restart)
	stop
	start
	;;
  *)
	echo $"Usage: $0 {start|stop|restart}"
	exit 2
esac
