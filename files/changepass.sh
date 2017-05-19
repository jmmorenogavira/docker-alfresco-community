#!/bin/bash
set -e

if [[ $PASSWORD_RESTARTED == 0 ]]; then
	echo "Restoring password..."
	ENV_PASS=`python /encodepass.py`
	sed -i /opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties -e "s/alfresco_user_store\.adminpassword=.*/alfresco_user_store\.adminpassword=$ENV_PASS/g"
	export PASSWORD_RESTARTED=1
fi

