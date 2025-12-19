#!/bin/bash

# ==============================================================================
# Script Name: manage_coursework.sh
# Description: Unified Server Management Utility for OS Coursework.
#              Contains all server-side logic (Setup, Security, Performance).
#              Run this ON THE SERVER.
# Author:      Sameer Chaudhary Tharu (A000027591)
# ==============================================================================

# Ensure running as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit
fi

# ==============================================================================
# MODULE: SETUP (Former setup_server.sh)
# ==============================================================================
do_setup() {
    echo "=================================================================="
    echo "   STARTING SERVER SETUP (Phase 4)"
    echo "=================================================================="

    echo "[*] Updating package lists..."
    apt update && apt upgrade -y

    echo "[*] Installing required packages..."
    apt install -y sysbench stress-ng iperf3 nginx ufw fail2ban unattended-upgrades ssh

    USERNAME="admin_user"
    echo "[*] Creating user: $USERNAME..."
    if id "$USERNAME" &>/dev/null; then
        echo "    User $USERNAME already exists."
    else
        useradd -m -s /bin/bash $USERNAME
        usermod -aG sudo $USERNAME
        echo "    User created. IMPORTANT: Set password manually with 'passwd $USERNAME'"
    fi

    echo "[*] Configuring Firewall..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw --force enable
    echo "    Firewall active."

    echo "[*] Configuring Fail2Ban..."
    if [ ! -f /etc/fail2ban/jail.local ]; then
        cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    fi
    systemctl enable fail2ban
    systemctl restart fail2ban

    echo "[*] Enabling Automatic Updates..."
    echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
    echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades

    echo "[*] Hardening SSH..."
    SSHD_CONFIG="/etc/ssh/sshd_config"
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $SSHD_CONFIG
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' $SSHD_CONFIG
    systemctl restart ssh

    echo "=================================================================="
    echo "   SETUP COMPLETE"
    echo "=================================================================="
    read -p "Press Enter to return to menu..."
}

# ==============================================================================
# MODULE: SECURITY BASELINE (Former security-baseline.sh)
# ==============================================================================
do_security_check() {
    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m'

    report_status() {
        if [ "$2" == "PASS" ]; then
            echo -e "[ ${GREEN}PASS${NC} ] $1: $3"
        else
            echo -e "[ ${RED}FAIL${NC} ] $1: $3"
        fi
    }

    echo "=================================================================="
    echo "   SECURITY BASELINE VERIFICATION REPORT"
    echo "=================================================================="
    echo "Date: $(date)"
    echo ""

    # 1. Firewall
    UFW_STATUS=$(ufw status | grep "Status: active")
    if [[ ! -z "$UFW_STATUS" ]]; then
        report_status "Firewall" "PASS" "Active"
    else
        report_status "Firewall" "FAIL" "Inactive"
    fi

    # 2. SSH
    ROOT_LOGIN=$(sshd -T | grep "permitrootlogin no")
    if [[ ! -z "$ROOT_LOGIN" ]]; then
        report_status "SSH Root Login" "PASS" "Disabled"
    else
        report_status "SSH Root Login" "FAIL" "Enabled"
    fi

    # 3. AppArmor
    if command -v aa-status &> /dev/null; then
        AA=$(aa-status --enabled 2>/dev/null && echo "enabled" || echo "disabled")
        if [[ "$AA" == "enabled" ]]; then
            report_status "AppArmor" "PASS" "Enforcing"
        else
            report_status "AppArmor" "FAIL" "Disabled"
        fi
    else
        report_status "AppArmor" "FAIL" "Not Installed"
    fi

    # 4. Fail2Ban
    if systemctl is-active --quiet fail2ban; then
        JAILS=$(fail2ban-client status | grep "Jail list" | sed 's/.*Jail list://')
        report_status "Fail2Ban" "PASS" "Running (Jails:$JAILS)"
    else
        report_status "Fail2Ban" "FAIL" "Not Running"
    fi
    
    echo "=================================================================="
    read -p "Press Enter to return to menu..."
}

# ==============================================================================
# MODULE: PERFORMANCE TEST (Former performance_test.sh)
# ==============================================================================
do_performance_test() {
    OUTPUT_DIR="perf_results"
    mkdir -p $OUTPUT_DIR
    
    echo "=================================================================="
    echo "   STARTING PERFORMANCE BENCHMARKS (Phase 6)"
    echo "   This will take roughly 2-3 minutes."
    echo "=================================================================="

    echo "[1/4] Sysbench CPU..."
    sysbench cpu --cpu-max-prime=20000 run > $OUTPUT_DIR/sysbench_cpu.txt
    
    echo "[2/4] Sysbench Memory..."
    sysbench memory --memory-block-size=1M --memory-total-size=10G run > $OUTPUT_DIR/sysbench_memory.txt
    
    echo "[3/4] Sysbench Disk I/O (Prepare & Run)..."
    sysbench fileio --file-total-size=1G prepare > /dev/null
    sysbench fileio --file-total-size=1G --file-test-mode=rndrw --time=40 --max-requests=0 run > $OUTPUT_DIR/sysbench_fileio.txt
    sysbench fileio --file-total-size=1G cleanup > /dev/null
    
    echo "[4/4] Stress-ng (30s)..."
    timeout 35s stress-ng --cpu 2 --vm 1 --vm-bytes 256M --metrics-brief 2>&1 | tee $OUTPUT_DIR/stress_ng.txt

    echo ""
    echo "=================================================================="
    echo "   PERFORMANCE SUMMARY REPORT"
    echo "=================================================================="
    CPU_SCORE=$(grep "events per second:" $OUTPUT_DIR/sysbench_cpu.txt | awk '{print $4}')
    DISK_READ=$(grep "reads/s:" $OUTPUT_DIR/sysbench_fileio.txt | awk '{print $2}')
    
    printf "%-20s | %-30s\n" "METRIC" "VALUE"
    echo "----------------------------------------------------"
    printf "%-20s | %-30s\n" "CPU Score" "$CPU_SCORE events/sec"
    printf "%-20s | %-30s\n" "Disk Read IOPS" "$DISK_READ"
    echo "----------------------------------------------------"
    echo "Full logs saved to $OUTPUT_DIR/"
    read -p "Press Enter to return to menu..."
}

show_menu() {
    clear
    echo "=================================================================="
    echo "   OS COURSEWORK MANAGER - UNIFIED TOOL"
    echo "=================================================================="
    echo "1. [Phase 4] Run Initial Setup (Install apps, user, firewall)"
    echo "2. [Phase 5] Run Security Baseline Verification"
    echo "3. [Phase 6] Run Performance Benchmarks"
    echo "0. Exit"
    echo "=================================================================="
}

# Main Loop
while true; do
    show_menu
    read -p "Enter Choice: " choice
    case $choice in
        1) do_setup ;;
        2) do_security_check ;;
        3) do_performance_test ;;
        0) exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
