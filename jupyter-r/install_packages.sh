#!/bin/bash
set -e

LOCKFILE="/tmp/renv.lock"
SOURCEFILE="/tmp/install_packages.R"

if [ -f "$LOCKFILE" ] && [ -s "$LOCKFILE" ]; then
    echo "renv.lock found – restoring pinned R package versions..."

    # Retry up to 3 times. On failure, clear the renv source cache before
    # retrying so corrupted tarballs from interrupted downloads are discarded.
    success=false
    for attempt in 1 2 3; do
        if [ "$attempt" -gt 1 ]; then
            echo "Attempt $attempt/3: clearing renv source cache and retrying..."
            rm -rf "${R_USER_CACHE_DIR}/R/renv/source"
        fi
        if Rscript -e "
            if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv')
            renv::restore(lockfile = '/tmp/renv.lock', prompt = FALSE)
        "; then
            success=true
            break
        fi
    done

    if [ "$success" = false ]; then
        echo "renv::restore failed after 3 attempts."
        exit 1
    fi
else
    echo "No renv.lock found – installing all R packages and freezing versions..."
    Rscript "$SOURCEFILE"
    echo ""
    echo "============================================================"
    echo " renv.lock written to /app/renv.lock."
    echo " It will be automatically copied to notebooks/ on the next"
    echo " 'docker compose up'. From there, move it to jupyter-r/."
    echo "============================================================"
    echo ""
fi
