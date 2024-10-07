#!/bin/bash

# Define the base project path
BASE_PATH="/Users/admin/Projects/MyApp"

# Load environment variables from the .env file using absolute path
source "$BASE_PATH/2_APIenvironment/2_app.env"

# Check if the API key is set
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "Error: ANTHROPIC_API_KEY is not set in $BASE_PATH/2_APIenvironment/2_app.env."
    echo "Please set the API key in the .env file."
    exit 1
fi

# Check if the Python script exists
if [ ! -f "$BASE_PATH/2_APIenvironment/1_request.py" ]; then
    echo "Error: 1_request.py not found in 2_APIenvironment directory."
    echo "Please ensure the Python script is in the correct location."
    exit 1
fi

# Check if the required AppleScripts exist
if [ ! -f "$BASE_PATH/3_AppleScripts/1_getclipboard.applescript" ] || [ ! -f "$BASE_PATH/3_AppleScripts/2_pastesynonym.applescript" ]; then
    echo "Error: Required AppleScripts not found in 3_AppleScripts directory."
    echo "Please ensure the AppleScripts are in the correct location."
    exit 1
fi

# Check if the regex_extractor.py script exists
if [ ! -f "$BASE_PATH/6_utils/regex_extractor.py" ]; then
    echo "Error: regex_extractor.py not found in 6_utils directory."
    echo "Please ensure the regex_extractor.py script is in the correct location."
    exit 1
fi

# Check if the log_handler.sh script exists
if [ ! -f "$BASE_PATH/6_utils/log_handler.sh" ]; then
    echo "Error: log_handler.sh not found in 6_utils directory."
    echo "Please ensure log_handler.sh is in the correct location."
    exit 1
fi

# Optional: Check if scripts are executable
if [ ! -x "$BASE_PATH/6_utils/regex_extractor.py" ]; then
    echo "Error: regex_extractor.py is not executable. Please run 'chmod +x $BASE_PATH/6_utils/regex_extractor.py'."
    exit 1
fi

if [ ! -x "$BASE_PATH/6_utils/log_handler.sh" ]; then
    echo "Error: log_handler.sh is not executable. Please run 'chmod +x $BASE_PATH/6_utils/log_handler.sh'."
    exit 1
fi

# If everything is good
echo "Environment validation successful."
