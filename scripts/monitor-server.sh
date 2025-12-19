#!/bin/bash

# ==============================================================================
# Script Name: monitor-server.sh
# Description: Remote monitoring script to be run on the Workstation.
#              Connects to the Server via SSH and captures real-time performance
#              metrics (CPU, Memory, Disk, Network).
# Author:      Sameer Chaudhary Tharu (A000027591)
# Phase:       5 (Advanced Security & Monitoring)
# Usage:       ./monitor-server.sh [user] [ip] [port]
# Example:     ./monitor-server.sh student 127.0.0.1 2222
# ==============================================================================

# Default Configuration
REMOTE_USER=${1:-"student"}
REMOTE_IP=${2:-"127.0.0.1"}
REMOTE_PORT=${3:-"2222"}

# SSH Command with options to reduce timeout and suppress warnings
# -o ConnectTimeout=5: Fail fast if server is down
# -o StrictHostKeyChecking=no: Avoid prompt for known_hosts (Optional, use with care)
# -q: Quiet mode
SSH_CMD="ssh -p $REMOTE_PORT -o ConnectTimeout=5 -q"

echo "========================================================================"
echo "   REMOTE SYSTEM MONITOR"
echo "   Target: $REMOTE_USER@$REMOTE_IP:$REMOTE_PORT"
echo "========================================================================"
printf "%-10s | %-15s | %-15s | %-15s | %-15s\n" "TIME" "LOAD AVG (1m)" "RAM USED (MB)" "DISK (/) %" "TCP CONNS"
echo "------------------------------------------------------------------------"

# Infinite Loop
while true; do
    TIMESTAMP=$(date +%H:%M:%S)

    # We execute a single compound command on the server to get all metrics at once.
    # This reduces network overhead and SSH handshake latency.
    METRICS=$($SSH_CMD $REMOTE_USER@$REMOTE_IP "
        cat /proc/loadavg | awk '{print \$1}'; 
        free -m | grep Mem | awk '{print \$3}'; 
        df -h / | awk 'NR==2 {print \$5}'; 
        ss -tH state established | wc -l
    ")

    # Check if SSH command failed (e.g., connection lost)
    if [ $? -ne 0 ]; then
        echo -e "$TIMESTAMP | [CONNECTION ERROR] - Retrying in 5s..."
        sleep 5
        continue
    fi

    # Parse stdout into array
    # 1: Load Avg
    # 2: RAM Used
    # 3: Disk Usage
    # 4: TCP Connections
    readarray -t DATA <<< "$METRICS"

    LOAD=${DATA[0]}
    RAM=${DATA[1]}
    DISK=${DATA[2]}

    # Ensure TCP conn is a number (ss might return empty if 0)
    CONN=${DATA[3]}
    if [[ -z "$CONN" ]]; then CONN="0"; fi

    # Print Formatted Row
    printf "%-10s | %-15s | %-15s | %-15s | %-15s\n" "$TIMESTAMP" "$LOAD" "${RAM} MB" "$DISK" "$CONN"

    # Wait before next poll
    sleep 2
done
