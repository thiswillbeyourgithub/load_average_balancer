import os
import sys
import time
import psutil
import fire

def usage():
    print("Usage: load_average_balancer.py -d <max_delay_seconds> -t <load_threshold>", file=sys.stderr)
    os.exit(1)


def load_average_balancer(max_delay: int, load_threshold: float):
    assert max_delay is not None and load_threshold is not None, "Both -d and -t arguments are required"
    assert isinstance(max_delay, int) and max_delay > 0, "max_delay must be a positive integer"
    assert 0 < load_threshold <= 1, "load_threshold must be between 0 and 1"
    
    # Get number of CPU cores
    cores = psutil.cpu_count(logical=True)
    
    # Calculate the effective load threshold
    effective_threshold = load_threshold * cores
    
    # Start time
    start_time = time.time()
    
    while True:
        # Get the 15-minute load average
        load_15 = psutil.getloadavg()[2]
        
        # Compare with the effective threshold
        if load_15 < effective_threshold:
            os.exit(0)
        
        # Check if the time limit has been reached
        elapsed_seconds = time.time() - start_time
        if elapsed_seconds >= max_delay:
            os.exit(0)
        
        # Wait for 1 minute
        time.sleep(60)

if __name__ == "__main__":
    fire.Fire(load_average_balancer)
