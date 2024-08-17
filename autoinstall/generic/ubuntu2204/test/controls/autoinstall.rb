describe user('automat') do
  it { should exist }
  its('uid') { should eq 63112 }
  it { should belong_to_primary_group 'users' }
end

describe file('/etc/default/grub') do
  it { should exist }
  its('content') { should match /^GRUB_TIMEOUT=countdown$/ }
  its('content') { should match /^GRUB_TIMEOUT=30$/ }
  its('content') { should match /^GRUB_TERMINAL="console"$/ }
  its('content') { should match /^GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS4,115200n8"$/ }
  its('content') { should match /^GRUB_CMDLINE_LINUX="console=tty0 console=ttyS4,115200n8 systemd.wants=serial-getty@ttyS4"$/ }
end

%w(
  bzip2
  ca-certificates
  curl
  file
  jq
  lsb
  unzip
).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end
