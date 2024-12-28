#!/bin/zsh

# Parse arguments
while getopts "m:l:" opt; do
  case $opt in
    m) minutes=$OPTARG ;;
    l) load_threshold=$OPTARG ;;
    *) echo "Usage: $0 -m <minutes> -l <load_threshold>" >&2; exit 1 ;;
  esac
done

# Get number of CPU cores
cores=$(nproc)

# Calculate the effective load threshold
effective_threshold=$(echo "$load_threshold * $cores" | bc)

# Start time
start_time=$(date +%s)

while true; do
  # Get the 15-minute load average
  load_15=$(uptime | awk -F 'load average:' '{print $2}' | awk -F, '{print $3}' | xargs)

  # Compare with the effective threshold
  if (( $(echo "$load_15 < $effective_threshold" | bc -l) )); then
    exit 0
  fi

  # Check if the time limit has been reached
  current_time=$(date +%s)
  elapsed_minutes=$(( (current_time - start_time) / 60 ))
  if (( elapsed_minutes >= minutes )); then
    exit 0
  fi

  # Wait for 1 minute
  sleep 60
done
