#!/bin/sh
# run all 7 backup programs, set cron="yes" for each config to automate backup
/git/freenas-backup-apps/sonarrbackup.sh
/git/freenas-backup-apps/radarrbackup.sh
/git/freenas-backup-apps/lidarrbackup.sh
/git/freenas-backup-apps/sabnzbdbackup.sh
/git/freenas-backup-apps/tautullibackup.sh
/git/freenas-backup-apps/wpBackup.sh
/git/freenas-backup-apps/lazylibrarianbackup.sh
echo "Done"
