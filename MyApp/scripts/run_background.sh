#!/bin/bash

# Change to the project directory
cd "$(dirname "$0")/.." || exit 1

# Run the main Python script
python3 src/main.py 2>&1 | tee -a logs/myapp.log