# Manual Chef Workstation install

```
# Optional - user setup
# Add User
# Settings > Power > Blank Screen: None
# Prevent the screen from blanking
gsettings set org.gnome.desktop.session idle-delay 0
# Prevent the screen from locking
gsettings set org.gnome.desktop.screensaver lock-enabled false
# Display Resolution 1440 x 900 (16:10)
# Terminal > Preferences > Unnamed
#   Text > Uncheck Terminal bell
#   CZolors > Check "Show bold text in bright colors"
# passwordless sudo
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/dont-prompt-$USER-for-sudo-password"

Add user taylor

ssh-keygen -t ed25519 -C "crakeChefWorkstation"

sudo apt-get update
sudo apt-get install ca-certificates curl
curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -P cinc-workstation

## Install Nomachine

Install Nomachine for Linux -x86_64, amd64
https://downloads.nomachine.com/linux/?id=1
curl -LO https://download.nomachine.com/download/8.13/Linux/nomachine_8.13.1_1_amd64.deb

sudo dpkg -i nomachine*.deb
```

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker

sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

```
sudo apt-get update
sudo apt-get install openssh-server

mkdir -p $HOME/.nx/config
touch $HOME/.nx/config/authorized.crt
chmod 0600 $HOME/.nx/config/authorized.crt
tee -a $HOME/.nx/config/authorized.crt<<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBZjVID1mAqZyhD3p0VbJtidKAxMHUwLmEMaCAJX0UN mahowald
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINy9cJcJl8oN6bRtcBc4RZq8f/T6P1AFR3YS1YRYi5YY sheila
EOF

mkdir -p~/.ssh
tee -a $HOME/.ssh/authorized_keys<<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBZjVID1mAqZyhD3p0VbJtidKAxMHUwLmEMaCAJX0UN mahowald
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINy9cJcJl8oN6bRtcBc4RZq8f/T6P1AFR3YS1YRYi5YY sheila
EOF

sudo apt-get update
sudo apt-get install git

git config --global user.email taylor@xxx.com
git config --global user.name "Mischa Taylor"

mkdir -p ~/github/polymathrobotics
cd ~/github/polymathrobotics
git clone git@github.com:boxcutter/chef-cookbooks.git
git clone git@github.com:boxcutter/boxcutter-chef-cookbooks.git

sudo apt-get update
# required to build rugged for taste-tester
sudo apt-get install pkg-config
# required to build rugged extensions for taste-tester
sudo apt-get install cmake
# we need to install rugged with special openssl settings, or it will get
# linked against the system openssl and won't work properly
export OPENSSL_ROOT_DIR=/opt/cinc-workstation/embedded

$ eval "$(cinc shell-init bash)
$ which cinc
/opt/cinc-workstation/bin/cinc

cinc gem install taste_tester

/usr/local/etc/taste-tester
taste-tester-plugin.rb
taste-tester.conf

sudo mkdir -p /usr/local/etc/taste-tester
sudo cp ~/github/boxcutter/boxcutter-chef-cookbooks/cookbooks/boxcutter_chef/files/taste-tester/taste-tester-plugin.rb /usr/local/etc/taste-tester
sudo cp ~/github/boxcutter/boxcutter-chef-cookbooks/cookbooks/boxcutter_chef/files/taste-tester/taste-tester.conf /usr/local/etc/taste-tester

# taste-tester.conf
repo File.join(ENV['HOME'], 'github', 'boxcutter', 'boxcutter-chef-cookbooks')
repo_type 'auto'
base_dir ''
cookbook_dirs ['cookbooks', '../chef-cookbooks/cookbooks']
databag_dir 'data_bags'
role_dir 'roles'
role_type 'rb'
chef_config_path '/etc/chef'
chef_config 'client.rb'
ref_file "#{ENV['HOME']}/.chef-cache/scale-taste-tester-ref.json"
checksum_dir "#{ENV['HOME']}/.chef-cache/checksums"
chef_client_command '/usr/local/sbin/chefctl -i'
use_ssl false
use_ssh_tunnels true
ssh_command '/usr/bin/ssh -o StrictHostKeyChecking=no'
chef_zero_path '/opt/cinc-workstation/bin/cinc-zero'
chef_zero_logging true
user ENV['USER']
plugin_path '/usr/local/etc/taste-tester/taste-tester-plugin.rb'


taste-tester $@ -c taste-tester.conf

taste-tester test -s 100.96.49.59 -c /usr/local/etc/taste-tester/taste-tester.conf


vi cookbooks/...             # Make your changes and commit locally
taste-tester impact          # Check where your changes are used
taste-tester test -s [host]  # Put host in Taste Tester mode
ssh root@[host]              # Log in to host
  # Run chef and watch it break
vi cookbooks/...             # Fix your cookbooks
taste-tester upload          # Upload the diff
ssh root@[host]
  # Run chef and watch it succeed
<Verify your changes were actually applied as intended!>
taste-tester untest [host]   # Put host back in production
                             #   (optional - will revert itself after 1 hour)
```
