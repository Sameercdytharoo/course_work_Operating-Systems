# Week 4: Initial System Configuration & Security Implementation

## 1. User Management

**Objective:** Create a non-root administrative user to adhere to the Principle of Least Privilege.

**Implementation:**
Created a user named `admin_user` and granted `sudo` privileges.

```bash
# Command to create user
sudo useradd -m -s /bin/bash admin_user

# Add to sudo group
sudo usermod -aG sudo admin_user
```

**Evidence:**
> **Evidence Required**: Capture a screenshot of the following command output:
> ```bash
> id admin_user
> grep sudo /etc/group | grep admin_user
> ```
> <img width="1222" height="115" alt="Screenshot from 2025-12-23 20-03-32" src="https://github.com/user-attachments/assets/c0c2cec2-b80a-4ca2-afaf-7978d7c4981a" />


## 2. SSH Hardening

**Objective:** Secure remote access by disabling root login and password authentication.

**Configuration Changes (`/etc/ssh/sshd_config`):**

| Setting | Value | Rationale |
| :--- | :--- | :--- |
| `PermitRootLogin` | `no` | Prevents direct root access. Attackers must compromise a lower user first. |
| `UsePAM` | `yes` | Standard security framework. |
| `PasswordAuthentication` | `no` | **Critical**: Forces use of SSH Keys, eliminating brute-force password guessing. |

**Evidence:**
> **Evidence Required**: Capture a screenshot of a successful login from your workstation terminal:
> ```bash
> ssh -p 2222 admin_user@127.0.0.1
> ```
> *Note: Ensure the prompt shows `admin_user@hostname`.*


## 3. Firewall Configuration (UFW)

**Objective:** Implement a "Default Deny" network policy.

**Rules Implemented:**
1.  **Incoming**: DENY (Block all unsolicited traffic).
2.  **Outgoing**: ALLOW (Allow server to fetch updates).
3.  **SSH**: ALLOW (Port 22/tcp).

**Command Output (`sudo ufw status verbose`):**
```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
```

**Evidence:**
> **Evidence Required**: Capture a screenshot of the firewall status command:
> ```bash
> sudo ufw status verbose
> ```

