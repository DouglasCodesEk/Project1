from pynput import keyboard
from config import TRIGGER_KEY

def start_listener(callback):
    def on_press(key):
        if key == TRIGGER_KEY:
            print(f"Trigger key (keypad_7) pressed, processing synonym request")
            callback()
            # We keep listening for more key presses

    print("Listening for keypad_7 key press...")
    with keyboard.Listener(on_press=on_press, suppress=True) as listener:
        listener.join()