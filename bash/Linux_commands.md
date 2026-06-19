Here is the complete, production-ready `README.md` guide covering the **essential and advanced Linux commands** required for a DevOps Engineer.

This guide skips the basic commands like `ls` and `cd` and instead focuses directly on the commands you need for **infrastructure troubleshooting, log parsing, networking, performance tuning, and user permissions**.

---

# Complete Linux Diagnostics & Systems Engineering Reference Guide

A master compilation of production-grade Linux commands used by DevOps engineers to triage system outages, debug network boundaries, parse logs, and manage server security.

---

## 1. System Performance & Kernel Triage

When an application is running slowly or a node becomes unresponsive, use these commands to inspect CPU, memory, and kernel states.

```bash
# 1. Real-Time Resource Monitoring
htop        # Interactive process viewer (preferred over standard 'top')
top -H -p <PID> # Monitor resource consumption of individual threads inside a specific process

# 2. Virtual Memory & CPU Wait Time Statistics
vmstat 1 5  # Reports statistics on processes, memory, paging, block I/O, and CPU activity every 1 second

# 3. Storage I/O Bottleneck Inspection
iostat -xz 1 5 # Provides detailed disk I/O metrics; look for high %util (disk saturation) and await (latency)

# 4. Global System Resource History
sar -q 1 5  # Reports queue length and load averages (part of the sysstat package)

# 5. Kernel Ring Buffer Messages
dmesg -T | tail -n 50 # View kernel-level errors, OOM (Out Of Memory) kills, or hardware faults with timestamps

```

---

## 2. Network Diagnostics & Socket Sifting

Essential for debugging broken microservice paths, checking if ports are bound correctly, and tracing firewall blocks.

```bash
# 1. Socket Statistics (Modern replacement for 'netstat')
ss -tunplw  # Show all listening TCP (-t), UDP (-u), Numeric ports (-n), Processes (-p), and Timers (-w)

# 2. Network Routing & Interface Configurations
ip a        # List all network interfaces and assigned IP addresses
ip route    # Display the current kernel routing table (default gateways)

# 3. DNS Resolution & Domain Auditing
dig +short api.production.internal # Get the immediate IP layout for an internal service address
nslookup google.com                # Query internet name servers interactively

# 4. Low-Level Packet Capturing (Packet Sniffing)
sudo tcpdump -c 50 -nn -i eth0 port 443 # Capture 50 packets on interface eth0 matching HTTPS traffic without resolving hostnames

# 5. Application Layer Network Probing
curl -Iv https://example.com # Fetch headers only (-I) and output full verbose connection logs (-v) for TLS triage

```

---

## 3. Storage, Disk Sifting, & Ghost Spaces

Used during "disk full" alerts to clear logs or track down hidden storage leaks.

```bash
# 1. Human-Readable Disk Usage Summary
df -h       # Reports total, used, and available space on all mounted filesystems

# 2. Sifting Out the Top 10 Heaviest Folders
du -ahx / | sort -rh | head -n 10 # -x prevents crossing filesystem boundaries (e.g., skips network mounts)

# 3. Resolving the "Ghost Space Leak"
# (Files that were deleted using 'rm' but are still taking up disk space because a process keeps them open)
lsof +L1    # Lists open files with a link count of less than 1. Find the PID and restart the service to free space.

# 4. Interactive Storage Analyzer
ncdu /      # NCurses-based disk usage interface (highly recommended for clearing staging environments)

```

---

## 4. Text Processing & Log Parsing Mechanics

When log aggregation platforms (Splunk/Datadog) are down or unavailable, you must be able to parse gigabytes of raw logs directly on the instance terminal.

```bash
# 1. Pattern Matching with Grep
grep -rni "ERROR" /var/log/nginx/ # Recursively (-r), ignore case (-i), print line numbers (-n) for matches
grep -v "DEBUG" server.log        # Inverse matching: Outputs only lines that do NOT contain "DEBUG"

# 2. Dynamic Text Parsing with Awk
awk '{print $1, $7}' /var/log/nginx/access.log | head -n 10 # Extract only the 1st (IP) and 7th (URI) columns from an access log

# 3. Stream Editing with Sed
sed -i 's/HTTP\//HTTPS\//g' config.env # Search and replace a string in-place (-i) inside a configuration file

# 4. Isolating Unique Counts
sort access.log | uniq -c | sort -nr | head -n 10 # Count duplicate lines, sort numerically descending, isolate top 10 entries

```

---

## 5. Security, Permissions, & Process Inspection

```bash
# 1. File Permissions & Ownership
chmod 600 id_rsa            # Restrict private key permissions to read/write for owner only
chown -R www-data:www-data /var/www/ # Recursively change user and group ownership of web assets

# 2. User & Execution Identity Checks
whoami                      # Prints the effective user ID of the current session
id                          # Prints real and effective user and group IDs

# 3. Deep Process Analysis & Open File Maps
lsof -p <PID>               # List every single file descriptor, port, and library hook mapped to a target process
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 # Isolate the top 5 highest CPU-consuming processes

# 4. Kernel System Call Tracing
strace -f -e trace=openat,connect -p <PID> # Intercept and view live system file opens or network attachments on a hung application

```

---

## 6. Interview Checklist: Quick Revision Summary

| Problem Scenario | Primary Command Strategy | Reason for Choice |
| --- | --- | --- |
| **Server out of storage, but `du` shows nothing** | `lsof +L1` | Finds unlinked files held open by running application processes. |
| **Checking if a port is bound by a process** | `ss -tunplw` | Displays listening TCP/UDP bindings alongside process PIDs. |
| **Debugging high CPU wait times** | `vmstat 1 5` / `iostat` | Differentiates between raw CPU computation spikes and disk I/O bottlenecks. |
| **App hanging during initial loading** | `strace -p <PID>` | Reveals exactly which file read or network connection is blocking execution. |
| **Validating internal cluster DNS routes** | `dig +short <service>` | Bypasses local wrapper noise to show exact DNS resolution entries. |