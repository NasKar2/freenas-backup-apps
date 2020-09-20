# freenas-backup-apps

### Use freenas-backup-appsdir instead.  Only one config and does all the jail apps.

## Clone git repository

```
git clone https://github.com/NasKar2/backupapps-freenas-iocage.git
```

to prevent edits to the config files from being changed with a git pull

```
git update-index --skip-worktree *-config
```

## Backup and Restore Freenas Apps Data

Script to help backup and restore the Sonarr, Radarr, Lidarr, Sabnzbd, Wordpress and Tautulli data directory

### Prerequisites

Edit each config file with your setup.  The config files will download when you do your git clone but any changes to the config files will not be overwritten when you do a 'git pull' to update to the latest version of the script. For example SonarrBackup-config

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
Edit file called RadarrBackup-config

Edit file called LidarrBackup-config

Edit file called SabnzbdBackup-config

Edit file called TautulliBackup-config

Edit file called WordpressBackup-config.  Change yourdatabasepassword to the mariadb password and set the file permission to 400.

```
chmod 400 WordpressBackup-config
```

## Install

```
./sonarrbackup.sh
./radarrbackup.sh
./lidarrbackup.sh
./sabnzbdbackup.sh
./tautullibackup.sh
./wpBackup.sh
```
## To run all in a cronjob

set cron="yes" in all the config files

```
./allbackup.sh
```
