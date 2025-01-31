# docker-alfresco-community

The image is based on Centos 7.

Builds an Alfresco container based on Alfresco Community Edition v 5.2

## Usage

In order to run a basic container is required to establish the next items:

- MySQL database required for Alfresco (can use another database type like PostgreSQL for example)
- A persistent volume in order to be able to restart and restore the container to a previous state

For more detailed instructions about Alfresco requirements,
see the documentation for `Alfresco Community Edition` image
[here](http://docs.alfresco.com/).

## Configuration (environment variables)

The next environment variables could be provided:

*  `INITIAL_PASS` - Restore the admin password when the container is created
*  `JAVA_OPTS` - JVM options like `-XX:MaxPermSize=256M -Xss1024K -Xms1G -Xmx2G`

In order to be able to configure some variables from alfresco-global.properties a trick is provided: 

##### ALF_*** variables must have format alfresco-global.properties_VAR_NAME=VALUE

All variables that starts with ALF_*** are replaced into configuration file for Alfresco.
An example for database configuration:
 
    - ALF_1=db.driver=org.gjt.mm.mysql.Driver
    - ALF_2=db.username=alfresco_user
    - ALF_3=db.password=alfresco_password
    - ALF_4=db.name=alfresco_db
    # db.host needs to point to a valid hostname (defined in extra_hosts or links)
    - ALF_5=db.host=alfresco_db_host
    - ALF_6=db.port=3306
    - ALF_7=db.jdbc.type=mysql

For more detailed instructions about Alfresco configuration requirements,
see the documentation for `Alfresco Configuration` image
[here](http://docs.alfresco.com/5.2/concepts/ch-configuration.html).

## Data persistence

If you want to make your data persistent, you need to mount a volume:

	docker run ....... -v /opt/alfresco-community/alf_data:/opt/alfresco-community/alf_data .....
	
This volume needs to contains basic data from alfresco for first start.
These information is provided
[here](https://github.com/jmmorenogavira/docker-alfresco-community).

The repository contains a zip with Alfresco installation (alfresco-community.tar.gz). 
The folder alf_data needs to be copied to the volume folder (only first time).

## Data coherence

The database and the content of alf_data directory are very related.
In order to backup and  restore Alfresco installation, you need to save the database and these folder.

## Alfresco integration with FreeIPA example configuration

The next environmets variables are used to connect and sync users from FreeIPA to Alfresco

    # FreeIPA configuration
    - ALF_LDAP_1=authentication.chain=alfinst:alfrescoNtlm,ldap1:ldap-ad
    - ALF_LDAP_2=ntlm.authentication.sso.enabled=false
    - ALF_LDAP_3=ldap.authentication.allowGuestLogin=false
    - ALF_LDAP_4=ldap.authentication.userNameFormat=uid=%s,cn=users,cn=accounts,dc=test,dc=com
    - ALF_LDAP_5=ldap.authentication.java.naming.provider.url=ldap:\/\/ipa.test.com:389
    - ALF_LDAP_6=ldap.authentication.defaultAdministratorUserNames=user.admin
    - ALF_LDAP_7=ldap.synchronization.java.naming.security.principal=uid=user.admin,cn=users,cn=accounts,dc=test,dc=com
    - ALF_LDAP_8=ldap.synchronization.java.naming.security.credentials=pass.admin
    # The group search base restricts the LDAP group query to a sub section of tree on the LDAP server.
    - ALF_LDAP_9=ldap.synchronization.groupSearchBase=cn\=groups,cn\=accounts,dc\=test,dc\=com
    # The user search base restricts the LDAP user query to a sub section of tree on the LDAP server.
    - ALF_LDAP_10=ldap.synchronization.userSearchBase=cn\=users,cn\=accounts,dc\=test,dc\=com
    # User and group sync config
    - ALF_LDAP__SYNC_1=synchronization.synchronizeChangesOnly=true
    # The cron expression defining when imports should take place
    - ALF_LDAP_SYNC_2=synchronization.import.cron=0 0 0 * * ?
    # Should we trigger a differential sync when missing people log in?
    - ALF_LDAP_SYNC_3=synchronization.syncWhenMissingPeopleLogIn=false
    # Should we trigger a differential sync on startup?
    - ALF_LDAP_SYNC_4=synchronization.syncOnStartup=true
    # Should we auto create a missing person on log in?
    - ALF_LDAP_SYNC_5=synchronization.autoCreatePeopleOnLogin=false
    # The number of entries to process before logging progress
    - ALF_LDAP_SYNC_6=synchronization.loggingInterval=100
    # The number of threads to use when doing a batch (scheduled or startup) sync
    - ALF_LDAP_SYNC_7=synchronization.workerThreads=1
    # Synchronization with deletions
    - ALF_LDAP_SYNC_8=synchronization.allowDeletions=true
    # For large LDAP directories the delete query is expensive and time consuming, needing to read the entire LDAP directory.
    - ALF_LDAP_SYNC_9=synchronization.syncDelete=true
    # external setting (LDAP systems) - whether users can be enabled; if false then users have to be explicitly disabled in Alfresco
    - ALF_LDAP_SYNC_10=synchronization.externalUserControl=true
    # Subsystem that will handle the external user control
    - ALF_LDAP_SYNC_11=synchronization.externalUserControlSubsystemName=ldap1
    # If positive, this property indicates that RFC 2696 paged results should be
    # used to split query results into batches of the specified size. This
    # overcomes any size limits imposed by the LDAP server.
    - ALF_LDAP_SYNC_12=ldap.synchronization.queryBatchSize=0
    # If positive, this property indicates that range retrieval should be used to fetch
    # multi-valued attributes (such as member) in batches of the specified size.
    # Overcomes any size limits imposed by Active Directory.        
    - ALF_LDAP_SYNC_13=ldap.synchronization.attributeBatchSize=0
    # The query to select all objects that represent the groups to import.
    - ALF_LDAP_SYNC_14=ldap.synchronization.groupQuery=(&(objectclass\=groupOfNames)(cn\=group-alfresco-user))
    # The query to select objects that represent the groups to import that have changed since a certain time.
    - ALF_LDAP_SYNC_15=ldap.synchronization.groupDifferentialQuery=(&(objectclass\=groupOfNames)(!(modifyTimestamp<\={0})))
    # The query to select all objects that represent the users to import.
    - ALF_LDAP_SYNC_16=ldap.synchronization.personQuery=(&(objectclass\=inetOrgPerson)(memberOf\=cn\=group-alfresco-user,cn\=groups,cn\=accounts,dc\=test,dc\=com))
    # The query to select objects that represent the users to import that have changed since a certain time.
    - ALF_LDAP_SYNC_17=ldap.synchronization.personDifferentialQuery=(&(objectclass\=inetOrgPerson)(!(modifyTimestamp<\={0})))
    # The name of the operational attribute recording the last update time for a group or user.
    - ALF_LDAP_SYNC_18=ldap.synchronization.modifyTimestampAttributeName=modifyTimestamp
    # The timestamp format. Unfortunately, this varies between directory servers.
    - ALF_LDAP_SYNC_19=ldap.synchronization.timestampFormat=yyyyMMddHHmmss'Z'
    # The attribute name on people objects found in LDAP to use as the uid in Alfresco
    - ALF_LDAP_SYNC_20=ldap.synchronization.userIdAttributeName=uid
    # The attribute on person objects in LDAP to map to the first name property in Alfresco
    - ALF_LDAP_SYNC_21=ldap.synchronization.userFirstNameAttributeName=givenName
    # The attribute on person objects in LDAP to map to the last name property in Alfresco
    - ALF_LDAP_SYNC_22=ldap.synchronization.userLastNameAttributeName=sn
    # The attribute on person objects in LDAP to map to the email property in Alfresco
    - ALF_LDAP_SYNC_23=ldap.synchronization.userEmailAttributeName=mail
    # The attribute on person objects in LDAP to map to the organizational id  property in Alfresco
    #- ALF_LDAP_SYNC_24=ldap.synchronization.userOrganizationalIdAttributeName=o
    # The default home folder provider to use for people created via LDAP import
    - ALF_LDAP_SYNC_25=ldap.synchronization.defaultHomeFolderProvider=largeHomeFolderProvider
    # The attribute on LDAP group objects to map to the authority name property in Alfresco
    - ALF_LDAP_SYNC_26=ldap.synchronization.groupIdAttributeName=cn
    # The attribute on LDAP group objects to map to the authority display name property in Alfresco
    - ALF_LDAP_SYNC_27=ldap.synchronization.groupDisplayNameAttributeName=description
    # The group type in LDAP
    - ALF_LDAP_SYNC_28=ldap.synchronization.groupType=groupOfNames
    # The person type in LDAP
    - ALF_LDAP_SYNC_29=ldap.synchronization.personType=inetOrgPerson
    # The attribute in LDAP on group objects that defines the DN for its members
    - ALF_LDAP_SYNC_30=ldap.synchronization.groupMemberAttributeName=member
    # If true progress estimation is enabled. When enabled, the user query has to be run twice in order to count entries.
    - ALF_LDAP_SYNC_31=ldap.synchronization.enableProgressEstimation=true
    # Requests timeout, in miliseconds, use 0 for none (default)
    - ALF_LDAP_SYNC_32=ldap.authentication.java.naming.read.timeout=0


