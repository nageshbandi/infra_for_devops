# Master Linux, Unix, & Shell Scripting Interview Preparation Guide

This master `README.md` is compiled entirely from the explicit tech stacks, foundational chapters, and engineering "hacks" documented within your attached resources: **"UNIX Concepts and Applications"** and **"Linux 101 Hacks"**.

Use this unified sheet to revise all key patterns, text-processing engines, system administration operations, and performance tuning configurations before your interview.

---

## 1. Directory Navigation & Shell Environment Customization

Streamlining filesystem traversal and tailoring the user prompt context dynamically.

### Dynamic Path Resolution via `CDPATH`

Avoid typing absolute paths for frequently accessed nested directories. Setting this environment variable redirects `cd` lookups automatically.

```bash
export CDPATH=.:~:/etc:/var:/home/projects
[cite_start]cd mail # Instantly moves to /etc/mail if it exists under the exported paths [cite: 3013, 3014]

```

### Navigating Up Deep Filesystem Traersals

Instead of repeating unreadable parent slices (`cd ../../../../`) , export structured dot aliases to your execution profile:

```bash
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
# Custom consecutive dot expansions
alias ...="cd ../.."
alias ....="cd ../../.."

```

### Directory Stack Manipulation

Manage historical operational contexts dynamically within an internal memory stack.

* 
`dirs`: Display the active directory stack.


* 
`pushd /tmp/dir1`: Push a directory path to the top of the context memory stack.


* 
`popd`: Remove the top-most directory slice from the stack and change location to it.



### Shell Customization Prompts (`PS1`, `PS2`, `PS3`, `PS4`)

Enforce informative layout layouts across your terminal frames.

* 
**`PS1`**: Primary interactive command prompt layout. Enforce user, host, and working directory layouts:


```bash
[cite_start]export PS1="\u@\h \w> " # \u=User, \h=Host, \w=Full Path [cite: 3375, 3386]
# Using dynamic command generation inside the primary prompt:
[cite_start]export PS1='\u@\h [`pgrep httpd | wc -l` processes]> ' [cite: 3390, 3391]

```


* 
**`PS2`**: Secondary continuation interactive prompt (default is `> `) for multi-line slashed inputs.


```bash
export PS2="continue-> "

```


* 
**`PS3`**: Prompt selection indicator string applied natively inside shell script `select` menu blocks.


* 
**`PS4`**: Execution tracing prefix output format applied when scripts run under debug modes (`set -x`).



---

## 2. Low-Level Text Processing & Data Extraction Filters

Parsing files line-by-line using basic and advanced string parsing utilities.

### Character Mapping via `tr`

`tr` modifies characters entirely via standard input streams.

```bash
[cite_start]tr -z A-Z < input.txt          # Global capitalization conversion [cite: 85, 3098]
[cite_start]tr -d '/' < input.txt           # Destructive character pruning [cite: 85]
[cite_start]tr -s ' ' < input.txt           # Compresses consecutive duplicate spaces [cite: 85]

```

### Horizontal File Slicing via `cut`

```bash
cut -d "|" [cite_start]-f 2,3 data.txt     # Extracts exact field columns using a pipe delimiter [cite: 73]
[cite_start]cut -c 1-8 names.txt           # Vertical slicing restricted strictly by string offsets [cite: 77, 4562]

```

### Joining, Sorting, & Uniqueness Deduplication

```bash
[cite_start]join employee.txt bonus.txt    # Merges fields of two sorted files side-by-side using common index columns [cite: 3095, 3097]
[cite_start]sort -t: -k 3n /etc/passwd     # Numeric sorting (-n) on the 3rd column (-k) with field delimiter (-t) [cite: 4498, 4499]
[cite_start]sort names.txt | uniq -c       # Returns aggregate frequency occurrences of lines [cite: 83, 4532]
[cite_start]sort names.txt | uniq -cd      # Isplates and displays ONLY duplicate structural matches [cite: 4539]

```

---

## 3. Regular Expression Search Engines (`grep` / `egrep`)

Performing pattern matching against target system configurations or text buffers.

```bash
[cite_start]grep -i "pattern" /var/log/syslog   # Case-insensitive global search lookup [cite: 90, 4236]
[cite_start]grep -v "director" accounts.lst    # Inverse match: Isolate lines missing the target token [cite: 90, 4219]
[cite_start]grep -ril "john" /etc/             # Recursive lookup (-r), printing ONLY names (-l) of matching files [cite: 25, 4241]
[cite_start]grep -c "^$" sample.log            # Aggregates exact line count of empty matching entries [cite: 27, 4287]

```

### Extended Regular Expression (`egrep` / `grep -E`) Matching Attributes

| Operator | Logic | Application |
| --- | --- | --- |
| `+` | One or more occurrences of the previous block.

 | `grep -E "sen+gupta"` |
| `?` | Zero or one occurrence of the previous character.

 | `grep -E "https?"` |
| `|` | Logical OR evaluating structural patterns.

 | <br>`grep -E "sengupta|dasgupta"` 

 |
| `()` | Groups sub-expressions cleanly.

 | <br>`grep -E "(sen|das)gupta"` 

 |

---

## 4. Advanced Stream Editing via `sed`

Perform non-interactive text modifications directly on live streams and pipelines.

### Structure Syntax Rules

```bash
# General Syntax Layout
[cite_start]sed '[address]action' target_file.txt [cite: 95]
[cite_start]sed 's/REGEXP/REPLACEMENT/FLAGS' filename [cite: 4699, 4700]

```

### Critical sed Action Implementations

```bash
[cite_start]sed -n '1,3p' log.txt          # Prints specific line sets explicitly (suppresses defaults via -n) [cite: 95, 96]
[cite_start]sed '3q' application.log       # Aborts streaming processing immediately upon reaching line 3 [cite: 95]
[cite_start]sed '/director/d' internal.lst # Purges matching rows dynamically from output streams [cite: 97]
[cite_start]sed 's/Linux/Unix/g' file.txt  # Global token translation pattern replacement [cite: 4742, 4743]
[cite_start]sed 's/Linux/Unix/2' file.txt  # Translates ONLY the 2nd instance within a row context [cite: 4753, 4755]
[cite_start]sed '/-/s/\-.*//g' schema.txt  # Condition-based truncation: Modifies rows matching a pattern [cite: 4773, 4774]
[cite_start]sed -e 's/#.*//;/^$/d' cfg.env # Inline multi-command link: Strips comments and empty rows [cite: 4811, 4814]
[cite_start]sed -e 's/<[^>]*>//g' index.html # Strips inline structured markup/HTML tags [cite: 4826, 4828]

```

---

## 5. Structured Data Manipulation Engine (`awk`)

Pattern scanning, processing, and column-based processing layout generations.

### Execution Blueprint

```bash
[cite_start]awk -F "delimiter" '/search_pattern/ { actions }' target_file [cite: 154, 4852]

```

* 
**Variables**: `$0` addresses full rows. `$1`, `$2` address parsed column array fields.


* 
**Built-ins**: `NR` tracking line records index. `NF` capturing current field bounds counts.



### Production awk Implementations

```bash
# Print specified columns using implicit white space formatting layouts
[cite_start]awk '{print $2, $5}' system_metrics.log [cite: 4892]

# Enforcing non-standard field split variables to process custom layout arrays
awk -F "|" [cite_start]'/sales/{print $2, $3, $6}' sales.db [cite: 154]

# Row Boundary Control Slicing
awk -F "|" [cite_start]'NR==3, NR==6 {print $3}' infrastructure.txt [cite: 155, 156]

# Dynamic Regex Field Matching Evaluator
[cite_start]awk '$4 ~/Technology/' internal_roster.db [cite: 4934, 4935]

```

### Structuring Pipeline Layouts via `BEGIN` & `END` Blocks

```awk
# Execute logic loops before streaming files and dump analytical results upon exit
awk -F "|" '
BEGIN { 
    print "--- Starting Audit Processing ---"; 
    count=0; 
}
$4 ~/[sS]ales/ { 
    count++; 
    total_sal += $6; 
}
END { 
    printf "Aggregated Rows Managed: %d | Mean Allocation: %d\n", count, total_sal/count; 
[cite_start]}' billing.db [cite: 167, 168]

```

---

## 6. Enterprise-Grade System Administration & Infrastructure Security

Managing local processes, disk allocations, packages, and secure connections.

### Storage Diagnostics

```bash
[cite_start]df -h                          # Reports global capacity statistics using human-readable layouts [cite: 142]
[cite_start]du -sh /home/* # Summarizes structural usage maps of specific root trees [cite: 144]
[cite_start]stat /etc/my.cnf               # Dumps structural metadata attributes, inodes, and file states [cite: 4575, 4576]

```

### Swap Space Engineering

```bash
[cite_start]dd if=/dev/zero of=/swapfile bs=1M count=512   # Allocate unformatted space block targets [cite: 3554]
[cite_start]mkswap /swapfile                                # Format target files as localized swap zones [cite: 3554, 3555]
[cite_start]swapon /swapfile                                # Enable active virtual memory paging [cite: 3555, 3556]

```

### System Services & Automation Cron Mechanics

```bash
[cite_start]chkconfig network on           # Configure service automation runlevels across system startup scripts [cite: 3616]
[cite_start]crontab -e                     # Modify periodic automation script schedules [cite: 48, 849]
# [cite_start]Format: Min (00-10) Hour (17) DayOfMonth (*) Month (3,6,9) DayOfWeek (5) [cite: 834, 846]
[cite_start]00-10 17 * 3,6,9 5 /usr/local/bin/backup.sh > /dev/null 2>&1 [cite: 834, 839]

```

### Hardening OpenSSH Daemons (`/etc/ssh/sshd_config`)

Enforce configuration standardizations to mitigate brute-force attacks:

```ini
[cite_start]PermitRootLogin no             # Deny direct superuser login tunnels; enforce unprivileged accounts [cite: 5467, 5479]
[cite_start]AllowUsers ramesh john jason   # Whitelist explicit accounts permitted to connect [cite: 5480, 5490]
[cite_start]Port 222                       # Re-route listener ports away from default values [cite: 5509, 5513]
[cite_start]LoginGraceTime 1m              # Drops unauthenticated connection hooks promptly [cite: 5520, 5526]
[cite_start]ClientAliveInterval 600        # Force idle disconnection drops after 10 minutes [cite: 5542, 5551]
[cite_start]ClientAliveCountMax 0          # Drops connection immediately if checkalive metrics mismatch [cite: 5545, 5552]

```

### Passwordless Authentication Architecture

Establishing trust zones securely across infrastructure nodes.

```bash
[cite_start]ssh-keygen                     # Provision private/public cryptography keys [cite: 3566, 3568]
[cite_start]ssh-copy-id -i ~/.ssh/id_rsa.pub remote-host   # Appends public keys to remote target files safely [cite: 3566, 3570]

```

### Package Management & Source Assembly Compilation

```bash
[cite_start]yum -y install postgresql      # Automates verification dependencies seamlessly [cite: 181, 3634]
[cite_start]apt-get install apache2        # Orchestrates package deployment profiles across Debian targets [cite: 73, 3656]
# Compiling straight from raw source archives:
[cite_start]./configure && make && make install [cite: 191, 3667]

```

---

## 7. Performance Engineering, Process Control, & Live Triage

Monitoring kernel wait states, process states, and runtime anomalies.

### Process Attribute Inspections

```bash
[cite_start]ps -elf                        # Detailed processing layout mapping states, priority weight maps, and PIDs [cite: 30, 701]
[cite_start]nice -n 5 wc -l database.log   # Initiate system processes under shifted priority weights [cite: 38, 749]
[cite_start]renice +10 -p 4123             # Adjust priorities of active operational tasks dynamically [cite: 5, 254]

```

### Job Control Interactivity

```bash
[cite_start]./long_job.sh &                # Defers execution streams to background process models [cite: 43, 4661]
[cite_start]jobs                           # Audit active background operational tasks tracking [cite: 40, 771]
[cite_start]bg %1                          # Resumes a suspended task process (`Ctrl+Z`) cleanly in the background [cite: 14, 752]
[cite_start]fg %1                          # Restores background operations straight to foreground interactions [cite: 41, 788]
[cite_start]kill -9 121                    # Transmits uncatchable SIGKILL overrides directly to hanging tasks [cite: 43, 804]

```

### Core Live Outage Troubleshooting Binaries

* 
`free -m`: Real-time system memory usage diagnostics.


* 
`top`: Interactive process prioritization and active utilization tracing tool. Press `1` inside to check per-core layout footprints.


* 
`vmstat 1 100`: Monitored tracking of processing queues, context switching (`cs`), and CPU wait profiles.


* 
`lsof`: Traces open file handlers and sockets mapped back to execution parents.


* 
`sar`: Historical diagnostics engine mapping subsystem loads and core performance arrays over time.