#!/bin/bash

printf "\n"
printf "\n"
echo "------------FILE MANAGEMENT SYSTEM---------------------"
printf "\n"

TMP="/tmp/matched_files.txt"
LOG="logs/actions.log"
ARCHIVE="archive_$(date '+%Y%m%d_%H%M%S').tar.gz"
TIME=$(date '+%Y-%m-%d %H:%M:%S') 

mkdir -p logs
> "$TMP"

read -p "Enter keyword to search: " KEY

for f in $(find . -type f); do
  grep -q "$KEY" "$f" && echo "$f" >> "$TMP"
done

if [ -s "$TMP" ]; then

printf "\n"
    echo "____________FILES:______________"
      printf "\n"
  echo "Files containing '$KEY':"
  cat "$TMP"
  printf "\n"
  echo "$TIME | Found matches for '$KEY'" >> "$LOG"
else
  echo "No files found with '$KEY'"
  printf "\n"
  echo "$TIME | No matches for '$KEY'" >> "$LOG"
  rm -f "$TMP"
  exit 0
fi
     printf "\n"
read -p "Backup matched files? (y/n): " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  tar -czf "$ARCHIVE" -T "$TMP" && \
       printf "\n"
  echo "Archived files to archive_$(date '+%Y-%m-%d_%H:%M:%S').tar.gz" && \
       printf "\n"
  echo "$TIME | Backup created: $ARCHIVE" >> "$LOG" || \
  printf "\n"
  echo "$TIME | Backup failed" >> "$LOG"
else
  echo "Backup skipped"
  printf "\n"
  echo "$TIME | Backup skipped" >> "$LOG"
fi

rm -f "$TMP"
echo "Log: $LOG"
printf "\n"
echo "------------GOOD BYEEEE :>------------------------"
printf "\n"
