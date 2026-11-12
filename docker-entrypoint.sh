#!/bin/sh
set -e

# Disable Tomcat shutdown port to prevent cloud health-check interference
sed -i 's/<Server port="[0-9\-]*"/<Server port="-1"/g' /usr/local/tomcat/conf/server.xml

# Bind Tomcat HTTP connector to cloud-assigned $PORT (Render / Railway) or 8080
TARGET_PORT="${PORT:-8080}"
sed -i "s/<Connector port=\"[0-9]*\"/<Connector port=\"$TARGET_PORT\"/g" /usr/local/tomcat/conf/server.xml

# Ensure Database environment variables default to TiDB Cloud cluster if unset
export DB_URL="${DB_URL:-jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/codequest_db?useSSL=true&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8}"
export DB_USER="${DB_USER:-38AoYnra5uUE3k9.root}"
export DB_PASSWORD="${DB_PASSWORD:-0YzGWKOyksUpTdpN}"

echo "=========================================================="
echo "CodeQuest Cloud Container: Tomcat HTTP listening on port $TARGET_PORT"
echo "Database URL: $DB_URL"
echo "Database User: $DB_USER"
echo "Tomcat shutdown listener disabled (port=-1) for cloud compliance"
echo "=========================================================="

exec catalina.sh run
