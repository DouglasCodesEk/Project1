# MyApp - Swedish Synonym Fetcher

This application fetches synonyms for Swedish words copied to the clipboard when triggered by pressing the keypad_7 key.

## Setup

1. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

2. Create a `.env` file in the project root directory with your Anthropic API key:
   ```
   ANTHROPIC_API_KEY=your_api_key_here
   ```

3. Run the application:
   ```
   python3 src/main.py
   ```

## Usage

1. Copy a Swedish word to your clipboard.
2. Press the keypad_7 key to fetch and paste synonyms for the word.

## Note

This application requires appropriate permissions to monitor keyboard input. You may need to grant accessibility permissions to your terminal or IDE in System Preferences > Security & Privacy > Privacy > Accessibility.
