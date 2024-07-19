#!/bin/bash -eux

# chefctl uses a shebang that points at /opt/chef, so make sure we have a link
# in place for compatibility
mkdir -p /etc/cinc
# /etc/chef -> /etc/cinc
ln -snf /etc/cinc /etc/chef

curl -L https://omnitruck.cinc.sh/install.sh | bash

# /opt/chef -> /opt/cinc
ln -snf /opt/cinc /opt/chef

apt-get update
apt-get install unzip
curl -o /tmp/op.zip https://cache.agilebits.com/dist/1P/op2/pkg/v2.29.0/op_linux_amd64_v2.29.0.zip
unzip /tmp/op.zip op -d /usr/local/bin/
rm -f /tmp/op.zip

tee /etc/cinc/client-prod.rb <<EOF
local_mode true
chef_repo_path '/var/chef/repos/boxcutter-chef-cookbooks'
cookbook_path ['/var/chef/repos/chef-cookbooks/cookbooks', '/var/chef/repos/boxcutter-chef-cookbooks/cookbooks']
follow_client_key_symlink true
client_fork false
no_lazy_load false
local_key_generation true
json_attribs '/etc/cinc/run-list.json'
ohai.critical_plugins ||= []
ohai.critical_plugins += [:Passwd]
ohai.optional_plugins ||= []
ohai.optional_plugins += [:Passwd]
EOF

openssl genrsa -out /etc/cinc/client-prod.pem
openssl genrsa -out /etc/cinc/validation.pem

ln -sf /etc/cinc/client-prod.rb /etc/chef/client.rb
ln -sf /etc/cinc/client-prod.pem /etc/chef/client.pem

# tee /etc/chef/chefctl_hooks.rb <<EOF
# EOF
curl -o /etc/chef/chefctl_hooks.rb https://raw.githubusercontent.com/boxcutter/boxcutter-chef-cookbooks/main/cookbooks/boxcutter_chef/files/chefctl/chefctl_hooks.rb

# tee /etc/chefctl-config.rb <<EOF
# chef_client '/opt/cinc/bin/cinc-client'
# chef_options ['--no-fork']
# log_dir '/var/log/chef'
# EOF
curl -o /etc/chefctl-config.rb https://raw.githubusercontent.com/boxcutter/boxcutter-chef-cookbooks/main/cookbooks/boxcutter_chef/files/chefctl/chefctl-config.rb

tee /etc/chef/run-list.json <<EOF
{
  "run_list" : [
    "recipe[boxcutter_ohai]",
    "recipe[boxcutter_init]"
  ]
}
EOF

mkdir -p /var/chef /var/chef/repos /var/log/chef
# cd /var/chef/repos
# git clone https://github.com/boxcutter/chef-cookbooks.git \
#   /var/chef/repos/chef-cookbooks
# git clone https://github.com/boxcutter/boxcutter-chef-cookbooks.git \
#   /var/chef/repos/boxcutter-chef-cookbooks


mkdir -p /usr/local/sbin
# curl -o /usr/local/sbin/chefctl.rb https://raw.githubusercontent.com/facebook/chef-utils/main/chefctl/src/chefctl.rb
curl -o /usr/local/sbin/chefctl.rb https://raw.githubusercontent.com/boxcutter/boxcutter-chef-cookbooks/main/cookbooks/boxcutter_chef/files/chefctl/chefctl.rb
chmod +x /usr/local/sbin/chefctl.rb
ln -sf /usr/local/sbin/chefctl.rb /usr/local/sbin/chefctl
