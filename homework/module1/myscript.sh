#!/bin/bash
LOG_FILE="$HOME/myscript.log"

while true; do
    date >> "$LOG_FILE"
    sleep 1
done
