import pyperclip

def get_clipboard_content():
    return pyperclip.paste()

def set_clipboard_content(content):
    pyperclip.copy(content)
