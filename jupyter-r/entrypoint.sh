#!/bin/bash
set -e

if [ -f /app/renv.lock ] && [ -s /app/renv.lock ]; then
    if [ ! -f /app/notebooks/renv.lock ] || ! cmp -s /app/renv.lock /app/notebooks/renv.lock; then
        cp /app/renv.lock /app/notebooks/renv.lock
        echo "============================================================"
        echo " renv.lock copied to your notebooks folder."
        echo " Move it to jupyter-r/ and commit it to your repository:"
        echo "   mv ../notebooks/renv.lock renv.lock"
        echo "   git add jupyter-r/renv.lock && git commit -m 'pin R packages'"
        echo "============================================================"
    fi
fi

if [ -f /app/requirements.txt ] && [ -s /app/requirements.txt ]; then
    if [ ! -f /app/notebooks/requirements.txt ] || ! cmp -s /app/requirements.txt /app/notebooks/requirements.txt; then
        cp /app/requirements.txt /app/notebooks/requirements.txt
        echo "============================================================"
        echo " requirements.txt copied to your notebooks folder."
        echo " Move it to jupyter-r/ and commit it to your repository:"
        echo "   mv ../notebooks/requirements.txt requirements.txt"
        echo "   git add jupyter-r/requirements.txt && git commit -m 'pin Python packages'"
        echo "============================================================"
    fi
fi

CERTFILE=/etc/jupyter/certs/cert.pem
KEYFILE=/etc/jupyter/certs/key.pem

if [ -f "$CERTFILE" ] && [ -f "$KEYFILE" ]; then
    exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser \
        --certfile="$CERTFILE" --keyfile="$KEYFILE" "$@"
else
    exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser "$@"
fi
