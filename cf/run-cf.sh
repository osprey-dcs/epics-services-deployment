#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

# figure out the path to the product jar
if [[ -z "${CF_JAR}" ]]; then
  CF_JAR=/opt/epics-tools/services/nasa/cf/ChannelFinder-4.7.3.jar
fi

JDK_JAVA_OPTIONS=" -DCA_DISABLE_REPEATER=true"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS -Dnashorn.args=--no-deprecation-warning"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS -Djdk.gtk.verbose=false -Djdk.gtk.version=2 -Dprism.forceGPU=true"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS -Dlogback.configurationFile=/opt/css/nsls2-phoebus/config/logback.xml"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS -Dorg.csstudio.javafx.rtplot.update_counter=false"
export JDK_JAVA_OPTIONS

echo $JDK_JAVA_OPTIONS

java -Dspring.config.location=/opt/epics-tools/services/nasa/cf/cf.properties -jar ${CF_JAR}
