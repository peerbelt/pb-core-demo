#!/bin/bash -x

ID_RSA=/home/ubuntu/.docker/machines/cd-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa
USER_DIR=/tmp


# Install Cassandra and Elastic Search images
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run -d --name pb_cassandra spotify/cassandra:latest'
scp -i $ID_RSA elasticsearch.tar root@`./docker-machine ip`:/tmp
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/elasticsearch.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run -d --name pb_elasticsearch peerbelt/elasticsearch'

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
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-saas-website -d -p 127.0.0.1:44445:80 peerbelt/pb-core-saas-website'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-console -d -p 127.0.0.1:44444:80 peerbelt/pb-core-console'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-console-api -d -p 127.0.0.1:33333:3000  peerbelt/pb-core-console-api'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-tracking-api -d -p 127.0.0.1:22222:3001 --link pb_cassandra:pb_cassandra peerbelt/pb-core-tracking-api'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-consumer-api -d -p 127.0.0.1:11111:3000 --link pb_elasticsearch:pb_elasticsearch peerbelt/pb-core-consumer-api'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run --name pb-core-digest -d --link pb_cassandra:pb_cassandra --link pb_elasticsearch:pb_elasticsearch peerbelt/pb-core-digest'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo service nginx restart'

# Create Team memebers accounts and get keys frm S3
scp -i $ID_RSA user-config.sh root@`./docker-machine ip`:/tmp
ssh -i $ID_RSA root@`./docker-machine ip` 'mkdir -p /root/.aws'
ssh -i $ID_RSA root@`./docker-machine ip` 'apt-get -y install awscli'
scp -i $ID_RSA config root@`./docker-machine ip`:/root/.aws/config
ssh -i $ID_RSA root@`./docker-machine ip` 'chmod 755 /tmp/user-config.sh'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo /tmp/user-config.sh'

#Configure iptables
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -j DROP'

# Start Papertrail
ssh -i ../.docker/machines/cd-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa root@`./docker-machine ip` 'sudo service remote_syslog start' 
# Clean up
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo sed -i s/PermitRootLogin\ yes/PermitRootLogin\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo service ssh restart'

