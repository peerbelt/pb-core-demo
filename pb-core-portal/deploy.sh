#!/bin/bash

SHA1=$1

# Deploy image to private images repo. 

#echo thedpd | docker push thedpd/peerbelt

# Create new Elastic Beanstalk version
EB_BUCKET=devops-peerbelt
DOCKERRUN_FILE=Dockerrun.aws.json
#sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE
aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/docker/$DOCKERRUN_FILE
aws s3 cp Dockerfile s3://$EB_BUCKET/docker/Dockerfile
aws elasticbeanstalk create-environment  --application-name "My First Elastic Beanstalk Application" --environment-name TEST-$CIRCLE_BUILD_NUM --template-name pb-prod-config
aws elasticbeanstalk create-application-version --application-name "My First Elastic Beanstalk Application" --version-label $SHA1 --source-bundle S3Bucket=devops-peerbelt,S3Key=docker/Dockerrun.aws.json
#Create environtment takes a while, tha is why the below loop is necessary. Without it, the build will fail. 
         COUNTER=0
         while [  $COUNTER -lt 10 ]; do
             echo The counter is $COUNTER
             let COUNTER=COUNTER+1 
	     sleep 60;
         done
# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name TEST-$CIRCLE_BUILD_NUM --version-label $SHA1
