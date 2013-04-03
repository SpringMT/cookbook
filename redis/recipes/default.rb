#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2013, makoto.haruyama
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

tar_dir  = '/root/src'
redis_version = 'redis-2.6.7'
tar_file = "#{redis_version}.tar.gz"
tar_url = "http://redis.googlecode.com/files/#{tar_file}"
bin_dir = "/usr/local/bin"

remote_file "#{tar_dir}/#{tar_file}" do
  source tar_url
end

execute "Extract #{tar_file}" do
  cwd       tar_dir
  command   <<-COMMAND
    tar zxf #{tar_file}
  COMMAND

  creates   "#{tar_dir}/#{redis_version}/utils/redis_init_script"
end

execute "Build #{redis_version}" do
  cwd       "#{tar_dir}/#{redis_version}"
  command   %{make install}

  creates   "#{bin_dir}/redis-server"
end

group 'redis' do
  system true
end

user 'redis' do
  gid 'redis'
  home '/var/lib/redis'
  shell '/sbin/nologin'
  system true
end

%w{/var/run/redis /var/log/redis /var/lib/redis}.each do |dir|
  directory dir do
    owner 'redis'
    group 'redis'
    mode  '0755'
    recursive true
  end
end


template '/etc/init.d/redis' do
  source 'redis_init_script.erb'
  owner  'root'
  group  'root'
  mode   '0755'
end

template '/etc/redis.conf' do
  source 'redis.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
end


