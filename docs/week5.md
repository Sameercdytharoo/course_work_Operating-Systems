# Week 5: Advanced Security and Monitoring Infrastructure

## 1. Access Control (AppArmor)

**Objective:** Use Mandatory Access Control (MAC) to restrict application capabilities.

**Implementation:**
Verified AppArmor is active and enforcing profiles.
```bash
sudo aa-status
```
> **Evidence Required**: Capture the output of `sudo aa-status` showing profiles in "enforce" mode.

```
*AppArmor profiles restrict the damage a compromised application can do by limiting file and network access.*

## 2. Automatic Security Updates

**Objective:** Ensure the system patches vulnerabilities automatically.

**Implementation:**
Installed and configured `unattended-upgrades`.
```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
```
**Evidence:**
> **Evidence Required**: Capture the config file content:
> ```bash
> cat /etc/apt/apt.conf.d/20auto-upgrades
> ```


## 3. Fail2Ban Intrusion Detection

**Objective:** Protect against brute-force attacks.

**Implementation:**
Installed `fail2ban` and configured a jail for SSH.
```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
```
**Jail Status:**
checked via `sudo fail2ban-client status sshd`.

## 4. Security Baseline Service

**Script:** `security-baseline.sh`
This script was created to automate the verification of our security controls.
It checks:
- Firewall State
- SSH Root Login Status
- AppArmor Status
- Empty Passwords

**Execution Evidence:**
> **Evidence Required**: Run the master script and select **Option 2** (Security Baseline):
> ```bash
> cd ~/scripts
> sudo ./manage_coursework.sh
> ```
> *Capture the "PASS" results from the output.*



## 5. Remote Monitoring

**Script:** `monitor-server.sh`
This script runs on the workstation and pulls vital stats over SSH.

**Execution Evidence:**
> **Evidence Required**: Run the monitor script on your **Workstation** (Local Machine) and capture the table output:
> ```bash
> ./monitor-server.sh admin_user 127.0.0.1 2222
> ```

