#!/usr/bin/env ruby

require 'rubygems';
require 'fog';

docker_id_rsa = 'id_rsa-#{ENV['CIRCLE_BUILD_NUM]'}'

@file = Fog::Storage.new(
  :provider => 'rackspace',
  :rackspace_username => 'USER',
  :rackspace_api_key => 'API_KEY',
  :rackspace_region => 'iad'
)

directory = @file.directories.get('devops')

file = directory.files.create(
  :key => 'machine-keys/#{docker_id_rsa}',
  :body => (File.open '#{docker_id_rsa}')
)
