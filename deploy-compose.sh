#!/bin/bash -x

ID_RSA=/home/ubuntu/.docker/machines/cd-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa
USER_DIR=/tmp


# Install Cassandra and Elastic Search images
scp -i $ID_RSA pb-cassandra-entrypoint.tar root@`./docker-machine ip`:/tmp
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/pb-cassandra-entrypoint.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run -d --name pb_cassandra peerbelt/cassandra'
scp -i $ID_RSA elasticsearch.tar root@`./docker-machine ip`:/tmp
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker load -i /tmp/elasticsearch.tar'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker run -d --name pb_elasticsearch peerbelt/elasticsearch'

# Copies the services and Nginx config to the new EC2
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo mkdir -p /var/log/console-api/ /var/log/consumer/ /var/log/tracking-api /var/log/digest'
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
ssh -i $ID_RSA root@`./docker-machine ip` 'curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo chmod +x /usr/local/bin/docker-compose'
scp -i $ID_RSA docker-compose.yml root@`./docker-machine ip`:/tmp
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo docker-compose --file /tmp/docker-compose.yml up -d' 
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo service nginx restart'

# Create Team memebers accounts and get keys frm S3
scp -i $ID_RSA user-config.sh root@`./docker-machine ip`:/tmp
ssh -i $ID_RSA root@`./docker-machine ip` 'mkdir -p /root/.aws'
ssh -i $ID_RSA root@`./docker-machine ip` 'apt-get -y install awscli'
scp -i $ID_RSA config root@`./docker-machine ip`:/root/.aws/config
ssh -i $ID_RSA root@`./docker-machine ip` 'chmod 755 /tmp/user-config.sh'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo /tmp/user-config.sh s3://devops-peerbelt/user-keys-rs/'
scp -i $ID_RSA rackspace_user root@`./docker-machine ip`:/etc/sudoers.d/rackspace_user
ssh -i $ID_RSA root@`./docker-machine ip` 'chmod 400 /etc/sudoers.d/rackspace_user'

# Start Papertrail
ssh -i ../.docker/machines/cd-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa root@`./docker-machine ip`  'sudo chmod 755 /etc/init.d/remote_syslog'
ssh -i ../.docker/machines/cd-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa root@`./docker-machine ip` 'sudo service remote_syslog start'

#Configure iptables
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -I INPUT 1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT'
ssh -i $ID_RSA root@`./docker-machine ip` 'iptables -A INPUT -i eth0 -j DROP'

# Clean up
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo sed -i s/PermitRootLogin\ yes/PermitRootLogin\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo sed -i s/PasswordAuthentication\ yes/PasswordAuthentication\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo sed -i s/UsePAM\ yes/UsePAM\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@`./docker-machine ip` 'sudo service ssh restart'

