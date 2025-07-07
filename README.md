#File Management Utility

A command-line tool for searching files containing specific keywords and creating backup archives.

## Features

- **Search Tool**: Scans directories for files containing specified keywords
- **Backup Option**: Creates timestamped tar.gz archives of matched files
- **Logging**: Logs all actions with timestamps to a persistent log file
- **Colored Output**: Uses ANSI colors for better readability
- **Verbose Mode**: Optional detailed output showing line numbers and matches
- **File Exclusion**: Ability to exclude specific file patterns

## Project Structure

```
file-manager/
├── search_backup.sh    # Main script
├── logs/
│   └── actions.log     # Activity log file
└── README.md          # This documentation
```

## Usage

### Basic Usage
```bash
./search_backup.sh /path/to/directory "keyword"
```

### Advanced Usage
```bash
# Enable verbose output
./search_backup.sh -v /var/log "error"

# Exclude specific file types
./search_backup.sh --exclude=*.log /home/user "TODO"

# Show help
./search_backup.sh --help
```

## Examples

### Example 1: Search for "error" in log files
```bash
./search_backup.sh /var/log "error"
```

**Expected Output:**
```
_________File Management System_________

enter keyword to search: error

Searching for files containing 'error' 
Found 3 files containing 'error'

Create backup archive? (y/n): y
Creating backup archive: archive_20250707_101605.tar.gz
Backup created successfully: archive_20250707_101605.tar.gz
Operation completed. Check logs/actions.log for details.
``

**Sample Log Entries:**
```
2025-07-07 10:15:32 | Script started - searching for 'error' in '/var/log'
2025-07-07 10:15:32 | Search: 3 files matched keyword "error"
2025-07-07 10:16:05 | Archived 3 files to archive_20250707_101605.tar.gz
2025-07-07 10:16:05 | Script completed
```

## Key Linux Commands Used

- **grep**: For searching text patterns within files
- **find**: For locating files in directory trees
- **tar**: For creating compressed archives
- **date**: For timestamp generation
- **mkdir**: For creating directories
- **wc**: For counting lines in files
- **read**: For user input prompts

## Git Workflow

This project follows a clean Git workflow with meaningful commits:

1. **Initial Setup**: `git init` and basic project structure
2. **Feature Development**: Separate commits for each major feature
3. **Documentation**: Final commit for README and documentation
4. **Versioning**: Proper commit messages following conventional format

### Commit History
```
feat: add search script
feat: add archiving function and logging
docs: add README and sample logs
```

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd file-manager
```

2. Make the script executable:
```bash
chmod +x search_backup.sh
```

3. Run the script:
```bash
./search_backup.sh /path/to/search "keyword"
```

## Requirements

- Bash shell (version 4.0+)
- Standard Linux utilities: grep, find, tar, date
- Read permissions on target directories
- Write permissions for log files and archives

## Script Features Breakdown

### Search Functionality
- Recursively searches through directories
- Uses `grep` for pattern matching
- Handles binary files gracefully
- Supports file exclusion patterns

### Backup Creation
- Creates timestamped tar.gz archives
- Preserves file structure and permissions
- Validates archive creation success
- Stores archives in current directory

### Logging System
- Persistent logging across script runs
- Timestamp format: YYYY-MM-DD HH:MM:SS
- Automatic log directory creation
- Both file and console output options

### Error Handling
- Input validation for directories and keywords
- Permission checking before operations
- Graceful handling of missing files
- User-friendly error messages

## Author

DevOps Student Muteeba Shahzad - Week 1 Linux + Git Project

## License

This project is for educational purposes as part of DevOps training.
