#
# Cookbook Name:: cdap
# Recipe:: web_app
#
# Copyright © 2013-2016 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# web_app is deprecated in favor of ui in CDAP 3.0
if node['cdap']['version'].to_i > 2
  include_recipe 'cdap::ui'
else
  include_recipe 'nodejs::default'
  link '/usr/bin/node' do
    to '/usr/local/bin/node'
    action :create
    not_if 'test -e /usr/bin/node'
  end

  include_recipe 'cdap::repo'

  package 'cdap-web-app' do
    action :install
    version node['cdap']['version']
  end

  include_recipe 'cdap::ssl_keystore_certificates'

  template '/etc/init.d/cdap-web-app' do
    source 'cdap-service.erb'
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    variables node['cdap']['web_app']
  end

  service 'cdap-web-app' do
    status_command 'service cdap-web-app status'
    action node['cdap']['web_app']['init_actions']
  end
end
