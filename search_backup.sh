#!/bin/bash 

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Default values
SRC_DIR="./data" 
DO_INCREMENTAL=false    #-i flag  
DO_REPORT=false         #-r flag  
BACKUP_TYPE="" 
 
# Function to print colored output
print_colored() {
    local color=$1
    local text=$2
    echo -e "${color}${text}${NC}"
}

# Function to print headers
print_header() {
    local text=$1
    echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}                    $text${NC}"
    echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════${NC}\n"
}

# Function to print section dividers
print_section() {
    local text=$1
    echo -e "\n${BOLD}${YELLOW}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${YELLOW}│  $text${NC}"
    echo -e "${BOLD}${YELLOW}└─────────────────────────────────────────────────────────┐${NC}\n"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓${NC} ${BOLD}$1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}✗${NC} ${BOLD}$1${NC}"
}

# Function to print info messages
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Parse command line options
while getopts ":d:ir" opt; do 
  case $opt in 
    d) SRC_DIR="$OPTARG" ;; 
    i) DO_INCREMENTAL=true ;; 
    r) DO_REPORT=true ;; 
    \?) print_error "Invalid option: -$OPTARG"; exit 0;;             # exit with zero if no choice    
  esac 
done 
shift $((OPTIND -1)) 
 
# Initialize variables
TMP="/tmp/matched_files.txt" 
LOG="logs/actions.log"
DATE=$(date '+%Y%m%d') 
TIME=$(date '+%Y-%m-%d %H:%M:%S') 
ARCHIVE="archive_${DATE}_$(date '+%H%M%S').tar.gz" 
BACKUP_FOLDER="backups/incremental-$DATE" 
PREV_FOLDER=$(ls -d backups/incremental-* 2>/dev/null | sort | tail -n 1) 
 
# Create necessary directories
mkdir -p logs backups 
> "$TMP" 
 
# Display welcome header
print_header "Enhanced Backup Service"
print_info "Source Directory: ${BOLD}${SRC_DIR}${NC}"
print_info "Date: ${BOLD}${DATE}${NC}"
print_info "Time: ${BOLD}${TIME}${NC}"

if [ "$DO_INCREMENTAL" = true ]; then
    print_info "Mode: ${BOLD}${GREEN}Incremental Backup Enabled${NC}"
fi

if [ "$DO_REPORT" = true ]; then
    print_info "Reporting: ${BOLD}${GREEN}Report Generation Enabled${NC}"
fi
 
print_section "File Search Configuration"
echo -ne "${BOLD}${PURPLE}Enter keyword to search: ${NC}"
read KEY 
 
print_info "Searching for files containing: ${BOLD}${YELLOW}'$KEY'${NC}"
echo -e "${CYAN}Scanning files...${NC}"

# Search for files containing the keyword
for f in $(find "$SRC_DIR" -type f); do 
  if grep -q "$KEY" "$f" 2>/dev/null; then 
    REL_PATH="${f#${SRC_DIR}/}" 
    echo "$REL_PATH" >> "$TMP" 
  fi 
done 
 
print_section "Search Results"
if [ -s "$TMP" ]; then 
  FILE_COUNT=$(wc -l < "$TMP")
  print_success "Found ${BOLD}${FILE_COUNT}${NC} files containing '${YELLOW}$KEY${NC}'"
  echo -e "\n${BOLD}${WHITE}Files found:${NC}"
  echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
  while IFS= read -r file; do
    echo -e "${CYAN}│${NC} ${GREEN}•${NC} $file"
  done < "$TMP"
  echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
  echo "$TIME | Found matches for '$KEY'" >> "$LOG" 
else 
  print_error "No files found containing '${YELLOW}$KEY${NC}'"
  echo "$TIME | No matches for '$KEY'" >> "$LOG" 
  rm -f "$TMP" 
  exit 1 
fi 

print_section "Backup Options"
echo -ne "${BOLD}${PURPLE}Create TAR archive backup? ${NC}${YELLOW}[y/N]: ${NC}"
read ans_tar 
if [[ "$ans_tar" =~ ^[Yy]$ ]]; then 
  print_info "Creating TAR archive..."
  if tar -czf "$ARCHIVE" -C "$SRC_DIR" -T "$TMP" 2>/dev/null; then
    print_success "Archive created: ${BOLD}${GREEN}$ARCHIVE${NC}"
    echo "$TIME | Tar backup created: $ARCHIVE" >> "$LOG" 
    BACKUP_TYPE="Tar"
  else
    print_error "Failed to create TAR archive"
  fi
else 
  print_warning "TAR backup skipped"
  echo "$TIME | Tar backup skipped" >> "$LOG" 
fi 

echo -ne "${BOLD}${PURPLE}Create incremental rsync backup? ${NC}${YELLOW}[y/N]: ${NC}"
read ans_rsync 
if [[ "$ans_rsync" =~ ^[Yy]$ ]]; then 
  print_info "Creating incremental backup..."
  mkdir -p "$BACKUP_FOLDER" 
  if [ "$DO_INCREMENTAL" = true ] && [ -d "$PREV_FOLDER" ] && [ "$PREV_FOLDER" != "$BACKUP_FOLDER" ]; then 
    print_info "Linking with previous backup: ${BOLD}$(basename "$PREV_FOLDER")${NC}"
    rsync -a --files-from="$TMP" --link-dest="../$(basename "$PREV_FOLDER")" "$SRC_DIR/" "$BACKUP_FOLDER/"
  else 
    rsync -a --files-from="$TMP" "$SRC_DIR/" "$BACKUP_FOLDER/"
  fi 
  print_success "Incremental backup saved to: ${BOLD}${GREEN}$BACKUP_FOLDER${NC}"
  echo "$TIME | Rsync incremental backup: $BACKUP_FOLDER" >> "$LOG" 
  BACKUP_TYPE="Incremental" 
else 
  print_warning "Rsync incremental backup skipped"
  echo "$TIME | Rsync incremental backup skipped" >> "$LOG" 
fi 
 
# Generate report if requested
if [ "$DO_REPORT" = true ]; then 
  print_section "Generating Report"
  COUNT=$(wc -l < "$TMP") 
  SIZE=$(du -ch $(< "$TMP" sed "s|^|$SRC_DIR/|") 2>/dev/null | grep total$ | awk '{print $1}') 
  { 
    echo "════════════════════════════════════════════════════════════════"
    echo "               Daily Backup Report - $(date '+%Y-%m-%d')"
    echo "════════════════════════════════════════════════════════════════"
    echo "📁 Files Processed    : $COUNT files"
    echo "📊 Total Size         : $SIZE" 
    echo "📂 Source Directory   : $(realpath "$SRC_DIR")" 
    echo "💾 Backup Location    : $BACKUP_FOLDER" 
    echo "🔧 Backup Type        : $BACKUP_TYPE" 
    echo "⏰ Timestamp          : $TIME" 
    echo "🔍 Search Keyword     : '$KEY'"
    echo "════════════════════════════════════════════════════════════════"
  } > report.txt 
  print_success "Report generated: ${BOLD}${GREEN}report.txt${NC}"
  echo "$TIME | Report generated: report.txt" >> "$LOG" 
fi 

print_section "Git Operations" 

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  print_info "Initializing new Git repository..."
  git init >/dev/null 2>&1
fi

print_info "Preparing Git operations..."
git checkout -B enhanced-backup >/dev/null 2>&1
git add . >/dev/null 2>&1
 
if git commit -m "Backup on $DATE" >/dev/null 2>&1; then 
  git tag "backup-$DATE" >/dev/null 2>&1
  print_success "Local commit created successfully"
  print_success "Tag created: ${BOLD}${GREEN}backup-$DATE${NC}"
  
  # Check if remote origin exists
  if git remote get-url origin >/dev/null 2>&1; then
    print_info "Pushing to remote repository..."
    if git push origin enhanced-backup >/dev/null 2>&1 && git push origin "backup-$DATE" >/dev/null 2>&1; then
      print_success "Successfully pushed to remote repository"
    else
      print_warning "Remote push failed - working locally only"
      print_info "Your backup is saved locally with tag: ${BOLD}backup-$DATE${NC}"
    fi
  else
    print_info "No remote repository configured - working locally"
    print_info "Your backup is saved locally with tag: ${BOLD}backup-$DATE${NC}"
    print_info "To add remote: ${BOLD}git remote add origin <your-repo-url>${NC}"
  fi
else 
  print_warning "Nothing new to commit since last backup"
fi 

# Cleanup and final messages
rm -f "$TMP" 

print_section "Summary"
print_success "Backup process completed successfully!"
print_info "Log file: ${BOLD}${LOG}${NC}"

# Final goodbye with style
echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║                                                              ║${NC}"
echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}${GREEN}✨ Thank you for using Enhanced Backup Service! ✨${NC}       ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}║${NC}                                                            ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}║${NC}  ${YELLOW}Have a great day! 😊${NC}                                    ${BOLD}${CYAN}║${NC}"
echo -e "${BOLD}${CYAN}║                                                              ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
