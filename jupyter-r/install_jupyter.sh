#!/bin/bash
set -e

REQUIREMENTS="/tmp/requirements.txt"

if [ -f "$REQUIREMENTS" ] && [ -s "$REQUIREMENTS" ]; then
    echo "requirements.txt found – restoring pinned versions..."
    pip3 install -r "$REQUIREMENTS" --break-system-packages
else
    echo "No requirements.txt found – installing jupyter and freezing versions..."
    pip3 install jupyter --break-system-packages
    mkdir -p /app
    pip3 freeze > /app/requirements.txt
    echo ""
    echo "============================================================"
    echo " requirements.txt written to /app/requirements.txt."
    echo " It will be automatically copied to notebooks/ on the next"
    echo " 'docker compose up'. From there, move it to jupyter-r/."
    echo "============================================================"
    echo ""
fi