# Week 7: Security Audit and System Evaluation

## 1. Security Audit Report

**Tool Used:** Lynis (Open Source Security Auditor)

**Command:**
```bash
sudo apt install lynis
sudo lynis audit system
```

**Results:**
-   **Hardening Index:** 78/100 (Good for a basic server).
-   **Critical Warnings:** 0
-   **Suggestions:** 15 (Mostly related to kernel hardening and banner hiding).

**Evidence:**
> **Evidence Required**: Run Lynis and capture the "Hardening index" score at the end of the output.
> ```bash
> sudo lynis audit system
> ```


<img width="912" height="643" alt="Screenshot from 2025-12-26 02-29-26" src="https://github.com/user-attachments/assets/05d5adeb-a135-4448-80b6-8751f292a46d" />


<img width="854" height="562" alt="Screenshot from 2025-12-26 02-30-10" src="https://github.com/user-attachments/assets/6e34c45b-bd55-4c70-83c6-144c83ef31ae" />



<img width="1222" height="724" alt="Screenshot from 2025-12-26 02-30-36" src="https://github.com/user-attachments/assets/809cbaed-9956-4689-984e-532041e0a13d" />


## 2. Network Security Assessment (Nmap)

**Objective:** Verify firewall rules from the perspective of the Workstation.

**Command (Run on Workstation):**
```bash
nmap -Pn -p- 127.0.0.1 -p 2222
```

**Results:**
```text
PORT     STATE SERVICE
2222/tcp open  EtherNetIP-1
```


*Only the SSH port provided by VirtualBox NAT forwarding is visible.*
> **Evidence Required**: Run nmap from your workstation (Host):
> ```bash
> nmap -Pn -p 2222 127.0.0.1
> ```


<img width="668" height="216" alt="Screenshot from 2025-12-26 16-35-11" src="https://github.com/user-attachments/assets/9b92360e-10fa-4c81-8091-30a12d979017" />


## 3. Access Control Verification

**User Permissions:**
Checked `sudo` access for `admin_user`.
confirmed that `root` cannot log in via SSH.

## 4. Final System Configuration Review

**Service Inventory:**
-   `sshd`: Required for management.
-   `systemd-timesyncd`: Time synchronization.
-   `cron`: Scheduled tasks.
-   `unattended-upgrades`: Security updates.
-   `agetty`: Console access (internal).

All other unnecessary services (e.g., `printer`, `avahi`) were disabled or not installed.

## 5. Risk Assessment

**Remaining Risks:**
1.  **Host Security:** The server is only as secure as the Windows host it runs on. Malware on the host could intercept SSH keys.
2.  **Physical Access:** Anyone with access to the host PC has physical access to the VM console.

**Conclusion:**
The system meets the requirement of a secure, headless Linux server with documented configuration and performance characteristics.
