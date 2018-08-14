#!/bin/sh
#backup and restore Lidarr data

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

# Initialize defaults
cron=""
LIDARR_JAIL_NAME=""
POOL_PATH=""
APPS_PATH=""
LIDARR_SOURCE=""
LIDARR_DESTINATION=""
BACKUP_PATH=""
BACKUP_NAME=""

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
. $SCRIPTPATH/LidarrBackup-config
CONFIGS_PATH=$SCRIPTPATH/configs

# Check for LidarrBackup-config and set configuration
if ! [ -e $SCRIPTPATH/LidarrBackup-config ]; then
  echo "$SCRIPTPATH/LidarrBackup-config must exist."
  exit 1
fi

# Check that necessary variables were set by LidarrBackup-config
if [ -z $POOL_PATH ]; then
  echo 'Configuration error: POOL_PATH must be set'
  exit 1
fi

if [ -z $LIDARR_JAIL_NAME ]; then
  echo 'Configuration error: LIDARR_JAIL_NAME must be set'
  exit 1
fi


if [ -z $APPS_PATH ]; then
  echo 'Configuration error: APPS_PATH must be set'
  exit 1
fi
if [ -z $LIDARR_SOURCE ]; then
  echo 'Configuration error: LIDARR_SOURCE must be set'
  exit 1
fi
if [ -z $LIDARR_DESTINATION ]; then
  echo 'Configuration error: LIDARR_DESTINATION must be set'
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
if [ ! -d "${POOL_PATH}/${APPS_PATH}/${LIDARR_SOURCE}" ]; then
  echo
  echo "You made a LidarrBackup-config error the LIDARR_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${LIDARR_SOURCE} does not exist"
  mkdir -p ${POOL_PATH}/${APPS_PATH}/${LIDARR_SOURCE}
  chown -R media:media ${POOL_PATH}/${APPS_PATH}/${LIDARR_SOURCE}
  echo
  echo "The LIDARR_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${LIDARR_SOURCE} has been created for you"
  echo
  echo "Please run the script again to use that directory or edit the LidarrBackup-config"
  exit 1
fi

if [ ${POOL_PATH} == "/" ]; then
POOL_PATH=""
fi

echo $POOL_PATH
#cron="yes"
#LIDARR_JAIL_NAME="lidarr"
#POOL_PATH="/mnt/v1"
#APPS_PATH="apps"
#LIDARR_SOURCE="lidarr"
#LIDARR_DESTINATION="lidarr"
#BACKUP_PATH="apps"
#BACKUP_NAME="lidarrbackup.tar.gz"

if [ "$cron" != "yes" ]; then
 read -p "Enter '(B)ackup' to backup Lidarr or '(R)estore' to restore Lidarr: " choice
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
  #tar --exclude=./*.db-* -zcvf /mnt/v1/apps/lidarrbackup.tar.gz ./
  iocage exec ${LIDARR_JAIL_NAME} service lidarr stop
  cd ${POOL_PATH}/${APPS_PATH}/${LIDARR_SOURCE}
  echo
  echo "cd ${POOL_PATH}/${APPS_PATH}/${LIDARR_SOURCE}"
  tar --exclude='./lidarr.db-*' --exclude='lidarr.pid' -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*

  echo
  echo "tar --exclude='./lidarr.db-*' --exclude='lidarr.pid' -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*"
  echo
  echo "Backup complete file located at ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME}"
  echo
  iocage exec ${LIDARR_JAIL_NAME} service lidarr start
elif [ $choice == "R" ] || [ $choice == "r" ]; then
  # to restore lidarrbackup to directory plexpass2
    if [ ! -d "${POOL_PATH}/${APPS_PATH}/${LIDARR_DESTINATION}" ]; then
      mkdir -p ${POOL_PATH}/${APPS_PATH}/${LIDARR_DESTINATION}
      echo
      echo "mkdir -p ${POOL_PATH}/${APPS_PATH}/${LIDARR_DESTINATION}"
      echo
      chowm -R media:media ${POOL_PATH}/${APPS_PATH}/${LIDARR_DESTINATION}
      echo "chown -R media:media ${POOL_PATH}/${APPS_PATH}/${LIDARR_DESTINATION}"
    fi
  #tar xf lidarrbackup.tar.gz -C /mnt/v1/apps/plexpass2/
  iocage exec ${LIDARR_JAIL_NAME} service lidarr stop
  tar zvxpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${LIDARR_DESTINATION}
  echo
  echo "tar xpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${LIDARR_DESTINATION}"
  echo
  echo "Restore completed at ${POOL_PATH}/${APPS_PATH}/${LIDARR_DESTINATION}"
  echo
  iocage exec ${LIDARR_JAIL_NAME} service lidarr start
  iocage restart ${LIDARR_JAIL_NAME} 
else
  echo
  echo "Must enter '(B)ackup' to backup Lidarr or '(R)estore' to restore Lidarr: "
  echo
fi

