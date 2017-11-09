auth --enableshadow --passalgo=sha512
graphical
url --url=$tree
firstboot --enable
ignoredisk --only-use=sda
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8

#Network information
$SNIPPET('network_config')
timezone Asia/Shanghai --isUtc --nontp
rootpw  --iscrypted $default_password_crypted
user --groups=wheel --name=oldboy --password=$default_password_crypted --iscrypted --gecos="oldboy"
xconfig  --startxonboot
bootloader --location=mbr --boot-drive=sda
clearpart --none --initlabel
part /boot --fstype="xfs" --ondisk=sda --size=1024
part swap --fstype="swap" --ondisk=sda --size=1024
part / --fstype xfs --size 1 --grow
services --disabled="chronyd"
selinux --disabled
firewall --disabled
reboot

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
@^gnome-desktop-environment
@base
@compat-libraries
@core
@desktop-debugging
@development
@dial-up
@directory-client
@fonts
@gnome-desktop
@guest-agents
@guest-desktop-agents
@input-methods
@internet-browser
@java-platform
@multimedia
@network-file-system-client
@networkmanager-submodules
@print-client
@x11

tree
nmap
sysstat
lrzsz
dos2unix
bash-completion
telnet
iptraf
ncurses-devel
openssl-devel
zlib-devel
OpenIPMI-tools
screen

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'
systemctl disable postfix.service
%end
