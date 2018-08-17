#!/bin/sh
# run all 5 backup programs, set cron="yes" for each config to automate backup
/git/backupapps-freenas-iocage/sonarrbackup.sh
/git/backupapps-freenas-iocage/radarrbackup.sh
/git/backupapps-freenas-iocage/lidarrbackup.sh
/git/backupapps-freenas-iocage/sabnzbdbackup.sh
/git/backupapps-freenas-iocage/tautullibackup.sh
/git/backupapps-freenas-iocage/wpBackup.sh
echo "Done"
