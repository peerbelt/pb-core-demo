#!/usr/bin/env ruby

require rubygems;
require fog;

docker_id_rsa=i"/home/ubuntu/.docker/machines/cd-eu-peerbelt-#{ENV['CIRCLE_BUILD_NUM]}/id_rsa"

service = Fog::Storage.new({
    :provider            => 'Rackspace',         # Rackspace Fog provider
    :rackspace_username  => 'USER', # Your Rackspace Username
    :rackspace_api_key   => 'API_KEY',       # Your Rackspace API key
    :rackspace_region    => :'iad',                # Defaults to :dfw
    :connection_options  => {}                   # Optional
})

file = directory.files.create :key => '#{docker_id_rsa}', :body => File.open "id_rsa-#{ENV['CIRCLE_BUILD_NUM]}"
