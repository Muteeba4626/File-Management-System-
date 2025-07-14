#!/bin/bash

printf "\n"
printf "\n"
echo "----------- FILE MANAGEMENT SYSTEM --------------"
printf "\n"

TMP="/tmp/matched_files.txt"
LOG="logs/actions.log"
DATE=$(date '+%Y%m%d')
TIME=$(date '+%Y-%m-%d %H:%M:%S')
ARCHIVE="archive_${DATE}_$(date '+%H%M%S').tar.gz"
BACKUP_FOLDER="backups/incremental-$DATE"

mkdir -p logs backups
> "$TMP"

read -p "Enter keyword to search: " KEY

for f in $(find ./data -type f); do
  if grep -q "$KEY" "$f"; then
    REL_PATH="${f#./data/}"  # save relative path
    echo "$REL_PATH" >> "$TMP"
  fi
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
read -p "Backup matched files (tar)? (y/n): " ans_tar
if [[ "$ans_tar" =~ ^[Yy]$ ]]; then
  tar -czf "$ARCHIVE" -C "./data" -T "$TMP"
  printf "\n"
  echo "Archived files to $ARCHIVE"
  printf "\n"
  echo "$TIME | Tar backup created: $ARCHIVE" >> "$LOG"
else
  echo "Tar backup skipped"
  printf "\n"
  echo "$TIME | Tar backup skipped" >> "$LOG"
fi

printf "\n"
read -p "Backup matched files (incremental rsync)? (y/n): " ans_rsync
if [[ "$ans_rsync" =~ ^[Yy]$ ]]; then
  mkdir -p "$BACKUP_FOLDER"
  rsync -a --files-from="$TMP" "./data/" "$BACKUP_FOLDER/"
  printf "\n"
  echo "Incremental backup saved to $BACKUP_FOLDER"
  printf "\n"
  echo "$TIME | Rsync incremental backup: $BACKUP_FOLDER" >> "$LOG"
else
  echo "Rsync incremental backup skipped"
  printf "\n"
  echo "$TIME | Rsync incremental backup skipped" >> "$LOG"
fi

printf "\n"
echo "Pushing to Git..."
git checkout -B enhanced-backup
git add .

if git commit -m "Backup on $DATE"; then

    git tag "backup-$DATE"
    git push origin enhanced-backup
    git push origin "backup-$DATE"
    echo "Git tag 'backup-$DATE' created and pushed."
else
    echo "  Nothing new to commit. Tag not created."
fi




rm -f "$TMP"
echo "Log: $LOG"
printf "\n"
echo "------------GOOD BYEEEE :>------------------------"
printf "\n"
