import os
from pynput.keyboard import KeyCode
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APPLESCRIPT_DIR = os.path.join(BASE_DIR, 'resources', 'applescripts')
LOG_FILE = os.path.join(BASE_DIR, 'logs', 'myapp.log')

# Get API key from environment variable
ANTHROPIC_API_KEY = os.getenv('ANTHROPIC_API_KEY')

# Trigger key
TRIGGER_KEY = KeyCode.from_char('7')
