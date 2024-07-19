
```
cd kvm/ubuntu/x86_64
packer init .
PACKER_LOG=1 packer build \
  ubuntu.pkr.hcl
```

```
sudo qemu-img convert \
  -f qcow2 \
  -O qcow2 \
  chef-bootstrap-ubuntu2204.qcow2 \
  /var/lib/libvirt/images/ubuntu-server-2204.qcow2

virt-install \
  --connect qemu:///system \
  --name ubuntu-server-2204 \
  --boot uefi \
  --memory 4096 \
  --vcpus 2 \
  --os-variant ubuntu22.04 \
  --disk /var/lib/libvirt/images/ubuntu-server-2204.qcow2,bus=virtio \
  --network network=host-network,model=virtio \
  --graphics spice \
  --noautoconsole \
  --console pty,target_type=serial \
  --import \
  --debug

virsh console ubuntu-server-2204
# login with automat/superseekret

# Verify that cloud-init is done (wait until it shows "done" status)
$ cloud-init status
status: done

# Check networking - you may notice that the network interface is down and
# the name of the interface generated in netplan doesn't match. If not
# correct, can regenerate with cloud-init
$ ip --brief a

# Check to make sure cloud-init is greater than 23.4
$ cloud-init --version
/usr/bin/cloud-init 24.1.3-0ubuntu1~22.04.1

# Regenerate only the network config
$ sudo cloud-init clean --configs network
$ sudo cloud-init init --local
$ sudo reboot
```

```
sudo touch /root/firstboot_os
echo "{\"tier\": \"robot\"}" | sudo tee /etc/boxcutter-config.json > /dev/null
sudo chefctl -iv
```
