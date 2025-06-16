#!/bin/bash

# Get the script direcotry
cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

# Prepare everything for shutdown
$SCRIPT_DIR/setup-shutdown.sh

# Build and run Docker container 
$SCRIPT_DIR/start-container.sh -b
