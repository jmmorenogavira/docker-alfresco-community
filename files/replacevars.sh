#!/bin/bash
# setting values for all the "-e ALF_xxx=..." parameters provided at startup
set -e
for thing in `env`
do
 if [[ $thing == ALF* ]]; then
# replace the "\075" when equal is escaped (see tutum)
    thingreplaced=`echo -e $thing`
# another possibility to escape with tutul is to use .EQ. 
    string_to_replace_with="="
    result_string="${thingreplaced/.EQ./$string_to_replace_with}"
    thingreplaced=$result_string
    echo $thingreplaced
# getting the value of the parameter
     val=`echo -e  "$thingreplaced" | awk -F "=" '{print $1}'`
     echo "val:$val"
# getting the name value of the configuration variable passed as parameter
     name=`echo -e "${!val}" | awk -F "\.EQ\.|=" '{print $1}'`
     echo "name:$name"
     #varvalue=`echo -e "${!val}" | awk -F "\.EQ\.|=" '{print $2}'`
     # using special replacement to only split by first "=" (ldap configuration problems)
     varvalue=`echo -e "${!val}" | awk -F "\.EQ\.|=" 'sub($1, "", $0) {print substr($0, 2)}'`
     echo "varvalue:$varvalue"
# if varvalue starts with TUTUM then it is considered as a tutum variable
     if [[ $varvalue == TUTUM* ]]; then
        varvalue=`echo -e "${!varvalue}"`
        echo "varvalue tutum:$varvalue"
     fi
# test if varvalue already configured in alfresco-global.properties
     if grep -q ^$name= /opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties
     then
        sed -i "/opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties" -e "s/$name=.*/$name=$varvalue/g"
    else
        echo  "$name=$varvalue" >> "/opt/alfresco-community/tomcat/shared/classes/alfresco-global.properties"
    fi

# not actually    
# look for variable in xml files alfresco-global.properties
#     if grep -q \$\{$name\} /opt/alfresco-community/tomcat/shared/classes/alfresco/web-extension/share-config-custom.xml
#     then
#        sed -i "/opt/alfresco-community/tomcat/shared/classes/alfresco/web-extension/share-config-custom.xml" -e "s|\${$name}|$varvalue|g"
#    fi

 fi
done
