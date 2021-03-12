#!/bin/bash
#
# A script to enable TCP BBR on a Linux system.
#
# @author Dumitru Uzun (DUzun.Me)
# @version 1.0.1
# @distro ArchLinux/Manjaro
#

old_cc=$(sysctl net.ipv4.tcp_congestion_control | awk -F= '{print $2}' | sed -e 's/\^\\s//')

echo "old tcp_congestion_control: $old_cc";

# if [[ $old_cc == "bbr" ]]; then
    # exit 0;
# fi

available_cc=$(sysctl net.ipv4.tcp_available_congestion_control)
if [[ $available_cc != *"bbr"* ]]; then
    sudo modprobe tcp_bbr
    available_cc=$(sysctl net.ipv4.tcp_available_congestion_control)
    if [[ $available_cc != *"bbr"* ]]; then
        echo "Looks like your kernel doesn't support BBR :-("
        exit 1;
    fi
fi

sudo sysctl net.ipv4.tcp_congestion_control=bbr && \
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/10-custom-kernel-bbr.conf && \
echo "net.core.default_qdisc=fq_codel" | sudo tee -a /etc/sysctl.d/10-custom-kernel-bbr.conf
