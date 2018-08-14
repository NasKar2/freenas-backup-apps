#!/bin/sh
#backup and restore Sonarr data

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

# Initialize defaults
cron=""
SONARR_JAIL_NAME=""
POOL_PATH=""
APPS_PATH=""
SONARR_SOURCE=""
SONARR_DESTINATION=""
BACKUP_PATH=""
BACKUP_NAME=""

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
. $SCRIPTPATH/SonarrBackup-config
CONFIGS_PATH=$SCRIPTPATH/configs

# Check for SonarrBackup-config and set configuration
if ! [ -e $SCRIPTPATH/SonarrBackup-config ]; then
  echo "$SCRIPTPATH/SonarrBackup-config must exist."
  exit 1
fi

# Check that necessary variables were set by SonarrBackup-config
if [ -z $POOL_PATH ]; then
  echo 'Configuration error: POOL_PATH must be set'
  exit 1
fi

if [ -z $SONARR_JAIL_NAME ]; then
  echo 'Configuration error: SONARR_JAIL_NAME must be set'
  exit 1
fi


if [ -z $APPS_PATH ]; then
  echo 'Configuration error: APPS_PATH must be set'
  exit 1
fi
if [ -z $SONARR_SOURCE ]; then
  echo 'Configuration error: SONARR_SOURCE must be set'
  exit 1
fi
if [ -z $SONARR_DESTINATION ]; then
  echo 'Configuration error: SONARR_DESTINATION must be set'
  exit 1
fi
if [ -z $BACKUP_PATH ]; then
  echo 'Configuration error: BACKUP_PATH must be set'
  exit 1
fi
if [ -z $BACKUP_NAME ]; then
  echo 'Configuration error: BACKUP_NAME must be set'
  exit 1
fi
if [ ! -d "${POOL_PATH}/${APPS_PATH}/${SONARR_SOURCE}" ]; then
  echo
  echo "You made a SonarrBackup-config error the SONARR_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${SONARR_SOURCE} does not exist"
  mkdir -p ${POOL_PATH}/${APPS_PATH}/${SONARR_SOURCE}
  chown -R media:media ${POOL_PATH}/${APPS_PATH}/${SONARR_SOURCE}
  echo
  echo "The SONARR_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${SONARR_SOURCE} has been created for you"
  echo
  echo "Please run the script again to use that directory or edit the SonarrBackup-config"
  exit 1
fi

if [ ${POOL_PATH} == "/" ]; then
POOL_PATH=""
fi

echo $POOL_PATH
#cron="yes"
#SONARR_JAIL_NAME="sonarr"
#POOL_PATH="/mnt/v1"
#APPS_PATH="apps"
#SONARR_SOURCE="sonarr"
#SONARR_DESTINATION="sonarr"
#BACKUP_PATH="apps"
#BACKUP_NAME="sonarrbackup.tar.gz"

if [ "$cron" != "yes" ]; then
 read -p "Enter '(B)ackup' to backup Sonarr or '(R)estore' to restore Sonarr: " choice
fi
echo

if [ "${cron}" == "yes" ]; then
    choice="B"
fi

echo
if [ ${choice} == "B" ] || [ ${choice} == "b" ]; then
    if [ ! -d "${POOL_PATH}/${BACKUP_PATH}" ]; then
      mkdir -p ${POOL_PATH}/${BACKUP_PATH}
      echo "mkdir -p ${POOL_PATH}/${BACKUP_PATH}"
    fi
  # to backup
  #tar --exclude=./*.db-* -zcvf /mnt/v1/apps/sonarrbackup.tar.gz ./
  iocage exec ${SONARR_JAIL_NAME} service sonarr stop
  cd ${POOL_PATH}/${APPS_PATH}/${SONARR_SOURCE}
  echo
  echo "cd ${POOL_PATH}/${APPS_PATH}/${SONARR_SOURCE}"
  tar --exclude='./nzbdrone.db-*' --exclude='nzbdrone.pid' -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*

  echo
  echo "tar --exclude='./nzbdrone.db-*' --exclude='nzbdrone.pid' -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*"
  echo
  echo "Backup complete file located at ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME}"
  echo
  iocage exec ${SONARR_JAIL_NAME} service sonarr start
elif [ $choice == "R" ] || [ $choice == "r" ]; then
  # to restore sonarrbackup to directory plexpass2
    if [ ! -d "${POOL_PATH}/${APPS_PATH}/${SONARR_DESTINATION}" ]; then
      mkdir -p ${POOL_PATH}/${APPS_PATH}/${SONARR_DESTINATION}
      echo
      echo "mkdir -p ${POOL_PATH}/${APPS_PATH}/${SONARR_DESTINATION}"
      echo
      chowm -R media:media ${POOL_PATH}/${APPS_PATH}/${SONARR_DESTINATION}
      echo "chown -R media:media ${POOL_PATH}/${APPS_PATH}/${SONARR_DESTINATION}"
    fi
  #tar xf sonarrbackup.tar.gz -C /mnt/v1/apps/plexpass2/
  iocage exec ${SONARR_JAIL_NAME} service sonarr stop
  tar zvxpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${SONARR_DESTINATION}
  echo
  echo "tar xpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${SONARR_DESTINATION}"
  echo
  echo "Restore completed at ${POOL_PATH}/${APPS_PATH}/${SONARR_DESTINATION}"
  echo
  iocage exec ${SONARR_JAIL_NAME} service sonarr start
  iocage restart ${SONARR_JAIL_NAME} 
else
  echo
  echo "Must enter '(B)ackup' to backup Sonarr or '(R)estore' to restore Sonarr: "
  echo
fi

