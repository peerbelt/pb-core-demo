FROM ubuntu:14.04
MAINTAINER Dimitar Damyanov <dimitar.damyanov@tumba.solutions>

#Install required packages
RUN     apt-get update  
RUN	apt-get install -y apt-utils 
RUN	apt-get install -y nodejs && apt-get install -y npm
RUN	apt-get install -y build-essential
RUN     apt-get install -y git
RUN	apt-get install -y nginx
RUN	apt-get install -y wget && apt-get install -y curl
RUN	npm install -g grunt-cli
RUN	npm install -g bower
RUN	service nginx stop
RUN     rm /etc/nginx/sites-enabled/default

#Copy portal directory onto the container. Configure Nginx. 
COPY    . /home/portal
COPY    portal.nginx /etc/nginx/sites-available/portal.nginx
RUN     ln -snf /etc/nginx/sites-available/portal.nginx /etc/nginx/sites-enabled/portal.nginx
RUN     echo "daemon off;" >> /etc/nginx/nginx.conf

#Set the default workibng directory
WORKDIR /home/portal

#Install the app
RUN 	sudo ln -s /usr/bin/nodejs /usr/bin/node 
RUN	npm install 
RUN	grunt dist

#Open port 80 to the host OS
EXPOSE  80
EXPOSE  443

#Start the app
CMD     ["service", "nginx", "start"]
