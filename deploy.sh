#!/bin/bash -x

ID_RSA=/home/ubuntu/.docker/machines/cd-eu-peerbelt-$CIRCLE_BUILD_NUM/id_rsa
USER_DIR=/tmp


# Install Cassandra and Elastic Search images
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run -d --name pb_cassandra spotify/cassandra:latest'
scp -i $ID_RSA elasticsearch.tar root@`./docker-machine ip`:/tmp
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/elasticsearch.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run -d --name pb_elasticsearch -p 9200:9200 peerbelt/elasticsearch'

# Copies the services and Nginx config to the new EC2
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo apt-get install -y nginx; sudo rm -rf /etc/nginx/sites-enabled/default'
scp -i $ID_RSA pb-core-saas-website-latest.tar root@`./docker-machine ip`:/tmp
scp -i $ID_RSA pb-core-console-latest.tar root@`./docker-machine ip`:/tmp
scp -i $ID_RSA pb-core-console-api-latest.tar root@`./docker-machine ip`:/tmp
scp -i $ID_RSA pb-core-tracking-api-latest.tar root@`./docker-machine ip`:/tmp
scp -i $ID_RSA pb-core-consumer-api-latest.tar root@`./docker-machine ip`:/tmp
scp -i $ID_RSA pb-core-digest-latest.tar root@`./docker-machine ip`:/tmp
scp -i $ID_RSA pb_services.nginx root@`./docker-machine ip`:/tmp/pb_services.nginx
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo mv /tmp/pb_services.nginx /etc/nginx/sites-available/pb_services.nginx'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo  ln -s  /etc/nginx/sites-available/pb_services.nginx /etc/nginx/sites-enabled/pb_services.nginx'

# Starts the services
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/pb-core-saas-website-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/pb-core-console-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/pb-core-console-api-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/pb-core-tracking-api-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/pb-core-consumer-api-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/pb-core-digest-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-saas-website -d -p 44445:80 peerbelt/pb-core-saas-website'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-console -d -p 44444:80 peerbelt/pb-core-console'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-console-api -d -p 33333:3000  peerbelt/pb-core-console-api'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-tracking-api -d -p 22222:3001 --link pb_cassandra:pb_cassandra peerbelt/pb-core-tracking-api'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-consumer-api -d -p 11111:3000 --link pb_elasticsearch:pb_elasticsearch peerbelt/pb-core-consumer-api'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-digest -d --link pb_cassandra:pb_cassandra --link pb_elasticsearch:pb_elasticsearch peerbelt/pb-core-digest'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo service nginx restart'

# Create Team memebers accounts and get keys frm S3
scp -i $ID_RSA user-config.sh ubuntu@`./docker-machine ip`:/tmp
ssh -i $ID_RSA ubuntu@`./docker-machine ip` 'mkdir -p /home/ubuntu/.aws'
ssh -i $ID_RSA ubuntu@`./docker-machine ip` 'sudo apt-get -y install awscli'
scp -i $ID_RSA config ubuntu@`./docker-machine ip`:/home/ubuntu/.aws/config
ssh -i $ID_RSA ubuntu@`./docker-machine ip` 'chmod 755 /tmp/user-config.sh'
ssh -i $ID_RSA ubuntu@`./docker-machine ip` 'sudo /tmp/user-config.sh'
# Start Papertrail
#ssh -i ../.docker/machines/cd-eu-peerbelt-$CIRCLE_BUILD_NUM/id_rsa ubuntu@`./docker-machine ip` 'sudo service remote_syslog start' 
# Clean up
#ssh -i ../.docker/machines/cd-eu-peerbelt-$CIRCLE_BUILD_NUM/id_rsa ubuntu@`./docker-machine ip` 'sudo rm -rf /home/ubuntu/pb* '


