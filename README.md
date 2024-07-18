# bootstrap-chef
JEOS images for bootstrapping Chef

## Configuration

We don't use user-mode networking in production. Instead we use bridged
networking. These templates all assume that they are being built with 
bridged network.

To build these templates on an Ubuntu machine, edit `/etc/qemu/bridge.conf`
and add the line: `allow br0`.

Also run the following command to allow a non-root user to make use of `br0`
in packer builds:
`sudo chmod +s /usr/lib/qemu/qemu-bridge-helper`
