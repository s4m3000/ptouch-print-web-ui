#!/bin/bash

# Get the script direcotry
cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

# Delete DevPod stuff to be sure that we don't have some permission issues
rm -r $SCRIPT_DIR/../.devpod*

# Prepare everything for shutdown
$SCRIPT_DIR/setup-shutdown.sh

# Build and run Docker container 
$SCRIPT_DIR/start-container.sh -b
