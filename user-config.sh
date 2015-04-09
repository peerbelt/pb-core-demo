#!/bin/bash -x 


export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Require aws cli to be installed
if [ "`which aws`" == "" ] ; then
        echo "AWS CLI is not installed, aborting!"
        exit 1
fi
# Check if lovethis-operations/users exists
if [ "`aws s3 ls s3://devops-peerbelt/user-keys`" == "" ] ; then
        echo "Users tree does not exist, aborting!"
        exit 1
fi

# Get tree from S3
aws s3 cp s3://devops-peerbelt/user-keys /tmp/peerbelt-users/ --recursive > /dev/null 2>&1;

if [ ! -d /tmp/peerbelt-users ] ; then
        echo "Users tree did not sync, aborting!"
        exit 1
fi

cd /tmp/peerbelt-users > /dev/null 2>&1

for DETAILS in `find -type f` ; do
        USERNAME=""
        GROUP=""
        ENVIRONMENT=""
        PASS=""
        KEY=""
        # Extract user account details
        USERNAME=`echo $DETAILS | cut -d '/' -f 2`
        GROUP=`echo $DETAILS | cut -d '/' -f 2`
        #Create a home directory for the user
        USER_HOME="/home/$USERNAME"
        mkdir -p $USER_HOME
        source $DETAILS
        #Check if the user exists
        if [ "`grep "$USERNAME" /etc/passwd`" != "" ]; then
                echo "User exists.";
                echo "Aborting...";
                exit 1;
        else 
                #Create the user and
                useradd -s /bin/bash -m $USERNAME -d /home/$USERNAME -p $PASS
                #Add user`s bublic key and configure it.
                if [ "$USER_HOME" != "" ] ; then
                        mkdir -p $USER_HOME/.ssh > /dev/null 2>&1
                        echo $KEY > $USER_HOME/.ssh/authorized_keys
                        chmod 600 $USER_HOME/.ssh/authorized_keys > /dev/null 2>&1
                        chown $USERNAME:$GROUP $USER_HOME/.ssh -R > /dev/null 2>&1
                fi
		#Set password hash
		if [ "$PASS" != "" ] ; then
			sed -i "s%^\($USERNAME:\)[^:]*\(:.*\)$%\1$PASS\2%g" /etc/shadow > /dev/null 2>&1
		fi
		#Add user to sudo group
		sudo adduser $USERNAME sudo;	
        fi               
done 

