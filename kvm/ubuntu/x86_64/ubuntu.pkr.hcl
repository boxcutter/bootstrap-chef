packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "efi_boot" {
  type    = bool
  default = true
}

variable "efi_firmware_code" {
  type    = string
  default = "/usr/share/OVMF/OVMF_CODE.fd"
}

variable "efi_firmware_vars" {
  type    = string
  default = "/usr/share/OVMF/OVMF_VARS.fd"
}

variable "ssh_username" {
  type    = string
  default = "automat"
}

variable "ssh_password" {
  type    = string
  default = "superseekret"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-22.04-x86_64"
}

source "file" "user_data" {
  content = <<EOF
#cloud-config
users:
  - name: ${var.ssh_username}
    plain_text_passwd: ${var.ssh_password}
    uid: 63112
    primary_group: users
    groups: users
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
chpasswd: { expire: False }
ssh_pwauth: True
EOF
  target  = "boot-${var.vm_name}/user-data"
}

source "file" "meta_data" {
  content = <<EOF
instance-id: ubuntu-cloud
local-hostname: ubuntu-cloud
EOF
  target  = "boot-${var.vm_name}/meta-data"
}

build {
  sources = ["sources.file.user_data", "sources.file.meta_data"]

  provisioner "shell-local" {
    inline = ["genisoimage -output boot-${var.vm_name}/cidata.iso -input-charset utf-8 -volid cidata -joliet -r boot-${var.vm_name}/user-data boot-${var.vm_name}/meta-data"]
  }
}

variable "iso_checksum" {
  type    = string
  default = "file:http://cloud-images.ubuntu.com/releases/22.04/release/SHA256SUMS"
}

variable "iso_url" {
  type    = string
  default = "http://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

source "qemu" "ubuntu" {
  disk_compression = true
  disk_image       = true
  disk_size        = "16G"
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  qemuargs = [
    ["-cdrom", "boot-${var.vm_name}/cidata.iso"]
  ]
  output_directory  = "output-${var.vm_name}"
  shutdown_command  = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_password      = var.ssh_password
  ssh_timeout       = "120s"
  ssh_username      = var.ssh_username
  vm_name           = "${var.vm_name}.qcow2"
  efi_boot          = var.efi_boot
  efi_firmware_code = var.efi_firmware_code
  efi_firmware_vars = var.efi_firmware_vars
  machine_type      = "q35"
  memory            = 4096
  cpus              = 2 
  net_bridge        = "br0"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
}

build {
  sources = ["source.qemu.ubuntu"]

  # cloud-init may still be running when we start executing scripts
  # To avoid race conditions, make sure cloud-init is done first
  provisioner "shell" {
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts = [
      "../scripts/cloud-init-wait.sh",
    ]
  }

  provisioner "shell" {
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "../scripts/disable-updates.sh",
      "../scripts/qemu.sh",
      "../scripts/clear-machine-information.sh"
    ]
  }
}
