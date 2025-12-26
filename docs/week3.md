# Week 3: Application Selection for Performance Testing

## 1. Application Selection Matrix

The following applications have been selected to simulate diverse workloads effectively.

| Application | Type | Justification |
| :--- | :--- | :--- |
| **Sysbench** | Synthetic Benchmark | Industry standard scriptable benchmark. Capable of stressing CPU (primes), RAM, and Disk I/O precisely. |
| **Stress-ng** | System Stressor | Offers over 200 stress tests. Perfect for testing stability and kernel behaviour under extreme memory/fork pressure. |
| **Nginx** | Web Server | Real-world service application. Represents "Network + CPU" workload typical of web hosting. |
| **Iperf3** | Network Tool | Pure network bandwidth tester. Essential for measuring the throughput between Host (Client) and VM (Server). |

## 2. Installation Documentation

These commands will be executed via SSH on the server.

```bash
# Update package list
sudo apt update

# Install Sysbench, Stress-ng, Nginx, and Iperf3
sudo apt install -y sysbench stress-ng nginx iperf3

# Verify installations
sysbench --version
stress-ng --version
nginx -v
iperf3 -v
```


> **Evidence Required**: Take a screenshot of the output of the above verification commands to prove installation execution.


<img width="1217" height="328" alt="Screenshot from 2025-12-23 19-50-10" src="https://github.com/user-attachments/assets/57888da7-f4d2-42a0-be3e-06a3f0bb0194" />
## 3. Expected Resource Profiles

| Application | Primary Resource | Expected Behaviour |
| :--- | :--- | :--- |
| **Sysbench (CPU)** | CPU | Utilization should hit 100% on all cores. Load average will rise. |
| **Stress-ng (VM)** | Memory (RAM) | High RAM modification rate. Might trigger OOM (Out of Memory) killer if pushed too far. Swap usage will increase. |
| **Sysbench (FileIO)** | Disk I/O | High Read/Write ops. Wait times (iowait) should increase significantly. |
| **Nginx (Load)** | Network & CPU | High interrupt rate, network packet flow, and moderate CPU usage for request handling. |

## 4. Monitoring Strategy

To capture the performance data during these tests, I will use a combination of simple tools and logged metrics.

1.  **Baseline**: Run `vmstat 1 10` before any test to establish idle state.
2.  **During Test**:
    -   **CPU**: `mpstat -P ALL 1` to see per-core usage.
    -   **Memory**: `vmstat 1` to watch swap/cache.
    -   **Network**: `iftop` or `nload` (interactive) or `sar -n DEV 1` for logging.
3.  **Data Logging**: Output of benchmarks (like `sysbench` result summary) will be saved to text files: `sysbench_cpu_results.txt`.
   
<img width="1154" height="531" alt="Screenshot from 2025-12-23 19-58-06" src="https://github.com/user-attachments/assets/ccc87e94-7c79-42d9-bf70-56ed2fcabfad" />


<img width="1224" height="165" alt="Screenshot from 2025-12-23 19-59-16" src="https://github.com/user-attachments/assets/9e08e9bc-e492-4659-83c9-b0b6af37a1e6" />

