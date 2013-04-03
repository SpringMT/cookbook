#
# Cookbook Name:: groonga
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

base_url = 'http://packages.groonga.org/centos/6/x86_64/Packages/'
version = node[:groonga][:version]
rpm_list = [
  'mecab-0.994-1.el6.x86_64.rpm',
  'mecab-ipadic-2.7.0.20070801-5.el6.1.x86_64.rpm',
  "groonga-libs-#{version}.el6.x86_64.rpm",
  "groonga-plugin-suggest-#{version}.el6.x86_64.rpm",
  "groonga-#{version}.el6.x86_64.rpm",
  "groonga-devel-#{version}.el6.x86_64.rpm",
  "groonga-tokenizer-mecab-#{version}.el6.x86_64.rpm"
]

directory '/tmp/chef-solo' do
  owner 'root'
  group 'root'
  mode '0755'
end

rpm_list.each do |rpm|
  remote_file "#{Chef::Config[:file_cache_path]}/#{rpm}" do
    source "#{base_url}#{rpm}"
    not_if "rpm -qa | egrep -qx #{rpm}"
    notifies :install, "rpm_package[#{rpm}]", :immediately
  end
  rpm_package "#{rpm}" do
    source "#{Chef::Config[:file_cache_path]}/#{rpm}"
    only_if {::File.exists?("#{Chef::Config[:file_cache_path]}/#{rpm}")}
    action :nothing
  end

  file "groonga-release-cleanup" do
    path "#{Chef::Config[:file_cache_path]}/#{rpm}"
    action :delete
  end
end


