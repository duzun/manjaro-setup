#!/bin/bash

#
# Hardware-specific setup for Lenovo Yoga Slim 7 14IMH9
# Intel Core Ultra 7 155H (Meteor Lake) + Intel Arc Graphics
#
# 14" 2880x1800 OLED Touch, 32GB RAM, Intel AX211 Wi-Fi 6E
#
# Run after manjaro_install_apps.sh / manjaro_install_cli.sh
#
# @author Dumitru Uzun (DUzun.me)
#

_i_='sudo pacman -S --needed --noconfirm'

# --- Intel Arc Graphics (Meteor Lake iGPU) ---
# VA-API hardware video acceleration
$_i_ intel-media-driver    # VAAPI driver for Broadwell+ (includes Meteor Lake)
$_i_ libva-intel-driver    # Legacy VA-API (fallback)
$_i_ libva-utils           # Verification tools (vainfo)

# Intel GPU monitoring
$_i_ intel-gpu-tools        # intel_gpu_top

# VPL (Video Processing Library) for hardware encode/decode
$_i_ libvpl
$_i_ vpl-gpu-rt

# --- Intel Xe GPU driver (force over i915) ---
# Detect Intel GPU PCI device ID (e.g. 7d55 for Meteor Lake-P Arc)
gpu_id=$(lspci -nn 2>/dev/null | grep -i 'vga.*intel' | grep -oP '8086:\K[0-9a-f]+')
if [ -z "$gpu_id" ]; then
    echo "Warning: Could not detect Intel GPU PCI ID, defaulting to 7d55"
    gpu_id="7d55"
fi
echo "Detected Intel GPU PCI ID: $gpu_id"

# In /etc/mkinitcpio.conf, MODULES=(xe) ensures early loading
if ! grep -q '^MODULES=.*\bxe\b' /etc/mkinitcpio.conf; then
    echo ""
    echo ">>> Add 'xe' to MODULES in /etc/mkinitcpio.conf, then run:"
    echo "    sudo mkinitcpio -P"
    echo ""
fi

# GRUB: force xe driver, disable i915 for this GPU
grub_file=/etc/default/grub
grub_updated=0
if [ -f "$grub_file" ]; then
    if ! grep -q "xe.force_probe=$gpu_id" "$grub_file"; then
        echo ""
        echo ">>> Add to GRUB_CMDLINE_LINUX_DEFAULT in $grub_file:"
        echo "    i915.force_probe=!$gpu_id xe.force_probe=$gpu_id"
        echo ""
        grub_updated=1
    fi

    # intel_pstate=passive: let kernel (schedutil) control CPU scaling
    # instead of aggressive HWP "race to idle" on hybrid P/E/LP-E cores
    if ! grep -q 'intel_pstate=passive' "$grub_file"; then
        echo ""
        echo ">>> Add to GRUB_CMDLINE_LINUX_DEFAULT in $grub_file:"
        echo "    intel_pstate=passive"
        echo ""
        grub_updated=1
    fi

    # zswap: compress RAM pages before hitting SSD swap
    if ! grep -q 'zswap.enabled=1' "$grub_file"; then
        echo ""
        echo ">>> Add to GRUB_CMDLINE_LINUX_DEFAULT in $grub_file:"
        echo "    zswap.enabled=1 zswap.max_pool_percent=33"
        echo ""
        grub_updated=1
    fi

    if [ "$grub_updated" = 1 ]; then
        echo ">>> After editing, run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    fi
fi

# --- Intel NPU (AI Boost) & Compute ---
# Level Zero API for oneAPI (GPU compute, NPU access)
$_i_ intel-compute-runtime
$_i_ level-zero-loader
$_i_ level-zero-headers

# Verify NPU is available: ls /dev/accel/
if [ -c /dev/accel/accel0 ]; then
    echo "Intel NPU (AI Boost) detected at /dev/accel/accel0"
else
    echo "Warning: Intel NPU device not found at /dev/accel/"
fi

# --- Audio (Intel SOF - Sound Open Firmware) ---
$_i_ sof-firmware
$_i_ alsa-ucm-conf

# --- Power Management ---
# TLP: advanced laptop power management
$_i_ tlp tlp-rdw
sudo systemctl enable tlp

# thermald: Intel thermal management daemon
$_i_ thermald
sudo systemctl enable thermald

# --- CPU Scaling ---
# cpupower: for verifying/setting CPU governor & EPP
$_i_ cpupower

# irqbalance: distribute hardware interrupts across E-cores
# Keeps P-cores free and reduces thermal spikes from SSHFS/NVMe IRQs
$_i_ irqbalance
sudo systemctl enable irqbalance

# --- Lenovo Battery Conservation Mode ---
# Caps charging at ~80% to extend battery lifespan
# 0 = disabled, 1 = enabled
conservation_mode=/sys/bus/platform/drivers/ideapad_acpi/VPC*/conservation_mode
if ls $conservation_mode 1>/dev/null 2>&1; then
    echo ""
    echo "Lenovo battery conservation mode available."
    echo "To enable (cap charge at ~80%):"
    echo "    echo 1 | sudo tee $conservation_mode"
    echo "To disable (charge to 100%):"
    echo "    echo 0 | sudo tee $conservation_mode"
    echo ""
    echo "TLP can manage this automatically via CONSERVATION_MODE in /etc/tlp.d/"
fi

# --- Summary ---
echo ""
echo "=== Post-install verification ==="
echo "  vainfo                        # VA-API acceleration"
echo "  intel_gpu_top                 # GPU usage monitor"
echo "  lspci -k | grep -A3 -i vga    # should show 'Kernel driver in use: xe'"
echo "  ls -l /dev/accel/             # NPU device"
echo "  cpupower frequency-info       # CPU governor (expect schedutil)"
echo ""
