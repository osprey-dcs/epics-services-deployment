#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

# figure out the path to the product jar
if [[ -z "${PHOEBUS_ALARM_CONFIG_LOGGER_JAR}" ]]; then
  PHOEBUS_ALARM_CONFIG_LOGGER_JAR=service-alarm-config-logger-4.7.4.jar
fi

JDK_JAVA_OPTIONS=" -DCA_DISABLE_REPEATER=true"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS -Dnashorn.args=--no-deprecation-warning"
JDK_JAVA_OPTIONS="$JDK_JAVA_OPTIONS -Dlogback.configurationFile=/opt/css/nsls2-phoebus/config/logback.xml"
export JDK_JAVA_OPTIONS

echo $JDK_JAVA_OPTIONS

java -jar ${PHOEBUS_ALARM_CONFIG_LOGGER_JAR} "$@"
