#!/bin/zsh

# Parse arguments
while getopts "d:t:" opt; do
  case $opt in
    d) max_delay=$OPTARG ;;
    t) load_threshold=$OPTARG ;;
    *) echo "Usage: $0 -d <max_delay_seconds> -t <load_threshold>" >&2; exit 1 ;;
  esac
done

# Validate arguments
if [[ -z "$max_delay" ]] || [[ -z "$load_threshold" ]]; then
  echo "Error: Both -d and -t arguments are required" >&2
  exit 1
fi

if ! [[ "$max_delay" =~ ^[0-9]+$ ]] || (( max_delay <= 0 )); then
  echo "Error: max_delay must be a positive integer" >&2
  exit 1
fi

if ! [[ "$load_threshold" =~ ^[0-9]*\.?[0-9]+$ ]] || \
   (( $(echo "$load_threshold <= 0 || $load_threshold > 1" | bc -l) )); then
  echo "Error: load_threshold must be between 0 and 1" >&2
  exit 1
fi

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
  elapsed_seconds=$(( current_time - start_time ))
  if (( elapsed_seconds >= max_delay )); then
    exit 0
  fi

  # Wait for 1 minute
  sleep 60
done
