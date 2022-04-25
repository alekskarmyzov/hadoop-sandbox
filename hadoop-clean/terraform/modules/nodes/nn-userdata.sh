#!/bin/bash

sudo apt-get update
sudo apt-get install unzip -y

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Pull SSH key from AWS Parameter Store
# ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
aws ssm get-parameter --name "/akarmyzov/id_rsa" --query 'Parameter.Value' --output text >> ~/.ssh/id_rsa
aws ssm get-parameter --name "/akarmyzov/id_rsa.pub" --query 'Parameter.Value' --output text >> ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys


# Install Java 8
sudo apt install openjdk-8-jdk -y

# Get Hadoop 
wget https://archive.apache.org/dist/hadoop/core/hadoop-3.3.2/hadoop-3.3.2.tar.gz
tar -xvf hadoop-3.3.2.tar.gz

# Add Hadoop and Java PATH variables to .bashrc
cat <<EOF >>~/.bashrc
export HADOOP_HOME=${PWD}/hadoop-3.3.2
export HADOOP_CONF_DIR=${PWD}/hadoop-3.3.2/etc/hadoop
export HADOOP_MAPRED_HOME=${PWD}/hadoop-3.3.2
export HADOOP_COMMON_HOME=${PWD}/hadoop-3.3.2
export HADOOP_HDFS_HOME=${PWD}/hadoop-3.3.2
export YARN_HOME=${PWD}/hadoop-3.3.2
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:/usr/lib/jvm/java-8-openjdk-amd64/bin:$PWD/hadoop-3.3.2/bin
EOF
source .bashrc

# Create core-site.xml
cat <<EOF >./hadoop-3.3.2/etc/hadoop/core-site.xml 
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>fs.default.name</name>
<value>:9000</value>
</property>
</configuration>
EOF

# Create hdfs-site.xml
cat <<EOF >./hadoop-3.3.2/etc/hadoop/hdfs-site.xml 
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>dfs.replication</name>
<value>1</value>
</property>
<property>
<name>dfs.permission</name>
<value>false</value>
</property>
</configuration>
EOF

# Create mapred-site.xml
cat <<EOF >./hadoop-3.3.2/etc/hadoop/mapred-site.xml 
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>
</configuration>
EOF

# Create yarn-site.xml
cat <<EOF >./hadoop-3.3.2/etc/hadoop/yarn-site.xml
<?xml version="1.0"?>
<configuration>
<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>
<property>
<name>yarn.nodemanager.auxservices.mapreduce.shuffle.class</name>
<value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>
</configuration>
EOF

# Add Java PATH to hadoop-env.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> hadoop-3.3.2/etc/hadoop/hadoop-env.sh