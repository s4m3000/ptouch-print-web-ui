#!/bin/bash

# Move to the root directory
cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)/.."
cd $PROJECT_DIR

while getopts ":b" OPTION; do
    case $OPTION in
        b) 
            # Build Docker container
            docker stop ptouch-app 2>/dev/null
            docker rm ptouch-app 2>/dev/null
            docker build -t ptouch-print-web .
            ;;
    esac
done

# Run Docker container with volume mount
docker run -d --restart always -p 5000:5000 \
  --name ptouch-app \
  -v /config/ssh-key/container_shutdown_key:/etc/ssh/shutdown_key:ro \
  --privileged ptouch-print-web 
