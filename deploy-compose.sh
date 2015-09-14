#!/bin/bash -x

ID_RSA=/home/ubuntu/.docker/machines/cd-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa
USER_DIR=/home/peerbelt

# Create Team memebers accounts and get keys frm S3
scp -i $ID_RSA user-config.sh root@`./docker-machine ip`:/tmp
ssh -i $ID_RSA root@`./docker-machine ip` 'mkdir -p /root/.aws'
ssh -i $ID_RSA root@`./docker-machine ip` 'apt-get -y install awscli'
scp -i $ID_RSA config root@`./docker-machine ip`:/root/.aws/config
ssh -i $ID_RSA root@`./docker-machine ip` 'chmod 755 /tmp/user-config.sh'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo /tmp/user-config.sh s3://devops-peerbelt/user-keys-rs/'
scp -i $ID_RSA rackspace_user root@`./docker-machine ip`:/etc/sudoers.d/rackspace_user
ssh -i $ID_RSA root@`./docker-machine ip` 'chmod 400 /etc/sudoers.d/rackspace_user'


# Install Cassandra and Elastic Search images
scp -i $ID_RSA cassandra-single-sample.tar root@`./docker-machine ip`:/home/peerbelt
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /home/peerbelt/cassandra-single-sample.tar'
scp -i $ID_RSA elasticsearch-single-sample.tar root@`./docker-machine ip`:/home/peerbelt
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /home/peerbelt/elasticsearch-single-sample.tar'

# Copies the services and Nginx config to the new EC2
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo apt-get update'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo apt-get install -y nginx'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo mkdir -p /var/log/console-api/ /var/log/consumer/ /var/log/tracking-api /var/log/digest /var/data/console-api'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo apt-get install -y nginx; sudo rm -rf /etc/nginx/sites-enabled/default'
scp -i $ID_RSA pb-core-saas-website-latest.tar root@`./docker-machine ip`:/home/peerbelt
scp -i $ID_RSA pb-core-console-latest.tar root@`./docker-machine ip`:/home/peerbelt
scp -i $ID_RSA pb-core-console-api-latest.tar root@`./docker-machine ip`:/home/peerbelt
scp -i $ID_RSA pb-core-tracking-api-latest.tar root@`./docker-machine ip`:/home/peerbelt
scp -i $ID_RSA pb-core-consumer-api-latest.tar root@`./docker-machine ip`:/home/peerbelt
scp -i $ID_RSA pb-core-digest-latest.tar root@`./docker-machine ip`:/home/peerbelt
scp -i $ID_RSA pb_services.nginx root@`./docker-machine ip`:/home/peerbelt/pb_services.nginx
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo mv /home/peerbelt/pb_services.nginx /etc/nginx/sites-available/pb_services.nginx'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo  ln -s  /etc/nginx/sites-available/pb_services.nginx /etc/nginx/sites-enabled/pb_services.nginx'

# Starts the services

ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /home/peerbelt/pb-core-saas-website-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /home/peerbelt/pb-core-console-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /home/peerbelt/pb-core-console-api-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /home/peerbelt/pb-core-tracking-api-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /home/peerbelt/pb-core-consumer-api-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /home/peerbelt/pb-core-digest-latest.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo chmod +x /usr/local/bin/docker-compose'
#scp -i $ID_RSA docker-compose-cassandra-elastic.yml root@`./docker-machine ip`:/home/peerbelt
scp -i $ID_RSA docker-compose.yml root@`./docker-machine ip`:/home/peerbelt
#ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker-compose --file docker-compose-cassandra-elastic.yml up -d'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker-compose --file /home/peerbelt/docker-compose.yml up -d' 
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo service nginx restart'

# Start Papertrail
ssh -i ../.docker/machines/cd-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa root@`./docker-machine ip`  'sudo chmod 755 /etc/init.d/remote_syslog'
ssh -i ../.docker/machines/cd-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa root@`./docker-machine ip` 'sudo service remote_syslog start'

# Start NewRelic
scp -i $ID_RSA nrsysmond.cfg root@`./docker-machine ip`:/home/peerbelt
ssh -i $ID_RSA root@`./docker-machine ip` 'mv /home/peerbelt/nrsysmond.cfg /etc/newrelic/nrsysmond.cfg'
ssh -i $ID_RSA root@`./docker-machine ip` 'service newrelic-sysmond start'

#Configure iptables
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -I INPUT 1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -j DROP'

# Restart containers, because ElasticSearch takes too long to start up:
ssh -i $ID_RSA root@`./docker-machine ip` 'sleep 60; sudo docker-compose --file /home/peerbelt/docker-compose.yml restart consumerapi'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker-compose --file /home/peerbelt/docker-compose.yml restart digest'

# Clean up
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo sed -i s/PermitRootLogin\ yes/PermitRootLogin\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo sed -i s/PasswordAuthentication\ yes/PasswordAuthentication\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo sed -i s/UsePAM\ yes/UsePAM\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo service ssh restart'

