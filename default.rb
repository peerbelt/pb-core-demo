remote_directory "/var/data" do
  recursive
  owner "dimitar"
  group "dimitar"
  mode '0755'
  action :create
end
