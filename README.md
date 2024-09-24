# epics-services-deployment
A general guide to deploying EPICS services

---

### EPICS Services Installation

#### Core Dependencies

```bash
sudo apt update && sudo apt upgrade
sudo apt install openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
sudo apt install git
sudo apt install maven
```

#### Create Services Account

```bash
adduser epics_services_nasa
usermod -aG sudo epics_services_nasa
```

---

### ElasticSearch 8.2

- **Installation Guide**: [ElasticSearch 8.2](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html)

#### Download and Extract ElasticSearch 8.2

```bash
cd /tmp
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.3-linux-x86_64.tar.gz
mkdir -p /opt/epics-tools/services/nasa/elastic/
cd /opt/epics-tools/services/nasa/elastic
tar -xvf /tmp/elasticsearch-8.2.3-linux-x86_64.tar.gz
```

#### Configuration

- Copy `elasticsearch.yml` to `/opt/epics-tools/services/nasa/elastic/elasticsearch-8.2.3/config`

#### Set Up ElasticSearch as a Service

- Copy `elastic.service` to `/etc/systemd/system/`

```bash
systemctl enable elastic.service
systemctl restart elastic.service
```

---

### MongoDB 7.0

- **Installation Guide**: [MongoDB on Debian 12](https://www.mongodb.com/community/forums/t/mongo-6-x-on-debian-12/232593)

#### Install MongoDB 7.0

```bash
sudo apt-get install gnupg curl
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
```

- Change the data location in `/etc/mongod.conf` (ensure MongoDB user has write permissions).

#### Start and Enable MongoDB

```bash
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl enable mongod
```

---

### Kafka 3.6.2

- **Installation Guide**: [Kafka Documentation](https://kafka.apache.org/22/documentation.html)

#### Download and Extract Kafka

```bash
cd /tmp
wget https://downloads.apache.org/kafka/3.6.2/kafka_2.13-3.6.2.tgz
mkdir -p /opt/epics-tools/services/nasa/kafka
cd /opt/epics-tools/services/nasa/kafka
tar -xvf /tmp/kafka_2.13-3.6.2.tgz
```

#### Optional Configuration

- Configure Zookeeper and Kafka ports, and set up the data folder in `kafka/config/`.

#### Set Up Kafka and Zookeeper Services

- Copy `zookeeper.service` and `kafka.service` to `/etc/systemd/system/`.

```bash
systemctl enable zookeeper
systemctl enable kafka
systemctl start zookeeper
systemctl start kafka
```

---

### Phoebus Installation

```bash
cd /tmp/
git clone https://github.com/ControlSystemStudio/phoebus.git
cd phoebus/
mvn clean install -DskipTests
```

---

### Alarm Services

- **Alarm Server**: [Alarm Server](https://github.com/ControlSystemStudio/phoebus/tree/master/services/alarm-server)
- **Alarm Logger**: [Alarm Logger](https://github.com/ControlSystemStudio/phoebus/tree/master/services/alarm-logger)
- **Alarm Config Logger**: [Alarm Config Logger](https://github.com/ControlSystemStudio/phoebus/tree/master/services/alarm-config-logger)

#### Setup Alarm Preferences

- Copy `phoebus_alarm_preferences.ini` to `/opt/epics-tools/services/nasa/phoebus-alarms`.

#### Install Alarm Server

```bash
mkdir -p /opt/epics-tools/services/nasa/phoebus-alarms
cp -rf /tmp/phoebus/services/alarm-server/target/service-alarm-server-4.7.4-SNAPSHOT-bin.tar.gz /opt/epics-tools/services/nasa/phoebus-alarms/
cd /opt/epics-tools/services/nasa/phoebus-alarms
tar -xvf service-alarm-server-4.7.4-SNAPSHOT-bin.tar.gz
```

- Copy `run-phoebus-alarm.sh` to `/opt/epics-tools/services/nasa/phoebus-alarms/`.

#### Enable and Start Alarm Services

```bash
systemctl enable phoebus_alarm
systemctl start phoebus_alarm
```

#### Setup Alarm Logger

```bash
mkdir /opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger
cp -rf /tmp/phoebus/services/alarm-logger/target/service-alarm-logger-4.7.4-SNAPSHOT.jar /opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger/
```

- Copy the logger properties and `run-phoebus-alarm-logger.sh` to `/opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger/`.

---

### Phoebus Olog

- **Installation Guide**: [Phoebus Olog](https://github.com/Olog/phoebus-olog?tab=readme-ov-file#installation)

#### Download and Install

```bash
cd /tmp/
git clone https://github.com/Olog/phoebus-olog.git
cd phoebus-olog/
mvn clean install -Pdeployable-jar -DskipTests
mkdir -p /opt/epics-tools/services/nasa/olog
cp -rf /tmp/phoebus-olog/target/service-olog-5.0.0-SNAPSHOT.jar /opt/epics-tools/services/nasa/olog/
```

#### Enable and Start Olog Service

```bash
systemctl enable phoebus_olog
systemctl start phoebus_olog
```

---

### Archiver Appliance

#### Install MySQL 5.7 and Set Up Database

```bash
mysql --user=root --password=*****
CREATE DATABASE archappl;
CREATE USER archappl IDENTIFIED BY '******';
GRANT ALL ON archappl.* TO 'archappl'@'%' WITH GRANT OPTION;
```

#### Install Archiver Appliance

```bash
cd /tmp/
git clone https://github.com/slacmshankar/epicsarchiverap.git
cd epicsarchiverap
./gradlew
```

- Copy binaries and connectors to `/opt/epics-tools/services/nasa/aa/deploy/`.

#### Run Installation Scripts

```bash
cd /opt/epics-tools/services/nasa/aa/deploy/install_scripts
./single_machine_install.sh
```

- Setup services using `aa.service` template and fix HTML pages.

---

### ChannelFinder

- **Installation Guide**: [ChannelFinder Service](https://github.com/ChannelFinder/ChannelFinderService)

#### Install ChannelFinder

```bash
cd /tmp/
git clone https://github.com/ChannelFinder/ChannelFinderService.git
cd ChannelFinderService
mvn clean install -DskipTests
mkdir -p /opt/epics-tools/services/nasa/cf
cp -rf /tmp/ChannelFinderService/target/ChannelFinder-4.7.3-SNAPSHOT.jar /opt/epics-tools/services/nasa/cf/
```

#### Enable and Start ChannelFinder Service

```bash
systemctl enable cf
systemctl start cf
```

---

### Save/Restore

```bash
mkdir -p /opt/epics-tools/services/nasa/save_restore
cp /tmp/phoebus/services/save-and-restore/target/service-save-and-restore-4.7.4-SNAPSHOT.jar /opt/epics-tools/services/nasa/save_restore/
```

- Setup services using `save_restore.service` as a template.

#### Enable and Start Save/Restore Service

```bash
systemctl enable save_restore
systemctl start save_restore
``` 

---
