#!/bin/sh
set -e

# Disable Tomcat shutdown port to prevent cloud health-check interference
sed -i 's/<Server port="[0-9\-]*"/<Server port="-1"/g' /usr/local/tomcat/conf/server.xml

# Bind Tomcat HTTP connector to cloud-assigned $PORT (Render / Railway) or 8080
TARGET_PORT="${PORT:-8080}"
sed -i "s/<Connector port=\"[0-9]*\"/<Connector port=\"$TARGET_PORT\"/g" /usr/local/tomcat/conf/server.xml

echo "=========================================================="
echo "CodeQuest Cloud Container: Tomcat HTTP listening on port $TARGET_PORT"
echo "Tomcat shutdown listener disabled (port=-1) for cloud compliance"
echo "=========================================================="

exec catalina.sh run
