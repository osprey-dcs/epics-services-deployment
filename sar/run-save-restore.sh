#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

# figure out the path to the product jar
if [[ -z "${SAVE_RESTORE_JAR}" ]]; then
  SAVE_RESTORE_JAR=service-save-and-restore-4.7.4-SNAPSHOT.jar
fi

JDK_JAVA_OPTIONS=" -DCA_DISABLE_REPEATER=true"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS -Dnashorn.args=--no-deprecation-warning"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS -Djdk.gtk.verbose=false -Djdk.gtk.version=2 -Dprism.forceGPU=true"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS -Dorg.csstudio.javafx.rtplot.update_counter=false"
export JDK_JAVA_OPTIONS

echo $JDK_JAVA_OPTIONS

java -Dspring.config.location=/opt/epics-tools/services/nasa/save_restore/save_restore.properties -jar ${SAVE_RESTORE_JAR}
