import sys
import requests

def fetch_synonyms(word):
    # Example API call to fetch synonyms
    response = requests.get(f"https://api.synonyms.com/synonyms/{word}")
    if response.status_code == 200:
        return response.json().get('synonyms', [])
    return []

if __name__ == "__main__":
    word = sys.argv[1]
    synonyms = fetch_synonyms(word)
    print(", ".join(synonyms))