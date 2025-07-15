#!/bin/bash

printf "\n"
echo "_________Enhanced Backup Service_________"
printf "\n"

SRC_DIR="./data"
DO_INCREMENTAL=false
DO_REPORT=false
BACKUP_TYPE=""

while getopts ":d:ir" opt; do
  case $opt in
    d) SRC_DIR="$OPTARG" ;;
    i) DO_INCREMENTAL=true ;;
    r) DO_REPORT=true ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND -1))

TMP="/tmp/matched_files.txt"
LOG="logs/actions.log"
DATE=$(date '+%Y%m%d')
TIME=$(date '+%Y-%m-%d %H:%M:%S')
ARCHIVE="archive_${DATE}_$(date '+%H%M%S').tar.gz"
BACKUP_FOLDER="backups/incremental-$DATE"
PREV_FOLDER=$(ls -d backups/incremental-* 2>/dev/null | sort | tail -n 1)

mkdir -p logs backups
> "$TMP"

read -p "Enter keyword to search: " KEY

for f in $(find "$SRC_DIR" -type f); do
  if grep -q "$KEY" "$f"; then
    REL_PATH="${f#${SRC_DIR}/}"
    echo "$REL_PATH" >> "$TMP"
  fi
done
printf "\n"
if [ -s "$TMP" ]; then
  echo "Files containing '$KEY':"
  cat "$TMP"
  echo "$TIME | Found matches for '$KEY'" >> "$LOG"
else
  echo "No files found with '$KEY'"
  echo "$TIME | No matches for '$KEY'" >> "$LOG"
  rm -f "$TMP"
  exit 1
fi
printf "\n"
read -p "Backup matched files (tar)? (y/n): " ans_tar
if [[ "$ans_tar" =~ ^[Yy]$ ]]; then
  tar -czf "$ARCHIVE" -C "$SRC_DIR" -T "$TMP"
  echo "Archived files to $ARCHIVE"
  echo "$TIME | Tar backup created: $ARCHIVE" >> "$LOG"
  BACKUP_TYPE="Tar"
else
  echo "Tar backup skipped"
  echo "$TIME | Tar backup skipped" >> "$LOG"
fi
printf "\n"
read -p "Backup matched files (incremental rsync)? (y/n): " ans_rsync
if [[ "$ans_rsync" =~ ^[Yy]$ ]]; then
  mkdir -p "$BACKUP_FOLDER"
  if [ "$DO_INCREMENTAL" = true ] && [ -d "$PREV_FOLDER" ] && [ "$PREV_FOLDER" != "$BACKUP_FOLDER" ]; then
    rsync -a --files-from="$TMP" --link-dest="../$(basename "$PREV_FOLDER")" "$SRC_DIR/" "$BACKUP_FOLDER/"
  else
    rsync -a --files-from="$TMP" "$SRC_DIR/" "$BACKUP_FOLDER/"
  fi
  printf "\n"
  echo "Incremental backup saved to $BACKUP_FOLDER"
  echo "$TIME | Rsync incremental backup: $BACKUP_FOLDER" >> "$LOG"
  BACKUP_TYPE="Incremental"
else
  echo "Rsync incremental backup skipped"
  echo "$TIME | Rsync incremental backup skipped" >> "$LOG"
fi

if [ "$DO_REPORT" = true ]; then
  COUNT=$(wc -l < "$TMP")
  SIZE=$(du -ch $(< "$TMP" sed "s|^|$SRC_DIR/|") 2>/dev/null | grep total$ | awk '{print $1}')
  {
    echo "Daily Backup Report - $(date '+%Y-%m-%d')"
    echo "================================"
    echo "$COUNT files archived, total $SIZE"
    echo "Source: $(realpath "$SRC_DIR")"
    echo "Destination: $BACKUP_FOLDER"
    echo "Backup Type: $BACKUP_TYPE"
    echo "Timestamp: $TIME"
  } > report.txt
  echo "$TIME | Report generated: report.txt" >> "$LOG"
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
  echo "Nothing new to commit. Tag not created."
fi
printf "\n"
rm -f "$TMP"
echo "Log: $LOG"
echo "------------GOOD BYEEEE :>------------------------"
