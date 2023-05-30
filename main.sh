#!/bin/sh
# Declare Paths
SYS_PATH="/etc/sysctl.conf"
LIM_PATH="/etc/security/limits.conf"
PROF_PATH="/etc/profile"
SSH_PATH="/etc/ssh/sshd_config"
DNS_PATH="/etc/resolv.conf"
# Fix DNS
fix_dns() {
  echo 
  echo "$(tput setaf 3)----- JOON CHE SERVERI.$(tput sgr0)"
  echo 
  sleep 1
  echo 
  echo "$(tput setaf 3)----- Optimizing System DNS Settings.$(tput sgr0)"
  echo 
  sleep 1

  sed -i '/nameserver/d' $DNS_PATH
  
  echo 'nameserver 8.8.8.8' >> $DNS_PATH
  echo 'nameserver 8.8.4.4' >> $DNS_PATH
  
  echo 
  echo "$(tput setaf 2)----- System DNS Optimized.$(tput sgr0)"
  echo
  sleep 1
}


# Update & Upgrade & Remove & Clean
complete_update() {
  echo 
  echo "$(tput setaf 3)----- Updating the System.$(tput sgr0)"
  echo 
  sleep 1

  sudo apt update
  sudo apt -y upgrade
  sleep 0.5
  sudo apt -y dist-upgrade
  sudo apt -y autoremove
  sudo apt -y autoclean
  sudo apt -y clean
  echo 
  echo "$(tput setaf 2)----- System Updated Successfully.$(tput sgr0)"
  echo 
  sleep 1
}


## Install useful packages
installations() {
  echo 
  echo "$(tput setaf 3)----- Installing Useful Packeges.$(tput sgr0)"
  echo 
  sleep 1

  # Purge firewalld to install UFW.
  sudo apt -y purge firewalld

  # Install
  sudo apt -y install software-properties-common build-essential apt-transport-https iptables iptables-persistent lsb-release ca-certificates ubuntu-keyring gnupg2 apt-utils cron bash-completion 
  sudo apt -y install curl git zip unzip ufw wget preload locales nano vim python3 python3-pip jq qrencode socat busybox net-tools haveged htop libssl-dev libsqlite3-dev dialog
  sudo apt -y install binutils make automake autoconf libtool btop
  sleep 0.5
  echo "$(tput setaf 2)----- Installing Soga.$(tput sgr0)"
  bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
  sleep 1
  echo 
  echo "$(tput setaf 2)----- Useful Packages Installed Succesfully.$(tput sgr0)"
  echo 
  sleep 0.5
}


# Enable packages at server boot
enable_packages() {
  sudo systemctl enable preload haveged cron
  echo 
  echo "$(tput setaf 2)----- Packages Enabled Succesfully.$(tput sgr0)"
  echo
  sleep 0.5
}


## Swap Maker
swap_maker() {
  echo 
  echo "$(tput setaf 3)----- Making SWAP Space.$(tput sgr0)"
  echo 
  sleep 1

  # 2 GB Swap Size
  SWAP_SIZE=3G

  # Default Swap Path
  SWAP_PATH="/swapfile"

  # Make Swap
  sudo fallocate -l $SWAP_SIZE $SWAP_PATH  # Allocate size
  sudo chmod 600 $SWAP_PATH                # Set proper permission
  sudo mkswap $SWAP_PATH                   # Setup swap         
  sudo swapon $SWAP_PATH                   # Enable swap
  echo "$SWAP_PATH   none    swap    sw    0   0" >> /etc/fstab # Add to fstab
  echo 
  echo $(tput setaf 2)----- SWAP Created Successfully.$(tput sgr0)
  echo
  sleep 0.5
  
}


# Remove Old SYSCTL Config to prevent duplicates.
remove_old_sysctl() {
  sed -i '/fs.file-max/d' $SYS_PATH
  sed -i '/fs.inotify.max_user_instances/d' $SYS_PATH

  sed -i '/net.ipv4.tcp_syncookies/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_fin_timeout/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_tw_reuse/d' $SYS_PATH
  sed -i '/net.ipv4.ip_local_port_range/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_max_syn_backlog/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_max_tw_buckets/d' $SYS_PATH
  sed -i '/net.ipv4.route.gc_timeout/d' $SYS_PATH

  sed -i '/net.ipv4.tcp_syn_retries/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_synack_retries/d' $SYS_PATH
  sed -i '/net.core.somaxconn/d' $SYS_PATH
  sed -i '/net.core.netdev_max_backlog/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_timestamps/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_max_orphans/d' $SYS_PATH
  sed -i '/net.ipv4.ip_forward/d' $SYS_PATH

  #IPv6
  sed -i '/net.ipv6.conf.all.disable_ipv6/d' $SYS_PATH
  sed -i '/net.ipv6.conf.default.disable_ipv6/d' $SYS_PATH
  sed -i '/net.ipv6.conf.all.forwarding/d' $SYS_PATH
  # System Limits.

  sed -i '/soft/d' $LIM_PATH
  sed -i '/hard/d' $LIM_PATH

  # BBR
  sed -i '/net.core.default_qdisc/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_congestion_control/d' $SYS_PATH
  sed -i '/net.ipv4.tcp_ecn/d' $SYS_PATH

  # uLimit
  sed -i '/1000000/d' $PROF_PATH

  #SWAP
  sed -i '/vm.swappiness/d' $SYS_PATH
  sed -i '/vm.vfs_cache_pressure/d' $SYS_PATH
}


## SYSCTL Optimization
sysctl_optimizations() {
  echo 
  echo "$(tput setaf 3)----- Optimizing the Network.$(tput sgr0)"
  echo 
  sleep 1
  # Optimize Swap Settings
  echo 'vm.swappiness=10' >> $SYS_PATH
  echo 'vm.vfs_cache_pressure=50' >> $SYS_PATH
  echo 'vm.dirty_ratio = 30' >> $SYS_PATH
  echo 'vm.dirty_background_ratio = 2' >> $SYS_PATH
  sleep 0.5


  echo 'fs.file-max = 6553560' >> $SYS_PATH
  echo 'net.ipv4.ip_local_port_range = 1024 65535' >> $SYS_PATH
  echo 'net.ipv4.tcp_synack_retries=3' >> $SYS_PATH
  echo 'net.ipv4.neigh.default.gc_stale_time = 120' >> $SYS_PATH
  echo 'net.ipv4.netfilter.ip_conntrack_tcp_timeout_syn_recv = 3' >> $SYS_PATH
  echo 'net.ipv4.netfilter.ip_conntrack_tcp_timeout_syn_sent = 10' >> $SYS_PATH
  echo 'net.ipv4.tcp_ecn = 0' >> $SYS_PATH
  echo 'net.core.rmem_default = 2097152' >> $SYS_PATH
  echo 'net.core.rmem_max = 8388608' >> $SYS_PATH
  echo 'net.core.rmem_max = 134217728' >> $SYS_PATH
  echo 'net.core.wmem_max = 134217728' >> $SYS_PATH
  echo 'net.ipv4.tcp_syncookies = 1' >> $SYS_PATH
  echo 'net.ipv4.tcp_low_latency = 1' >> $SYS_PATH
  echo 'net.ipv4.tcp_fin_timeout = 10' >> $SYS_PATH
  echo 'net.ipv4.tcp_sack = 1' >> $SYS_PATH
  echo 'net.ipv4.tcp_fack = 1' >> $SYS_PATH
  echo 'net.ipv4.tcp_syn_retries = 3' >> $SYS_PATH
  echo 'net.ipv4.tcp_fastopen = 3' >> $SYS_PATH
  echo 'net.ipv4.tcp_mtu_probing = 1' >> $SYS_PATH
  echo 'net.core.netdev_max_backlog = 250000' >> $SYS_PATH
  echo 'net.ipv4.tcp_max_syn_backlog = 4096' >> $SYS_PATH
  echo 'net.ipv4.tcp_max_tw_buckets = 5000' >> $SYS_PATH
  echo 'net.ipv4.tcp_timestamps = 1' >> $SYS_PATH
  echo 'net.core.somaxconn = 4096' >> $SYS_PATH
  echo 'net.ipv4.tcp_tw_recycle=1' >> $SYS_PATH
  echo 'net.ipv4.conf.all.rp_filter = 0' >> $SYS_PATH
  echo 'net.ipv4.tcp_reordering=3' >> $SYS_PATH
  echo 'net.ipv4.tcp_rmem = 4096 87380 67108864' >> $SYS_PATH
  echo 'net.ipv4.tcp_wmem = 4096 65536 67108864' >> $SYS_PATH
  echo 'net.ipv4.tcp_retries2 = 8' >> $SYS_PATH
  echo 'net.ipv4.tcp_slow_start_after_idle = 0' >> $SYS_PATH
  echo 'net.ipv4.ip_forward = 1' | tee -a $SYS_PATH
  echo 'tcp_keepalive_time=1800' >> $SYS_PATH
  echo 'tcp_max_syn_backlog=1500' >> $SYS_PATH
  echo 'tcp_keepalive_probes=5' >> $SYS_PATH
  echo 'tcp_keepalive_intvl=60' >> $SYS_PATH
  echo 'tcp_fin_timeout=60' >> $SYS_PATH
  echo 'net.ipv4.conf.lo.arp_announce = 2' >> $SYS_PATH
  echo 'net.ipv4.conf.all.arp_announce = 2' >> $SYS_PATH
  echo 'net.ipv4.conf.default.arp_announce = 2' >> $SYS_PATH
  echo 'net.ipv4.tcp_max_orphans=4096' >> $SYS_PATH
  echo 'net.ipv6.conf.all.disable_ipv6 = 0' >> $SYS_PATH
  echo 'net.ipv6.conf.default.disable_ipv6 = 0' >> $SYS_PATH
  echo 'net.ipv6.conf.all.forwarding = 1' >> $SYS_PATH
  echo 'net.core.default_qdisc = fq' >> $SYS_PATH
  echo 'net.ipv4.tcp_congestion_control = bbr' >> $SYS_PATH
  echo 'net.ipv4.tcp_tw_reuse = 1' >> $SYS_PATH
  echo 'net.ipv4.tcp_window_scaling=1' >> $SYS_PATH
  echo 'net.ipv4.tcp_abort_on_overflow = 1' >> $SYS_PATH
  echo 'net.ipv4.ip_conntrack_max = 750000' >> $SYS_PATH
  echo 'net.nf_conntrack_max = 750000' >> $SYS_PATH
  echo 'net.ipv4.tcp_mem = 786432 1048576 1572864' >> $SYS_PATH
  sysctl -p
  echo 
  echo $(tput setaf 2)----- Network is Optimized.$(tput sgr0)
  echo 
  sleep 0.5
}


# Remove old SSH config to prevent duplicates.
remove_old_ssh_conf() {
  # Make a backup of the original sshd_config file
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  echo 
  echo "$(tput setaf 2)----- Default SSH Config file Saved. Directory: /etc/ssh/sshd_config.bak$(tput sgr0)"
  echo 
  sleep 1
  
  # Disable DNS lookups for connecting clients
  sed -i 's/#UseDNS yes/UseDNS no/' $SSH_PATH

  # Enable compression for SSH connections
  sed -i 's/#Compression no/Compression yes/' $SSH_PATH

  # Remove less efficient encryption ciphers
  sed -i 's/Ciphers .*/Ciphers aes256-ctr,chacha20-poly1305@openssh.com/' $SSH_PATH

  # Remove these lines
  sed -i '/MaxAuthTries/d' $SSH_PATH
  sed -i '/MaxSessions/d' $SSH_PATH
  sed -i '/TCPKeepAlive/d' $SSH_PATH
  sed -i '/ClientAliveInterval/d' $SSH_PATH
  sed -i '/ClientAliveCountMax/d' $SSH_PATH
  sed -i '/AllowAgentForwarding/d' $SSH_PATH
  sed -i '/PermitRootLogin/d' $SSH_PATH
  sed -i '/AllowTcpForwarding/d' $SSH_PATH
  sed -i '/GatewayPorts/d' $SSH_PATH
  sed -i '/PermitTunnel/d' $SSH_PATH

}


## Update SSH config
update_sshd_conf() {
  echo 
  echo "$(tput setaf 3)----- Optimizing SSH.$(tput sgr0)"
  echo 
  sleep 1

  # Enable TCP keep-alive messages
  echo "TCPKeepAlive yes" | tee -a $SSH_PATH

  # Configure client keep-alive messages
  echo "ClientAliveInterval 3000" | tee -a $SSH_PATH
  echo "ClientAliveCountMax 100" | tee -a $SSH_PATH

  # Allow agent forwarding
  echo "AllowAgentForwarding yes" | tee -a $SSH_PATH

  #Permit Root Login
  echo "PermitRootLogin yes" | tee -a $SSH_PATH

  # Allow TCP forwarding
  echo "AllowTcpForwarding yes" | tee -a $SSH_PATH

  # Enable gateway ports
  echo "GatewayPorts yes" | tee -a $SSH_PATH

  # Enable tunneling
  echo "PermitTunnel yes" | tee -a $SSH_PATH

  # Restart the SSH service to apply the changes
  service ssh restart

  echo 
  echo $(tput setaf 2)----- SSH is Optimized.$(tput sgr0)
  echo 
}


# System Limits Optimizations
limits_optimizations() {
  echo
  echo "$(tput setaf 3)----- Optimizing System Limits.$(tput sgr0)"
  echo 
  sleep 1

  echo '* soft     nproc          655350' >> $LIM_PATH
  echo '* hard     nproc          655350' >> $LIM_PATH
  echo '* soft     nofile         655350' >> $LIM_PATH
  echo '* hard     nofile         655350' >> $LIM_PATH

  echo 'root soft     nproc          655350' >> $LIM_PATH
  echo 'root hard     nproc          655350' >> $LIM_PATH
  echo 'root soft     nofile         655350' >> $LIM_PATH
  echo 'root hard     nofile         655350' >> $LIM_PATH

  sudo sysctl -p
  echo 
  echo $(tput setaf 2)----- System Limits Optimized.$(tput sgr0)
  echo 
  sleep 0.5
}


# RUN BABY, RUN

fix_dns
sleep 0.5

complete_update
sleep 0.5

installations
sleep 0.5

enable_packages
sleep 0.5

swap_maker
sleep 0.5

remove_old_sysctl
sleep 0.5

sysctl_optimizations
sleep 0.5

remove_old_ssh_conf
sleep 0.5

update_sshd_conf
sleep 0.5

limits_optimizations
sleep 1



# Outro
echo 
echo $(tput setaf 2)=========================$(tput sgr0)
echo "$(tput setaf 2)----- Done! Server is Optimized.$(tput sgr0)"
echo "$(tput setaf 3)----- Reboot in 5 seconds...$(tput sgr0)"
echo $(tput setaf 2)=========================$(tput sgr0)
sudo sleep 5 ; shutdown -r 0
echo 
echo 
echo
