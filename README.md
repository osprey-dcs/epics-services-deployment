# epics-services-deployment
A general guide to deploying EPICS services

---

### EPICS Services Installation

#### Core Dependencies

```
sudo apt update && sudo apt upgrade
sudo apt install openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
sudo apt install git
sudo apt install maven
```

#### Create Services Account

```
adduser epics_services_nasa
usermod -aG sudo epics_services_nasa
```

---

### ElasticSearch 8.2

- **Installation Guide**: [ElasticSearch 8.2](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html)

#### Download and Extract ElasticSearch 8.2

```
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

```
systemctl enable elastic.service
systemctl restart elastic.service
```

---

### MongoDB 7.0

- **Installation Guide**: [MongoDB on Debian 12](https://www.mongodb.com/community/forums/t/mongo-6-x-on-debian-12/232593)

#### Install MongoDB 7.0

```
sudo apt-get install gnupg curl
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
```

- Change the data location in `/etc/mongod.conf` (ensure MongoDB user has write permissions).

#### Start and Enable MongoDB

```
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl enable mongod
```

---

### Kafka 3.6.2

- **Installation Guide**: [Kafka Documentation](https://kafka.apache.org/22/documentation.html)

#### Download and Extract Kafka

```
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

```
systemctl enable zookeeper
systemctl enable kafka
systemctl start zookeeper
systemctl start kafka
```

---

### Phoebus Installation

```
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

```
mkdir -p /opt/epics-tools/services/nasa/phoebus-alarms
cp -rf /tmp/phoebus/services/alarm-server/target/service-alarm-server-4.7.4-SNAPSHOT-bin.tar.gz /opt/epics-tools/services/nasa/phoebus-alarms/
cd /opt/epics-tools/services/nasa/phoebus-alarms
tar -xvf service-alarm-server-4.7.4-SNAPSHOT-bin.tar.gz
```

- Copy `run-phoebus-alarm.sh` to `/opt/epics-tools/services/nasa/phoebus-alarms/`.

#### Enable and Start Alarm Services

```
systemctl enable phoebus_alarm
systemctl start phoebus_alarm
```

#### Setup Alarm Logger

```
mkdir /opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger
cp -rf /tmp/phoebus/services/alarm-logger/target/service-alarm-logger-4.7.4-SNAPSHOT.jar /opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger/
```

- Copy the logger properties and `run-phoebus-alarm-logger.sh` to `/opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger/`.

---

### Phoebus Olog

- **Installation Guide**: [Phoebus Olog](https://github.com/Olog/phoebus-olog?tab=readme-ov-file#installation)

#### Download and Install

```
cd /tmp/
git clone https://github.com/Olog/phoebus-olog.git
cd phoebus-olog/
mvn clean install -Pdeployable-jar -DskipTests
mkdir -p /opt/epics-tools/services/nasa/olog
cp -rf /tmp/phoebus-olog/target/service-olog-5.0.0-SNAPSHOT.jar /opt/epics-tools/services/nasa/olog/
```

#### Enable and Start Olog Service

```
systemctl enable phoebus_olog
systemctl start phoebus_olog
```

---

### Archiver Appliance

#### Install Archiver Appliance

### Prerequisites
- **MySQL 5.7** (with legacy encryption)
- **Gradle** (for building the application)

### Step 1: Build and Deploy the Archiver Appliance
1. **Clone the Repository**
   ```
   cd /tmp/
   git clone https://github.com/archiver-appliance/epicsarchiverap.git && cd epicsarchiverap && git checkout 75665cb -b deploy
   cd /tmp/epicsarchiverap
   ./gradlew
   ```

   or use pre built binaries https://github.com/archiver-appliance/epicsarchiverap/releases/tag/1.1.0

2. **Prepare Directories**
   ```
   mkdir -p /tmp/epicsarchiverap-dep
   cd /tmp/epicsarchiverap-dep
   ```

### Step 2: Download Dependencies
1. **Download Tomcat**
   ```
   wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.31/bin/apache-tomcat-9.0.31.tar.gz
   ```

2. **Download MySQL Connector**
   ```
   wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-j-8.2.0.tar.gz
   ```

### Step 3: Setup MySQL
1. **Create the Archiver Database**
   
   See details for [RDB Setup](https://github.com/archiver-appliance/epicsarchiverap/wiki/setup_rhel7_rpms#install-dependencies)
   
   ```
   mysql --user=root --password=*****
   CREATE DATABASE archappl;
   CREATE USER archappl IDENTIFIED BY '******';
   GRANT ALL ON archappl.* TO 'archappl'@'%' WITH GRANT OPTION;
   ```

### Step 4: Install the Archiver Appliance
1. **Prepare Installation Directory**
   ```
   mkdir -p /opt/epics-tools/services/nasa/aa/deploy
   cp -rf /tmp/epicsarchiverap/build/distributions/archappl_v1.1.0-55-g8fea848.tar.gz /opt/epics-tools/services/nasa/aa/deploy/
   cd /opt/epics-tools/services/nasa/aa/deploy
   tar -xvf archappl_v1.1.0-55-g8fea848.tar.gz
   ```

2. **Setup the MySQL Connector**
   ```
   cd /opt/epics-tools/services/nasa/aa/deploy
   tar -xvf /tmp/epicsarchiverap-dep/mysql-connector-j-8.2.0.tar.gz
   ```

3. **Create Installation Scripts Directory**
   ```
   mkdir -p /opt/epics-tools/services/nasa/aa/deploy/install_scripts
   ```

4. **Copy Installation Scripts**
   - Copy `single_machine_install.sh` and fix Python references in `addMysqlConnPool.py` and `deployMultipleTomcats.py`.

5. **(Optional) Create Configuration Directory**
   ```
   mkdir -p /opt/epics-tools/services/nasa/aa/deploy/conf
   ```

### Step 5: Run the Installation
1. **Set Environment Variables**
   ```bash
   cd /opt/epics-tools/services/nasa/aa/deploy/install_scripts
   export DEPLOY_DIR=/opt/epics-tools/services/nasa/aa/deploy
   export JAVA_HOMEb=/usr/lib/jvm/java-17-openjdk-amd64
   export TOMCAT_DISTRIBUTION=/tmp/epicsarchiverap-dep/apache-tomcat-9.0.31.tar.gz
   export MYSQL_CLIENT_JAR=/opt/epics-tools/services/nasa/aa/deploy/mysql-connector-j-8.2.0/mysql-connector-j-8.2.0.jar
   export MYSQL_CONNECTION_STRING="--host=localhost --user=archappl --password=***** --database=archappl"
   # Optional
   export SITE_SPECIFIC_POLICIES_FILE=/opt/epics-tools/services/nasa/aa/deploy/conf/policies.py
   ```

2. **Execute the Installation Script**
   ```bash
   ./single_machine_install.sh
   ```

### Step 6: Configure Startup and Services
1. **Setup Startup Scripts**
   - Copy `sampleStatup.sh` to `/opt/epics-tools/services/nasa/aa/deploy/nasaStartup.sh`.

2. **Setup Service Files**
   - Copy `aa.service` to `/etc/systemd/system`.

3. **Modify HTML Management Pages**
   ```bash
   cd /opt/epics-tools/services/nasa/aa/deploy/mgmt/webapps/mgmt/ui/
   find . -type f -name "*.html" -exec sed -i 's/LCLS/NSLS2/gI' {} +
   find . -type f -name "*.html" -exec sed -i 's/Jingchen Zhou/AST/gI' {} +
   find . -type f -name "*.html" -exec sed -i 's/Murali Shankar at 650 xxx xxxx or Bob Hall at 650 xxx xxxx/Kunal Shroff at shroffk@bnl.gov/gI' {} +
   ```

4. **Switch Lab Logo**
   - Update logos in:
     - `../mgmt/webapps/mgmt/ui/comm/img/labLogo.png`
     - `../mgmt/webapps/mgmt/ui/comm/img/labLogo2.png`

--- 

Feel free to modify any specifics or add more steps as needed!

---

### ChannelFinder

- **Installation Guide**: [ChannelFinder Service](https://github.com/ChannelFinder/ChannelFinderService)

#### Install ChannelFinder

```
cd /tmp/
git clone https://github.com/ChannelFinder/ChannelFinderService.git
cd ChannelFinderService
mvn clean install -DskipTests
mkdir -p /opt/epics-tools/services/nasa/cf
cp -rf /tmp/ChannelFinderService/target/ChannelFinder-4.7.3-SNAPSHOT.jar /opt/epics-tools/services/nasa/cf/
```

#### Enable and Start ChannelFinder Service

```
systemctl enable cf
systemctl start cf
```

---

### Save/Restore

```
mkdir -p /opt/epics-tools/services/nasa/save_restore
cp /tmp/phoebus/services/save-and-restore/target/service-save-and-restore-4.7.4-SNAPSHOT.jar /opt/epics-tools/services/nasa/save_restore/
```

- Setup services using `save_restore.service` as a template.

#### Enable and Start Save/Restore Service

```
systemctl enable save_restore
systemctl start save_restore
``` 

---
