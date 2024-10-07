import subprocess
import logging

def run_applescript(script_path):
    try:
        result = subprocess.run(['osascript', script_path], check=True, capture_output=True, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        logging.error(f"Error running AppleScript: {e}")
        logging.error(f"Script output: {e.output}")
        raise
