import logging
import time
from pynput import keyboard
from clipboard_handler import get_clipboard_content, set_clipboard_content
from synonym_fetcher import fetch_synonyms
from applescript_runner import run_applescript
from config import APPLESCRIPT_DIR, LOG_FILE, TRIGGER_KEY

logging.basicConfig(filename=LOG_FILE, level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def process_synonym_request():
    logging.info("Trigger key pressed, processing synonym request...")
    try:
        # Add a small delay to ensure the key press doesn't interfere with the selection
        time.sleep(0.1)

        # Simulate Cmd+C to copy selected text
        run_applescript(f"{APPLESCRIPT_DIR}/copy_selection.applescript")
        time.sleep(0.2)  # Short delay to ensure clipboard is updated

        word = get_clipboard_content()
        logging.info(f"Clipboard content: '{word}'")
        synonyms = fetch_synonyms(word)
        logging.info(f"Fetched synonyms: {synonyms}")

        # Join the synonyms into a string
        result = ', '.join(synonyms)
        set_clipboard_content(result)
        logging.info(f"Processed synonyms: {result}")

        # Paste the result
        run_applescript(f"{APPLESCRIPT_DIR}/paste_synonym.applescript")
        logging.info("Synonyms pasted successfully")

    except Exception as e:
        logging.error(f"Error in synonym processing: {str(e)}")

def on_press(key):
    try:
        if key == keyboard.KeyCode.from_char('7'):
            print("Trigger key (7) pressed, processing synonym request")
            process_synonym_request()
            return False  # This suppresses the key press
    except AttributeError:
        pass
    return True  # Allow other key presses

def start_app():
    logging.info("Starting MyApp keyboard listener")
    print("Listening for 7 key press...")
    
    with keyboard.Listener(on_press=on_press, suppress=True) as listener:
        listener.join()

if __name__ == "__main__":
    start_app()