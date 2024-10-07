import sys
import requests
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Get API key from environment variable
api_key = os.getenv('ANTHROPIC_API_KEY')

def fetch_related_words(word):
    # Construct the prompt for the API
    prompt = f"Please provide related words for the Swedish word '{word}'. Return only the related words as a comma-separated list, without any additional text or explanation."

    # Set up the API request
    url = "https://api.anthropic.com/v1/completions"
    headers = {
        "Content-Type": "application/json",
        "X-API-Key": api_key
    }
    data = {
        "prompt": prompt,
        "model": "claude-v1",
        "max_tokens_to_sample": 100,
        "temperature": 0.5
    }

    try:
        # Make the API request
        response = requests.post(url, json=data, headers=headers)
        response.raise_for_status()  # Raise an exception for bad status codes

        # Extract the related words from the response
        related_words = response.json()['completion'].strip()
        return related_words

    except requests.exceptions.RequestException as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python word_api_handler.py <word>")
        sys.exit(1)

    word = sys.argv[1]
    related_words = fetch_related_words(word)
    print(related_words)
