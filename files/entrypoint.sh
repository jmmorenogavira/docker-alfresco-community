#!/bin/bash
# trap SIGTERM and gracefully stops alfresco
set -e
trap '/opt/alfresco-community/alfresco.sh stop;exit 0' SIGTERM

echo "Loading environment variables..."

echo "setting values for all the '-e ALF_xxx=...' parameters provided at startup";
bash /replacevars.sh;
	
bash /changepass.sh

if [ -f /.apply_amps_created ]; 
then
    echo "apply_amps.sh done"
else   
	if grep -q ^read /opt/alfresco-community/bin/apply_amps.sh
	then
    	sed -i "/opt/alfresco-community/bin/apply_amps.sh" -e "s/read/#read/g"
	fi
	/opt/alfresco-community/bin/apply_amps.sh
	touch /.apply_amps_created
fi


	
echo "Starting Alfresco...";
/opt/alfresco-community/alfresco.sh start;
# loop so container does not exit
while true;do sleep 5;done;
