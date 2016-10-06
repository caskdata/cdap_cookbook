#
# Cookbook Name:: cdap
# Recipe:: gateway
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

include_recipe 'cdap::default'

package 'cdap-gateway' do
  action :install
  version node['cdap']['version']
end

include_recipe 'cdap::ssl_keystore_certificates'

svcs = ['cdap-router']
unless node['cdap']['version'].to_f >= 2.6
  unless node['cdap']['version'].split('.')[2].to_i >= 9000
    svcs += ['cdap-gateway']
  end
end

svcs.each do |svc|
  attrib = svc.gsub('cdap-', '').tr('-', '_')
  template "/etc/init.d/#{svc}" do
    source 'cdap-service.erb'
    mode '0755'
    owner 'root'
    group 'root'
    action :create
    variables node['cdap'][attrib]
  end

  service svc do
    status_command "service #{svc} status"
    action node['cdap'][attrib]['init_actions']
  end
end
