machine:
  node:
    version: 0.10.32
  python:
    version: 2.7.3
  ruby:
    version: 2.1.5
  services:
    - docker

dependencies:
  pre:
    - pip install awscli
    - wget https://github.com/docker/machine/releases/download/v0.1.0-rc5/docker-machine_linux-amd64
    - mv docker-machine_linux-amd64 docker-machine
    - chmod 755 docker-machine
    - sed -i "s/AWS_KEY/$AWS_ACCESS_KEY_ID/g" config
    - sed -i "s|AWS_SECRET|$AWS_SECRET_ACCESS_KEY|g" config
    - sed -i "s/USER/$OS_USERNAME/g" keys.rb
    - sed -i "s/API_KEY/$OS_API_KEY/g" keys.rb
    - ruby -v
    - gem install fog
  override:
    - docker info
    - aws s3 cp s3://devops-peerbelt/machines/CD/images/latest/pb-core-saas-website-latest.tar . 
    - aws s3 cp s3://devops-peerbelt/machines/CD/images/latest/pb-core-console-latest.tar .
    - aws s3 cp s3://devops-peerbelt/machines/CD/images/latest/pb-core-console-api-latest.tar . 
    - aws s3 cp s3://devops-peerbelt/machines/CD/images/latest/pb-core-tracking-api-latest.tar .
    - aws s3 cp s3://devops-peerbelt/machines/CD/images/latest/pb-core-consumer-api-latest.tar .
    - aws s3 cp s3://devops-peerbelt/machines/CD/images/latest/pb-core-digest-latest.tar .
    - aws s3 cp s3://devops-peerbelt/machines/CD/elasticsearch.tar .
    - docker load -i pb-core-saas-website-latest.tar
    - docker load -i pb-core-console-latest.tar

test:
  override:
    - docker run -d -p 44444:80 peerbelt/pb-core-saas-website
    - docker run -d -p 44445:80 peerbelt/pb-core-console
    - curl --retry 10 --retry-delay 5 -v http://localhost:44444
    - curl --retry 10 --retry-delay 5 -v http://localhost:44445

deployment:
    staging:
      branch: cd
      commands:
        # Creates the EC2 instance
        - ./docker-machine create --driver rackspace cd-eu-peerbelt-$CIRCLE_BUILD_NUM
        - cp $HOME/.docker/machines/cd-eu-peerbelt-$CIRCLE_BUILD_NUM/id_rsa id_rsa-$CIRCLE_BUILD_NUM
        # Pushes the machine private key to S3
        - aws s3 cp ../.docker/machines/cd-eu-peerbelt-$CIRCLE_BUILD_NUM/id_rsa s3://devops-peerbelt/ec2-keys/CD/id_rsa_$CIRCLE_BUILD_NUM 
        #Deploy service containers 
        - /bin/bash -x ./deploy.sh 
