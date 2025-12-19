# Week 2: Security Planning and Testing Methodology

## 1. Performance Testing Plan

**Objective:**
To critically analyse the operating system's behaviour under different workloads (CPU, Memory, I/O) by measuring key metrics before and during load generation.

**Methodology:**
The testing will follow a **Remote Monitoring** approach to ensure the observation process itself minimizes impact on the server's resources.

**Tools & Strategy:**
1.  **Workload Generation**: Specific applications (identified in Phase 3) will be used to stress specific resources.
2.  **Data Collection**:
    -   **On-Server**: `vmstat`, `mpstat`, `iostat` (from `sysstat` package) for granular kernel-level metrics.
    -   **Remote**: A custom script (`monitor-server.sh`) running on the workstation will connect via SSH to snapshots of these metrics every 1-5 seconds.
3.  **Metrics to Track**:
    -   **CPU**: User vs System time, Load Average (1, 5, 15 min).
    -   **Memory**: Used vs Cache/Buffer, Swap usage.
    -   **Disk I/O**: Read/Write throughput (MB/s), IOPS, Wait time.

> **Methodology Justification**: Remote monitoring prevents "observer effect" where the monitoring tool itself consumes significant CPU on the target server, potentially skewing results.


## 2. Security Configuration Checklist

This checklist defines the **Security Baseline** to be implemented in Phase 4 and 5.

| Category | Control | Rationale | Implementation |
| :--- | :--- | :--- | :--- |
| **SSH** | **Disable Root Login** | Prevent direct attack on the superuser account. | `PermitRootLogin no` in `sshd_config` |
| **SSH** | **Key-Based Auth Only** | Eliminate password brute-force risks. | `PasswordAuthentication no`, `PubkeyAuthentication yes` |
| **Firewall** | **Default Deny** | Block all unsolicited traffic by default. | `ufw default deny incoming` |
| **Firewall** | **Allow SSH (Specific IP)** | Restrict management access to the workstation only. | `ufw allow from 10.0.2.2 to any port 22` |
| **User Mgmt** | **Least Privilege User** | Admin tasks performed via sudo only. | Create `admin` user, add to `sudo` group. |
| **Updates** | **Automatic Security Updates** | Reduce window of vulnerability for known CVEs. | Install `unattended-upgrades`. |
| **Access Control** | **AppArmor** | Confine programs to limited resources. | Ensure `apparmor` service is active and enforcing. |
| **Intrusion** | **Fail2Ban** | Ban IPs showing malicious behavior (e.g., repeated login fails). | Install and configure `fail2ban`. |

## 3. Threat Model

**Identified Threats:**

### Threat 1: Brute-Force SSH Attacks
-   **Description**: Attackers attempting to guess passwords to gain shell access. Even on a private network, internal threats or compromised workstations pose this risk.
-   **Impact**: High. Full system compromise.
-   **Mitigation Strategy**:
    -   Disable Password Authentication totally (rely on SSH Keys).
    -   Implement **Fail2Ban** to lock out repeated failures.
    -   Run SSH on a non-standard port (optional, "Security by Obscurity", but helpful for log noise).

### Threat 2: Unpatched Service Vulnerabilities
-   **Description**: Running services (like SSH or future app servers) with known CVEs that exploits can target.
-   **Impact**: Critical. Remote code execution or denial of service.
-   **Mitigation Strategy**:
    -   Enable **Unattended Upgrades** for immediate security patching.
    -   Minimize attack surface by uninstalling unused packages (e.g., removing `cups` or `avahi` if not needed).


### Threat 3: Privilege Escalation
-   **Description**: An attacker who gains low-level user access exploits a kernel bug or misconfiguration to become root.
-   **Impact**: Critical. Total control over the OS.
-   **Mitigation Strategy**:
    -   **Principle of Least Privilege**: Run services as dedicated non-root users.
    -   **Mandatory Access Control (MAC)**: Use AppArmor to confine service processes so they cannot access files outside their scope, even if compromised.
