#!/bin/bash
export M2_HOME=/home/ramya/Installed/apache-maven
export M2=$M2_HOME/bin
export PATH=$PATH:$M2
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386
export PATH=$PATH:$JAVA_HOME/bin
export HADOOP_PREFIX=/home/ramya/Installed/hadoop
export PATH=$PATH:$HADOOP_PREFIX/bin
export MAHOUT_DIR=/home/ramya/Installed/mahout
export MAHOUT=$MAHOUT_DIR/bin/mahout
echo $PATH	
