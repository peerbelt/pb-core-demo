#!/usr/bin/env ruby

require rubygems;
require fog;

docker_id_rsa="/home/ubuntu/.docker/machines/cd-eu-peerbelt-#{ENV['CIRCLE_BUILD_NUM]}/id_rsa"

file = Fog::Storage.new({
    :provider            => "Rackspace",
    :rackspace_username  => "USER",
    :rackspace_api_key   => "API_KEY",
    :rackspace_region    => "iad"
})

directory =  @file.directories.get("devops")

file = directory.files.create(
  :key => "machine-keys/#{docker_id_rsa}",
  :body => (File.open "#{docker_id_rsa}")
)

