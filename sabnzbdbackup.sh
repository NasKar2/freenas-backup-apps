#!/bin/sh
#backup and restore Sabnzbd data

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

# Initialize defaults
cron=""
SABNZBD_JAIL_NAME=""
POOL_PATH=""
APPS_PATH=""
SABNZBD_SOURCE=""
SABNZBD_DESTINATION=""
BACKUP_PATH=""
BACKUP_NAME=""

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
. $SCRIPTPATH/SabnzbdBackup-config
CONFIGS_PATH=$SCRIPTPATH/configs

# Check for SabnzbdBackup-config and set configuration
if ! [ -e $SCRIPTPATH/SabnzbdBackup-config ]; then
  echo "$SCRIPTPATH/SabnzbdBackup-config must exist."
  exit 1
fi

# Check that necessary variables were set by SabnzbdBackup-config
if [ -z $POOL_PATH ]; then
  echo 'Configuration error: POOL_PATH must be set'
  exit 1
fi

if [ -z $SABNZBD_JAIL_NAME ]; then
  echo 'Configuration error: SABNZBD_JAIL_NAME must be set'
  exit 1
fi


if [ -z $APPS_PATH ]; then
  echo 'Configuration error: APPS_PATH must be set'
  exit 1
fi
if [ -z $SABNZBD_SOURCE ]; then
  echo 'Configuration error: SABNZBD_SOURCE must be set'
  exit 1
fi
if [ -z $SABNZBD_DESTINATION ]; then
  echo 'Configuration error: SABNZBD_DESTINATION must be set'
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
if [ ! -d "${POOL_PATH}/${APPS_PATH}/${SABNZBD_SOURCE}" ]; then
  echo
  echo "You made a SabnzbdBackup-config error the SABNZBD_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${SABNZBD_SOURCE} does not exist"
  mkdir -p ${POOL_PATH}/${APPS_PATH}/${SABNZBD_SOURCE}
  chown -R media:media ${POOL_PATH}/${APPS_PATH}/${SABNZBD_SOURCE}
  echo
  echo "The SABNZBD_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${SABNZBD_SOURCE} has been created for you"
  echo
  echo "Please run the script again to use that directory or edit the SabnzbdBackup-config"
  exit 1
fi

if [ ${POOL_PATH} == "/" ]; then
POOL_PATH=""
fi

echo $POOL_PATH
#cron="yes"
#SABNZBD_JAIL_NAME="sabnzbd"
#POOL_PATH="/mnt/v1"
#APPS_PATH="apps"
#SABNZBD_SOURCE="sabnzbd"
#SABNZBD_DESTINATION="sabnzbd"
#BACKUP_PATH="apps"
#BACKUP_NAME="sabnzbdbackup.tar.gz"

if [ "$cron" != "yes" ]; then
 read -p "Enter '(B)ackup' to backup Sabnzbd or '(R)estore' to restore Sabnzbd: " choice
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
#  iocage exec ${SABNZBD_JAIL_NAME} service sabnzbd stop
  cd ${POOL_PATH}/${APPS_PATH}/${SABNZBD_SOURCE}
  echo
  echo "cd ${POOL_PATH}/${APPS_PATH}/${SABNZBD_SOURCE}"
  tar -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*

  echo
  echo "tar -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*"
  echo
  echo "Backup complete file located at ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME}"
  echo
#  iocage exec ${SABNZBD_JAIL_NAME} service sabnzbd start
elif [ $choice == "R" ] || [ $choice == "r" ]; then
  # to restore sabnzbdbackup to directory
    if [ ! -d "${POOL_PATH}/${APPS_PATH}/${SABNZBD_DESTINATION}" ]; then
      mkdir -p ${POOL_PATH}/${APPS_PATH}/${SABNZBD_DESTINATION}
      echo
      echo "mkdir -p ${POOL_PATH}/${APPS_PATH}/${SABNZBD_DESTINATION}"
      echo
      chowm -R media:media ${POOL_PATH}/${APPS_PATH}/${SABNZBD_DESTINATION}
      echo "chown -R media:media ${POOL_PATH}/${APPS_PATH}/${SABNZBD_DESTINATION}"
    fi
  iocage exec ${SABNZBD_JAIL_NAME} service sabnzbd stop
  tar zvxpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${SABNZBD_DESTINATION}
  echo
  echo "tar xpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${SABNZBD_DESTINATION}"
  echo
  echo "Restore completed at ${POOL_PATH}/${APPS_PATH}/${SABNZBD_DESTINATION}"
  echo
  iocage exec ${SABNZBD_JAIL_NAME} service sabnzbd start
  iocage restart ${SABNZBD_JAIL_NAME} 
else
  echo
  echo "Must enter '(B)ackup' to backup Sabnzbd or '(R)estore' to restore Sabnzbd: "
  echo
fi

