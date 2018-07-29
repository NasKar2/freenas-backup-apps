# backupapps-freenas-iocage

## Backup and Restore Freenas Apps Data

Script to help backup and restore the Sonarr data directory

### Prerequisites

Create file called RadarrBackup-config

The cron variable allows you to backup without asking for user input if set to cron="yes"

The APPS_PATH is the directory in our pool to put the sonarr data. In our example that would be /mnt/v1/apps/

The SONARR_SOURCE is the name of the sonarr data directory that is the source of the backup. In our example /mnt/v1/apps/sonarr/

The SONARR_DESTINATION is the name of the sonarr data directory that is the destination of the backup data. In our example /mnt/v1/apps/sonarr/

The BACKUP_PATH is the location in the pool for the backup file. In our example /mnt/v1/apps/

THE BACKUP_NAME is the name of the backup file

```
cron=""
SONARR_JAIL_NAME="sonarr"
POOL_PATH="/mnt/v1"
APPS_PATH="apps"
SONARR_SOURCE="sonarr"
SONARR_DESTINATION="sonarr"
BACKUP_PATH="backup"
BACKUP_NAME="sonarrbackup.tar.gz"
```

Create file called RadarrBackup-config

The cron variable allows you to backup without asking for user input if set to cron="yes"

The APPS_PATH is the directory in our pool to put the sonarr data. In our example that would be /mnt/v1/apps/

The RADARR_SOURCE is the name of the sonarr data directory that is the source of the backup. In our example /mnt/v1/apps/sonarr/

The RADARR_DESTINATION is the name of the sonarr data directory that is the destination of the backup data. In our example /mnt/v1/apps/sonarr/

The BACKUP_PATH is the location in the pool for the backup file. In our example /mnt/v1/apps/

THE BACKUP_NAME is the name of the backup file


```
cron=""
RADARR_JAIL_NAME="radarr"
POOL_PATH="/mnt/v1"
APPS_PATH="apps"
RADARR_SOURCE="radarr"
RADARR_DESTINATION="radarr"
BACKUP_PATH="backup"
BACKUP_NAME="radarrbackup.tar.gz"
```

## Install

```
./sonarrbackup.sh
./radarrbackup.sh
```
