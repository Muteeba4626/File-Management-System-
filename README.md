# Enhanced Backup Service
A comprehensive DevOps backup solution with incremental backups, automated scheduling, Git versioning, and web-server integration.

## Features
- **CLI Flag Support**: Command-line options using `getopts` for flexible operation
- **Incremental Backups**: Efficient `rsync`-based incremental backup system
- **Daily Reports**: Automated generation of backup statistics and file counts
- **Cron Scheduling**: Automated daily backup execution
- **Git Versioning**: Automatic tagging and version control for each backup
- **Web Server Integration**: Apache/Nginx configuration for web-based backup access
- **Logging**: Comprehensive logging with timestamps
- **Error Handling**: Robust error detection and reporting

## Project Structure
```
enhanced-backup/
├── search_backup.sh       # Main enhanced backup script
├── backups/
│   ├── incremental-20250714/  # Daily incremental backups
│   └── incremental-20250713/
├── logs/
│   └── actions.log        # Activity log file
├── report.txt             # Daily backup report
├── cronjob.txt           # Cron configuration
├── web-config/           # Web server configuration
│   └── apache-backup.conf
└── README.md             # This documentation
```

## Usage

### Basic Usage
```bash
./search_backup.sh -d /path/to/source -i -r
```

### Command Line Options
- `-d <directory>`: Set source directory (default: `./data`)
- `-i`: Enable incremental backup mode
- `-r`: Generate daily report with file count and total size

### Examples

#### Example 1: Basic incremental backup with report
```bash
./search_backup.sh -d /home/user/documents -i -r
```

**Expected Output:**
```
_________Enhanced Backup Service_________
Source Directory: /home/user/documents
Backup Mode: Incremental
Creating incremental backup: backups/incremental-20250714
Running rsync with link-dest optimization...
Backup completed successfully!
Generating daily report...
Report saved to: report.txt
```

#### Example 2: Default directory backup
```bash
./search_backup.sh -i -r
```

**Sample Report Output (`report.txt`):**
```
Daily Backup Report - 2025-07-14
================================
3 files archived, total 2.1M
Source: /home/user/data
Destination: backups/incremental-20250714
Backup Type: Incremental
Timestamp: 2025-07-14 01:00:32
```

**Sample Log Entries:**
```
2025-07-14 01:00:30 | Script started - incremental backup mode enabled
2025-07-14 01:00:31 | Source directory: /home/user/data
2025-07-14 01:00:32 | Incremental backup created: backups/incremental-20250714
2025-07-14 01:00:32 | Report generated: 3 files, 2.1M total
2025-07-14 01:00:33 | Git tag created: backup-20250714
2025-07-14 01:00:33 | Script completed successfully
```

## Key Technologies Used
- **rsync**: For efficient incremental backups with `--link-dest` optimization
- **getopts**: For command-line argument parsing
- **du/awk**: For file size calculations and reporting
- **cron**: For automated scheduling
- **git**: For version control and tagging
- **Apache/Nginx**: For web-based backup access

## Installation & Setup

### 1. Clone and Setup
```bash
git clone <repository-url>
cd enhanced-backup
git checkout -b enhanced-backup
chmod +x search_backup.sh
```

### 2. Cron Setup
```bash
# Install cron job
crontab cronjob.txt

# Verify cron installation
crontab -l
```

**Cron Configuration (`cronjob.txt`):**
```
# Daily backup at 1:00 AM
0 1 * * * /path/to/search_backup.sh -d /home/user/data -i -r
```

### 3. Web Server Configuration

#### Apache Setup
```bash
# Install Apache
sudo apt update && sudo apt install apache2

# Enable and start service
sudo systemctl enable --now apache2

# Copy backups to web root
sudo cp -r backups /var/www/html/backups

# Apply configuration
sudo cp web-config/apache-backup.conf /etc/apache2/sites-available/
sudo a2ensite apache-backup
sudo systemctl reload apache2
```

#### Nginx Setup
```bash
# Install Nginx
sudo apt update && sudo apt install nginx

# Enable and start service
sudo systemctl enable --now nginx

# Copy backups to web root
sudo cp -r backups /var/www/html/backups

# Apply configuration
sudo cp web-config/nginx-backup.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/nginx-backup.conf /etc/nginx/sites-enabled/
sudo systemctl reload nginx
```

### 4. Verification
```bash
# Test web access
curl http://localhost/backups/

# Check backup functionality
./search_backup.sh -d ./data -i -r
```

## Git Workflow & Versioning

### Automatic Tagging
The script automatically creates Git tags for each backup:
```bash
git tag backup-$(date +%Y%m%d)
git push --tags
```

### Branch Structure
- **Main Branch**: `enhanced-backup`
- **Tag Format**: `backup-YYYYMMDD`
- **Required Tags**: Minimum 2 tags for project completion

### Commit History
```
feat: add getopts CLI flag support
feat: implement rsync incremental backups
feat: add daily report generation with du/awk
feat: add cron scheduling configuration
feat: implement git auto-tagging
feat: add Apache/Nginx web server integration
docs: update README with enhanced features
```

## Web Server Integration

### Apache VirtualHost Configuration
```apache
<VirtualHost *:80>
    DocumentRoot /var/www/html
    
    <Directory "/var/www/html/backups">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex disabled
    </Directory>
    
    Alias /backups /var/www/html/backups
</VirtualHost>
```

### Nginx Server Block
```nginx
server {
    listen 80;
    root /var/www/html;
    
    location /backups/ {
        alias /var/www/html/backups/;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
    }
}
```

## Script Features Breakdown

### Incremental Backup System
- Uses `rsync -a --link-dest=../previous` for space-efficient backups
- Maintains file permissions and timestamps
- Creates hard links for unchanged files
- Organizes backups by date: `backups/incremental-YYYYMMDD`

### CLI Flag Processing
- Robust `getopts` implementation
- Input validation and error handling
- Default value fallbacks
- Help message support

### Daily Reporting
- File count statistics using `find` and `wc`
- Total size calculation with `du` and `awk`
- Formatted output with timestamps
- Persistent report storage

### Automation Features
- Cron-ready script design
- Non-interactive execution mode
- Comprehensive error handling
- Exit code management for monitoring

## Requirements
- Bash shell (version 4.0+)
- rsync utility
- Standard Linux utilities: du, awk, find, date
- Git for version control
- Apache or Nginx web server
- Cron daemon
- Read permissions on source directories
- Write permissions for backup destinations

## Troubleshooting

### Common Issues
1. **Permission Denied**: Ensure script has execute permissions
2. **Rsync Errors**: Check source directory accessibility
3. **Cron Not Running**: Verify cron service status
4. **Web Access Issues**: Check Apache/Nginx configuration and permissions

### Debug Mode
```bash
# Enable verbose output
bash -x ./search_backup.sh -d /path/to/data -i -r
```

## Author
DevOps Student Muteeba Shahzad - Enhanced Backup Service Project  
Building on Week 1 Linux + Git foundations with advanced DevOps practices

## License
This project is for educational purposes as part of DevOps Pre-Requisite Course training.

## Time Investment
Approximately 4 hours for complete implementation and testing.
