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
sudo apt install procserv
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

- Copy [elasticsearch.yml](https://github.com/osprey-dcs/epics-services-deployment/blob/main/elastic/elasticsearch.yml) to `/opt/epics-tools/services/nasa/elastic/elasticsearch-8.2.3/config`

#### Set Up ElasticSearch as a Service

- Copy [elastic.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/elastic/elastic.service) to `/etc/systemd/system/`

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

### Kafka 3.9.0

- **Installation Guide**: [Kafka Documentation](https://kafka.apache.org/22/documentation.html)

#### Download and Extract Kafka

```
cd /tmp
wget https://downloads.apache.org/kafka/3.9.0/kafka_2.13-3.9.0.tgz
mkdir -p /opt/epics-tools/services/nasa/kafka
cd /opt/epics-tools/services/nasa/kafka
tar -xvf /tmp/kafka_2.13-3.9.0.tgz
```

#### Optional Configuration

- **Zookeeper and Kafka Port Configuration**:  
  You may configure Zookeeper and Kafka ports by editing the respective configuration files located in the `kafka/config/` directory. Additionally, ensure that the data folder is properly set up for Kafka to store its data.

- **Kafka Listener Configuration**:  
  By default, Kafka uses the `getCanonicalName` of the machine and port `9092` as its listener. This should work in most scenarios. However, if you experience connection issues, you can manually set the listener by adding the following line to your `server.properties` file:

  ```properties
  listeners=PLAINTEXT://<hostname>:9092

#### Set Up Kafka and Zookeeper Services

- Copy [zookeeper.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/kafka/zookeeper.service) and [kafka.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/kafka/kafka.service) to `/etc/systemd/system/`.

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
git clone https://github.com/ControlSystemStudio/phoebus.git && cd phoebus && git checkout v4.7.4 -b deploy
mvn clean install -DskipTests
```

Install Phoebus in your home directory

```
cp -rf /tmp/phoebus/phoebus-product/ ~
```

- Copy [phoebus-preferences.ini](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-preferences.ini) to `~/phoebus-product/`.

**Note** the preferences are system specific and you will have to review and update n/w configurations, creadentails, alarm topics to match your deployment

```
./phoebus.sh -p phoebus-preferences.ini
```

---

### Alarm Services

- **Alarm Server**: [Alarm Server](https://github.com/ControlSystemStudio/phoebus/tree/master/services/alarm-server)
- **Alarm Logger**: [Alarm Logger](https://github.com/ControlSystemStudio/phoebus/tree/master/services/alarm-logger)
- **Alarm Config Logger**: [Alarm Config Logger](https://github.com/ControlSystemStudio/phoebus/tree/master/services/alarm-config-logger)


#### Install Alarm Server

Ensure you have completed the previous step of `Phoebus Installation`

```
mkdir -p /opt/epics-tools/services/nasa/phoebus-alarms
cp -rf /tmp/phoebus/services/alarm-server/target/service-alarm-server-4.7.4-bin.tar.gz /opt/epics-tools/services/nasa/phoebus-alarms/
cd /opt/epics-tools/services/nasa/phoebus-alarms
tar -xvf service-alarm-server-4.7.4-bin.tar.gz
```

- Copy [run-phoebus-alarm.sh](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/run-phoebus-alarm.sh) to `/opt/epics-tools/services/nasa/phoebus-alarms/`.

#### Setup Alarm Preferences

- Copy [phoebus_alarm_preferences.ini](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/phoebus_alarm_preferences.ini) to `/opt/epics-tools/services/nasa/phoebus-alarms`.

#### Install Alarm Logger

```
mkdir /opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger
cp -rf /tmp/phoebus/services/alarm-logger/target/service-alarm-logger-4.7.4.jar /opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger/
```

#### Setup Alarm Logger Preferences

- Copy the logger [phoebus_alarm.properties](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/phoebus_alarm.properties) to `/opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger/`.

- Copy [run-phoebus-alarm-logger.sh](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/run-phoebus-alarm-logger.sh) to `/opt/epics-tools/services/nasa/phoebus-alarms/alarm_logger/`.

#### Install Alarm Config Logger

```
mkdir /opt/epics-tools/services/nasa/phoebus-alarms/alarm_config_logger
cp -rf /tmp/phoebus/services/alarm-config-logger/target/service-alarm-config-logger-4.7.4.jar /opt/epics-tools/services/nasa/phoebus-alarms/alarm_config_logger/
```

#### Setup Alarm Config Logger Preferences

- Copy the config logger [phoebus_alarm.properties](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/phoebus_alarm.properties) to `/opt/epics-tools/services/nasa/phoebus-alarms/alarm_config_logger/`.

- Copy [run-phoebus-alarm-config-logger.sh](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/run-phoebus-alarm-config-logger.sh) to `/opt/epics-tools/services/nasa/phoebus-alarms/alarm_config_logger/`.

#### initialize the alarm configuration

Initialize the alarm topics using the create_alarm_topics scripts

- Copy [create_alarm_topics](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/create_alarm_topics.sh) to `/opt/epics-tools/services/nasa/phoebus-alarms`.

```
./create_alarm_topics nasa_epics_alarm
```

#### Enable and Start Alarm Services

- Setup the services using the template phoebus_alarm.services

- Copy [phoebus_alarm.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/phoebus_alarm.service) to `/etc/systemd/system`

- Copy [phoebus_alarm_logger.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/phoebus_alarm_logger.service) to `/etc/systemd/system`

- Copy [phoebus_alarm_config_logger.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-alarm/phoebus_alarm_config_logger.service) to `/etc/systemd/system`

```
systemctl enable phoebus_alarm
systemctl start phoebus_alarm

systemctl enable phoebus_alarm_logger
systemctl start phoebus_alarm_logger

systemctl enable phoebus_alarm_config_logger
systemctl start phoebus_alarm_config_logger
```

#### Verification

Start the Phoebus GUI:
run-phoebus
In the GUI menus, navigate to:   
    Applications -> Alarm -> Alarm Tree  
and then repeat to   
    Applications -> Alarm -> Alarm Log Table   

Verification of the alarm configuration logger

The alarm configuration logger creates a git repo with the alarm configuration tree under the folder configured in the `phoebus_alarm_config_logger.service`

e.g.
```
ls -al /opt/epics-tools/services/nasa/phoebus-alarms/nasa_epics_alarm
```

---

### Phoebus Olog

- **Installation Guide**: [Phoebus Olog](https://github.com/Olog/phoebus-olog?tab=readme-ov-file#installation)

#### Download and Install

```
cd /tmp/
git clone https://github.com/Olog/phoebus-olog.git -b v5.0.2 && cd phoebus-olog && git checkout -b deploy
mvn clean install -Pdeployable-jar -DskipTests
mkdir -p /opt/epics-tools/services/nasa/olog
cp -rf /tmp/phoebus-olog/target/service-olog-5.0.2.jar /opt/epics-tools/services/nasa/olog/service-olog-5.0.2.jar
```

**Setup Startup Scripts and properties**

- Copy [olog.properties](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-olog/olog.properties) to ` /opt/epics-tools/services/nasa/olog/`.

- Copy [run-phoebus-olog.sh](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-olog/run-phoebus-olog.sh) to ` /opt/epics-tools/services/nasa/olog/`.

#### Enable and Start Olog Service

- Copy [phoebus_olog.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-olog/phoebus_olog.service) to `/etc/systemd/system`

```
systemctl enable phoebus_olog
systemctl start phoebus_olog
```

#### Check service status

```
curl http://localhost:9090/Olog
```

Follow the verification instructions on [Github](https://github.com/Olog/phoebus-olog?tab=readme-ov-file#check-if-service-is-running)

#### Olog Webclient

```
cd /opt/epics-tools/services/nasa/olog
git clone https://github.com/Olog/phoebus-olog-web-client.git && cd phoebus-olog-web-client && git checkout v2.1.0 -b deploy
cp .env.example .env

# Set REACT_APP_BASE_URL=http://localhost:9090/Olog
# The exact URL should match your Olog service deployment

npm ci
npm run build
```

- Copy [phoebus_olog_webclient.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/phoebus-olog/phoebus_olog_webclient.service) to `/etc/systemd/system`

```
systemctl enable phoebus_olog_webclient
systemctl start phoebus_olog_webclient
```

NOTE: You will also have to update the olog.properties to include the following cors exception

```
############################## CORS settings ##############################
# Comma separated list of origins allowed to do CORS requests.
# Defaults to http://localhost:3000 (NodeJS development), but must be augmented
# with the origin(s) on which the web front-end is deployed.
cors.allowed.origins=http://localhost:3000
```

Installing Olog on tomcat or other servers

OR - option2

You can follow the instruction available at:

https://create-react-app.dev/docs/deployment/

```
npm install -g serve
serve -s build
```

Update the following 2 lines in the `/etc/systemd/system/phoebus_olog_webclient`

```
WorkingDirectory=/opt/epics-tools/services/nasa/olog/phoebus-olog-web-client
ExecStart=serve -s build
```

---

### Archiver Appliance

#### Install Archiver Appliance

### Prerequisites
- **MySQL or MariaDB** (with legacy encryption)
- **Gradle** (for building the application)

### Step 1: Build and Deploy the Archiver Appliance
1. **Clone the Repository**
   ```
   cd /tmp/
   git clone https://github.com/archiver-appliance/epicsarchiverap.git && cd epicsarchiverap && git checkout 75665cb -b deploy
   cd /tmp/epicsarchiverap
   ./gradlew -x sphinx
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

### Step 3: Setup RDB backend
1. **Create the Archiver Database**
   
   See details for [RDB Setup](https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-22-04)
   
   ```
   sudo mariadb
   ```
   In the database shell
   ```
   CREATE DATABASE archappl;
   CREATE USER archappl IDENTIFIED BY '******';
   GRANT ALL ON archappl.* TO 'archappl'@'%' WITH GRANT OPTION;
   ```

### Step 4: Install the Archiver Appliance
1. **Prepare Installation Directory**
   ```
   mkdir -p /opt/epics-tools/services/nasa/aa/deploy
   cp -rf /tmp/epicsarchiverap/build/distributions/archappl_v1.1.0-97-g75665cb.tar.gz /opt/epics-tools/services/nasa/aa/deploy/
   cd /opt/epics-tools/services/nasa/aa/deploy
   tar -xvf archappl_v1.1.0-97-g75665cb.tar.gz
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
   Copy the following templated install scripts to `install_scripts`
   - Copy [single_machine_install.sh](https://github.com/osprey-dcs/epics-services-deployment/blob/main/aa/single_machine_install.sh)
   - Copy [addMysqlConnPool.py](https://github.com/osprey-dcs/epics-services-deployment/blob/main/aa/addMysqlConnPool.py)
   - Copy [deployMultipleTomcats.py](https://github.com/osprey-dcs/epics-services-deployment/blob/main/aa/deployMultipleTomcats.py)

5. **(Optional) Create Configuration Directory**
   ```
   mkdir -p /opt/epics-tools/services/nasa/aa/deploy/conf
   ```

6. **Create/Verify the storage locations**

   Ensure the STS, MTS, and LTS locations exist.
   
   ```
   sudo install -d -o epics_services_nasa -g epics_services_nasa /arch

   sudo install -d -o epics_services_nasa -g epics_services_nasa /arch/sts/ArchiverStore
   sudo install -d -o epics_services_nasa -g epics_services_nasa /arch/mts/ArchiverStore
   sudo install -d -o epics_services_nasa -g epics_services_nasa /arch/lts/ArchiverStore
   sudo mount -t tmpfs -o size=2048M tmpfs /arch/sts/ArchiverStore
   ```
   
   Update the fstab file `/etc/fstab`
   ```
   none /arch/sts/ArchiverStore tmpfs nodev,nosuid,noexec,nodiratime,size=2048M 0 0
   ```

### Step 5: Run the Installation
1. **Set Environment Variables**
   ```bash
   cd /opt/epics-tools/services/nasa/aa/deploy/install_scripts
   export DEPLOY_DIR=/opt/epics-tools/services/nasa/aa/deploy
   export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
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
1. **Setup Startup Scripts [IMPORTANT]**
   - Copy [sampleStatup.sh](https://github.com/osprey-dcs/epics-services-deployment/blob/main/aa/sampleStartup.sh) to `/opt/epics-tools/services/nasa/aa/deploy/nasaStartup.sh`.

2. **Setup Service Files**
   - Copy [aa.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/aa/aa.service) to `/etc/systemd/system`.

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

#### Verify the service is running

Check the `/opt/epics-tools/services/nasa/aa/deploy/mgmt/logs/arch.log`

The following messages represent a good way to verify the AA services are running

```
[INFO ] 2024-09-24 16:43:51.705 [Startup executor] MgmtPostStartup - Finished post startup for the mgmt webapp
[INFO ] 2024-09-24 16:44:03.783 [http-nio-17665-exec-4] BasicDispatcher - Servicing /webAppReady
[INFO ] 2024-09-24 16:44:03.785 [http-nio-17665-exec-4] WebappReady - Received webAppReady from RETRIEVAL
[INFO ] 2024-09-24 16:44:03.802 [http-nio-17665-exec-5] BasicDispatcher - Servicing /webAppReady
[INFO ] 2024-09-24 16:44:03.803 [http-nio-17665-exec-5] WebappReady - Received webAppReady from ETL
[INFO ] 2024-09-24 16:44:04.200 [http-nio-17665-exec-6] BasicDispatcher - Servicing /webAppReady
[INFO ] 2024-09-24 16:44:04.201 [http-nio-17665-exec-6] WebappReady - Received webAppReady from ENGINE
[INFO ] 2024-09-24 16:44:06.199 [Startup executor] MgmtPostStartup - About to run MgmtPostStartup
[INFO ] 2024-09-24 16:44:06.200 [Startup executor] MgmtPostStartup - Startup is complete for MgmtPostStartup
[INFO ] 2024-09-24 16:44:11.070 [http-nio-17665-exec-4] MgmtRuntimeState - All components in this appliance have started up. We should be ready to start accepting UI requests
```

---

### ChannelFinder

- **Installation Guide**: [ChannelFinder Service](https://github.com/ChannelFinder/ChannelFinderService)

#### Install ChannelFinder

```
cd /tmp/
git clone https://github.com/ChannelFinder/ChannelFinderService.git  && cd ChannelFinderService && git checkout ChannelFinder-4.7.3

cd ChannelFinderService
mvn clean install -DskipTests
mkdir -p /opt/epics-tools/services/nasa/cf
cp -rf /tmp/ChannelFinderService/target/ChannelFinder-4.7.3.jar /opt/epics-tools/services/nasa/cf/ChannelFinder-4.7.3.jar
```

- Copy [cf.properties](https://github.com/osprey-dcs/epics-services-deployment/blob/main/cf/cf.properties) to `/opt/epics-tools/services/nasa/cf/`.

- Copy [run-cf.sh](https://github.com/osprey-dcs/epics-services-deployment/blob/main/cf/run-cf.sh) to `/opt/epics-tools/services/nasa/cf/`.

#### Enable and Start ChannelFinder Service

- Copy [cf.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/cf/cf.service) to `/etc/systemd/system`.

```
systemctl enable cf
systemctl start cf
```

#### Check service status


```
curl http://localhost:7070/ChannelFinder
```

Follow the verification instructions on [Github](https://github.com/ChannelFinder/ChannelFinderService?tab=readme-ov-file#verification)

#### Setting up recsync

```
sudo apt install python3-twisted python3-requests python3-simplejson python3-urllib3

cd /tmp
git clone https://github.com/ChannelFinder/RecSync-env && cd RecSync-env && git checkout b01bd93 -b deploy
cd RecSync-env

make init
make install

# in /etc/systemd/system/recsync.service
# change channelfinder.service to cf.service
# change /usr/bin/twistd to /usr/bin/twistd3

systemctl daemon-reload
systemctl start recsync.service
systemctl status recsync.service
```

#### Recsync configuration

In `/opt/RecSync/recsync.conf` set addrList

In `/opt/RecSync/channelfinderapi.conf` set the CF url, username, and password

#### Check recsync service status

```
[twisted.scripts._twistd_unix.UnixAppLogger#info] twistd 22.1.0 (/usr/bin/python3 3.10.12) starting up.
[twisted.scripts._twistd_unix.UnixAppLogger#info] reactor class: twisted.internet.pollreactor.PollReactor.
[stdout#info] Starting
[-] CastFactory starting on 45722
[recceiver.recast.CastFactory#info] Starting factory <recceiver.recast.CastFactory object at 0x7f5a3e96d7e0>
[stdout#info] listening on IPv4Address(type='TCP', host='0.0.0.0', port=45722)
[-] Announcer starting on 45722
[-] Starting protocol <recceiver.announce.Announcer object at 0x7f5a3e96e110>
```
---

### Save/Restore

```
mkdir -p /opt/epics-tools/services/nasa/save_restore
cp /tmp/phoebus/services/save-and-restore/target/service-save-and-restore-4.7.4.jar /opt/epics-tools/services/nasa/save_restore/service-save-and-restore-4.7.4.jar
```

- Copy [save_restore.properties](https://github.com/osprey-dcs/epics-services-deployment/blob/main/sar/save_restore.properties) to `/opt/epics-tools/services/nasa/save_restore/`.

- Copy [run-save-restore.sh](https://github.com/osprey-dcs/epics-services-deployment/blob/main/sar/run-save_restore.sh) to `/opt/epics-tools/services/nasa/save_restore/`.


#### Enable and Start Save/Restore Service

- Setup services using `save_restore.service` as a template.

- Copy [save_restore.service](https://github.com/osprey-dcs/epics-services-deployment/blob/main/sar/save_restore.service) to `/etc/systemd/system`.


```
systemctl enable save_restore
systemctl start save_restore
``` 

#### Check service status

```
curl http://localhost:6060/save-restore
```

Follow the verification instructions on [Github](https://github.com/ControlSystemStudio/phoebus/tree/master/services/save-and-restore#verification)

---
