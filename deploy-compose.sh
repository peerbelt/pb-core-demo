#!/bin/bash -x

SRV_STATUS=`slcli vs ready "sl-$CIRCLE_BUILD_NUM-web-wdc04" --wait=0`

until  [[ $SRV_STATUS == 'READY' ]]; do 
	sleep 60;
        SRV_STATUS=`slcli vs ready "sl-$CIRCLE_BUILD_NUM-web-wdc04" --wait=0`;
done   

ID_RSA=/home/ubuntu/pb-core-demo/id_rsa
USER_DIR=/home/peerbelt
SERVER_IP=`slcli vs list -H sl-$CIRCLE_BUILD_NUM-web-wdc04 | awk {'print $3'}`


# Create Team memebers accounts and get keys frm S3
ssh -i $ID_RSA root@$SERVER_IP 'apt-get update'
scp -i $ID_RSA user-config.sh root@$SERVER_IP:/tmp
ssh -i $ID_RSA root@$SERVER_IP 'mkdir -p /root/.aws'
ssh -i $ID_RSA root@$SERVER_IP 'apt-get -y install awscli'
scp -i $ID_RSA config root@$SERVER_IP:/root/.aws/config
ssh -i $ID_RSA root@$SERVER_IP 'chmod 755 /tmp/user-config.sh'
ssh -i $ID_RSA root@$SERVER_IP 'sudo /tmp/user-config.sh s3://devops-peerbelt/user-keys-rs/'
scp -i $ID_RSA rackspace_user root@$SERVER_IP:/etc/sudoers.d/rackspace_user
ssh -i $ID_RSA root@$SERVER_IP 'chmod 400 /etc/sudoers.d/rackspace_user'



# Copies the services and Nginx config to the new EC2
ssh -i $ID_RSA root@$SERVER_IP 'sudo mkdir -p /var/log/console-api/ /var/log/consumer/ /var/log/tracking-api /var/log/digest /var/data/console-api'
ssh -i $ID_RSA root@$SERVER_IP ' sudo rm -rf /etc/nginx/sites-enabled/default'
scp -i $ID_RSA pb-core-saas-website-latest.tar root@$SERVER_IP:/home/peerbelt
scp -i $ID_RSA pb-core-console-latest.tar root@$SERVER_IP:/home/peerbelt
scp -i $ID_RSA pb-core-console-api-latest.tar root@$SERVER_IP:/home/peerbelt
scp -i $ID_RSA pb-core-tracking-api-latest.tar root@$SERVER_IP:/home/peerbelt
scp -i $ID_RSA pb-core-consumer-api-latest.tar root@$SERVER_IP:/home/peerbelt
scp -i $ID_RSA pb-core-digest-latest.tar root@$SERVER_IP:/home/peerbelt
scp -i $ID_RSA pb_services.nginx root@$SERVER_IP:/home/peerbelt/pb_services.nginx
ssh -i $ID_RSA root@$SERVER_IP 'sudo mv /home/peerbelt/pb_services.nginx /etc/nginx/sites-available/pb_services.nqginx'
ssh -i $ID_RSA root@$SERVER_IP 'sudo  ln -s  /etc/nginx/sites-available/pb_services.nginx /etc/nginx/sites-enabled/pb_services.nginx'

# Starts the services

ssh -i $ID_RSA root@$SERVER_IP 'sudo docker load -i /home/peerbelt/pb-core-saas-website-latest.tar'
ssh -i $ID_RSA root@$SERVER_IP 'sudo docker load -i /home/peerbelt/pb-core-console-latest.tar'
ssh -i $ID_RSA root@$SERVER_IP 'sudo docker load -i /home/peerbelt/pb-core-console-api-latest.tar'
ssh -i $ID_RSA root@$SERVER_IP 'sudo docker load -i /home/peerbelt/pb-core-tracking-api-latest.tar'
ssh -i $ID_RSA root@$SERVER_IP 'sudo docker load -i /home/peerbelt/pb-core-consumer-api-latest.tar'
#ssh -i $ID_RSA root@$SERVER_IP 'sudo docker load -i /home/peerbelt/pb-core-digest-latest.tar'
ssh -i $ID_RSA root@$SERVER_IP 'curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'
ssh -i $ID_RSA root@$SERVER_IP 'sudo chmod +x /usr/local/bin/docker-compose'
scp -i $ID_RSA docker-compose.yml root@$SERVER_IP:/home/peerbelt
ssh -i $ID_RSA root@$SERVER_IP 'sudo docker-compose --file /home/peerbelt/docker-compose.yml up -d' 
ssh -i $ID_RSA root@$SERVER_IP 'sudo service nginx restart'

# Start Papertrail
#ssh -i ../.docker/machines/prod-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa root@`$SERVER_IP`  'sudo chmod 755 /etc/init.d/remote_syslog'
#ssh -i ../.docker/machines/prod-iad-peerbelt-$CIRCLE_BUILD_NUM/id_rsa root@`$SERVER_IP` 'sudo service remote_syslog start'

# Start NewRelic
scp -i $ID_RSA nrsysmond.cfg root@$SERVER_IP:/home/peerbelt
ssh -i $ID_RSA root@$SERVER_IP 'mv /home/peerbelt/nrsysmond.cfg /etc/newrelic/nrsysmond.cfg'
ssh -i $ID_RSA root@$SERVER_IP 'service newrelic-sysmond start'

#Configure iptables
ssh -i $ID_RSA root@$SERVER_IP 'iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@$SERVER_IP 'iptables -A INPUT -i eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@$SERVER_IP 'iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@$SERVER_IP 'iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT'
ssh -i $ID_RSA root@$SERVER_IP 'iptables -I INPUT 1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT'
ssh -i $ID_RSA root@$SERVER_IP 'iptables -A INPUT -i eth0 -j DROP'

# Restart containers, because ElasticSearch takes too long to start up:
#ssh -i $ID_RSA root@$SERVER_IP 'sleep 60; sudo docker-compose --file /home/peerbelt/docker-compose.yml restart consumerapi'
#ssh -i $ID_RSA root@$SERVER_IP 'sudo docker-compose --file /home/peerbelt/docker-compose.yml restart digest'

# Clean up
ssh -i $ID_RSA root@$SERVER_IP 'sudo sed -i s/PermitRootLogin\ Yes/PermitRootLogin\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@$SERVER_IP 'sudo sed -i s/\#PasswordAuthentication\ no/PasswordAuthentication\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@$SERVER_IP 'sudo sed -i s/UsePAM\ yes/UsePAM\ no/g /etc/ssh/sshd_config'
ssh -i $ID_RSA root@$SERVER_IP 'sudo service ssh restart'

