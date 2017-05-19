#!/bin/bash
# trap SIGTERM and gracefully stops alfresco
set -e
trap '/opt/alfresco-community/alfresco.sh stop;exit 0' SIGTERM

echo "Loading environment variables..."

echo "setting values for all the '-e ALF_xxx=...' parameters provided at startup";
bash /replacevars.sh;
	
bash /changepass.sh
	
echo "Starting Alfresco...";
/opt/alfresco-community/alfresco.sh start;
# loop so container does not exit
while true;do sleep 5;done;
