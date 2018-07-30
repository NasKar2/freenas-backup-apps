#!/bin/sh
#backup and restore Radarr data

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

# Initialize defaults
cron=""
RADARR_JAIL_NAME=""
POOL_PATH=""
APPS_PATH=""
RADARR_SOURCE=""
RADARR_DESTINATION=""
BACKUP_PATH=""
BACKUP_NAME=""

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
. $SCRIPTPATH/RadarrBackup-config
CONFIGS_PATH=$SCRIPTPATH/configs

# Check for RadarrBackup-config and set configuration
if ! [ -e $SCRIPTPATH/RadarrBackup-config ]; then
  echo "$SCRIPTPATH/RadarrBackup-config must exist."
  exit 1
fi

# Check that necessary variables were set by RadarrBackup-config
if [ -z $POOL_PATH ]; then
  echo 'Configuration error: POOL_PATH must be set'
  exit 1
fi

if [ -z $RADARR_JAIL_NAME ]; then
  echo 'Configuration error: RADARR_JAIL_NAME must be set'
  exit 1
fi


if [ -z $APPS_PATH ]; then
  echo 'Configuration error: APPS_PATH must be set'
  exit 1
fi
if [ -z $RADARR_SOURCE ]; then
  echo 'Configuration error: RADARR_SOURCE must be set'
  exit 1
fi
if [ -z $RADARR_DESTINATION ]; then
  echo 'Configuration error: RADARR_DESTINATION must be set'
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
if [ ! -d "${POOL_PATH}/${APPS_PATH}/${RADARR_SOURCE}" ]; then
  echo
  echo "You made a RadarrBackup-config error the RADARR_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${RADARR_SOURCE} does not exist"
  mkdir -p ${POOL_PATH}/${APPS_PATH}/${RADARR_SOURCE}
  chown -R media:media ${POOL_PATH}/${APPS_PATH}/${RADARR_SOURCE}
  echo
  echo "The RADARR_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${RADARR_SOURCE} has been created for you"
  echo
  echo "Please run the script again to use that directory or edit the RadarrBackup-config"
  exit 1
fi

if [ ${POOL_PATH} == "/" ]; then
POOL_PATH=""
fi

echo $POOL_PATH
#cron="yes"
#RADARR_JAIL_NAME="radarr"
#POOL_PATH="/mnt/v1"
#APPS_PATH="apps"
#RADARR_SOURCE="radarr"
#RADARR_DESTINATION="radarr"
#BACKUP_PATH="apps"
#BACKUP_NAME="radarrbackup.tar.gz"

if [ "$cron" != "yes" ]; then
 read -p "Enter '(B)ackup' to backup Radarr or '(R)estore' to restore Radarr: " choice
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
  #tar --exclude=./*.db-* -zcvf /mnt/v1/apps/radarrbackup.tar.gz ./
  iocage exec ${RADARR_JAIL_NAME} service radarr stop
  cd ${POOL_PATH}/${APPS_PATH}/${RADARR_SOURCE}
  echo
  echo "cd ${POOL_PATH}/${APPS_PATH}/${RADARR_SOURCE}"
  tar --exclude='./nzbdrone.db-*' --exclude='nzbdrone.pid' -zcvpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*

  echo
  echo "tar --exclude='./nzbdrone.db-*' --exclude='nzbdrone.pid' -zcvpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*"
  echo
  echo "Backup complete file located at ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME}"
  echo
  iocage exec ${RADARR_JAIL_NAME} service radarr start
elif [ $choice == "R" ] || [ $choice == "r" ]; then
  # to restore radarrbackup to directory plexpass2
    if [ ! -d "${POOL_PATH}/${APPS_PATH}/${RADARR_DESTINATION}" ]; then
      mkdir -p ${POOL_PATH}/${APPS_PATH}/${RADARR_DESTINATION}
      echo
      echo "mkdir -p ${POOL_PATH}/${APPS_PATH}/${RADARR_DESTINATION}"
      echo
      chowm -R media:media ${POOL_PATH}/${APPS_PATH}/${RADARR_DESTINATION}
      echo "chown -R media:media ${POOL_PATH}/${APPS_PATH}/${RADARR_DESTINATION}"
    fi
  #tar xf radarrbackup.tar.gz -C /mnt/v1/apps/plexpass2/
  iocage exec ${RADARR_JAIL_NAME} service radarr stop
  tar zvxpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${RADARR_DESTINATION}
  echo
  echo "tar xpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${RADARR_DESTINATION}"
  echo
  echo "Restore completed at ${POOL_PATH}/${APPS_PATH}/${RADARR_DESTINATION}"
  echo
  iocage exec ${RADARR_JAIL_NAME} service radarr start
  iocage restart ${RADARR_JAIL_NAME} 
else
  echo
  echo "Must enter '(B)ackup' to backup Radarr or '(R)estore' to restore Radarr: "
  echo
fi

