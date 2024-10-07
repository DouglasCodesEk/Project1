import re
import random
from flask import Flask, request, jsonify
from flask_cors import CORS

# Comment out or remove the problematic import
# from nltk.chat.util import Chat, reflections

# If you need chat functionality, consider using a different library
# or implementing your own chat logic

pairs = [
    [
        r"hi|hello|hey",
        ["Hello!", "Hi there!", "Hey! How can I help you today?"]
    ],
    [
        r"what can you do",
        ["I can provide information about our projects, technologies, and services. What would you like to know?"]
    ],
    [
        r"tell me about (.*)",
        ["Sure, I'd be happy to tell you about %1. What specific aspects are you interested in?"]
    ],
    [
        r"bye|goodbye",
        ["Goodbye!", "It was nice chatting with you. Have a great day!"]
    ]
]

# If you need chat functionality, consider using a different library
# or implementing your own chat logic
# chatbot = Chat(pairs, reflections)

app = Flask(__name__)
CORS(app)

@app.route('/api/chat', methods=['POST'])
def chat():
    user_input = request.json['message']
    response = get_response(user_input)
    return jsonify({'response': response})

def get_response(user_input):
    for pattern, responses in pairs:
        if re.search(pattern, user_input, re.IGNORECASE):
            return random.choice(responses)
    return "I'm sorry, I didn't understand that. Could you please rephrase?"

if __name__ == '__main__':
    app.run(debug=True)
