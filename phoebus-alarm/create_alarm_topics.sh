#!/bin/sh

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

if [ $# -ne 1 ]
then
    echo "Usage: create_alarm_topics.sh nasa_epics_alarm"
    exit 1
fi

config=$1

# Create the compacted topics.
for topic in "$1"
do
    /opt/epics-tools/services/nasa/kafka/kafka_2.13-3.9.0/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --replication-factor 1 --partitions 1 --topic $topic
    /opt/epics-tools/services/nasa/kafka/kafka_2.13-3.9.0/bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --alter --entity-name $topic \
           --add-config cleanup.policy=compact,segment.ms=10000,min.cleanable.dirty.ratio=0.01,min.compaction.lag.ms=1000
done

# Create the deleted topics
for topic in "${1}Command" "${1}Talk"
do
    /opt/epics-tools/services/nasa/kafka/kafka_2.13-3.9.0/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --replication-factor 1 --partitions 1 --topic $topic
    /opt/epics-tools/services/nasa/kafka/kafka_2.13-3.9.0/bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --alter --entity-name $topic \
           --add-config cleanup.policy=delete,segment.ms=10000,min.cleanable.dirty.ratio=0.01,min.compaction.lag.ms=1000,retention.ms=20000,delete.retention.ms=1000,file.delete.delay.ms=1000
done
