# Load Average Balancer

A utility script to delay the execution of CPU-intensive tasks (like restic backups) until the system load average drops below a specified threshold.

## Purpose

This script was created to prevent restic backups from running during periods of high CPU usage. It monitors the system's 15-minute load average and only exits (allowing the backup to proceed) when either:
- The load average falls below a specified threshold
- A maximum delay time is reached

## Usage

### Shell Version
```bash
./load_average_balancer.sh -d <max_delay_seconds> -t <load_threshold>
```

### Python Version
```bash
python3 load_average_balancer.py -d <max_delay_seconds> -t <load_threshold>
```

The Python version provides the same functionality as the shell script but uses Python's psutil library for system monitoring. It may be more portable across different operating systems.

### Arguments

- `-d <max_delay_seconds>`: Maximum time to wait in seconds before allowing the backup to proceed
- `-t <load_threshold>`: Load average threshold as a fraction of available CPU cores (0-1)
- `-h`: Display help message

### Example

To wait up to 1 hour for the load to drop below 80% of available CPU cores:

```bash
./load_average_balancer.sh -d 3600 -t 0.8
```

### Integration with restic

#### Shell Version
Add this script before your restic backup command:

```bash
./load_average_balancer.sh -d 3600 -t 0.8 && restic backup /path/to/backup
```

#### Python Version
```bash
python3 load_average_balancer.py -d 3600 -t 0.8 && restic backup /path/to/backup
```

## Requirements

### Shell Version
- zsh shell
- bc (basic calculator)
- Standard Unix utilities (uptime, nproc)

### Python Version
- Python 3.6 or higher
- psutil package (install with `pip install psutil`)
- Compatible with Linux, macOS, and other Unix-like systems

## Exit Codes

- 0: Success (either load dropped below threshold or maximum delay was reached)
- 1: Invalid arguments or usage error
