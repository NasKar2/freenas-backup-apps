#!/bin/sh
#backup and restore Tautulli data

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

# Initialize defaults
cron=""
TAUTULLI_JAIL_NAME=""
POOL_PATH=""
APPS_PATH=""
TAUTULLI_SOURCE=""
TAUTULLI_DESTINATION=""
BACKUP_PATH=""
BACKUP_NAME=""

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
. $SCRIPTPATH/TautulliBackup-config
CONFIGS_PATH=$SCRIPTPATH/configs

# Check for TautulliBackup-config and set configuration
if ! [ -e $SCRIPTPATH/TautulliBackup-config ]; then
  echo "$SCRIPTPATH/TautulliBackup-config must exist."
  exit 1
fi

# Check that necessary variables were set by TautulliBackup-config
if [ -z $POOL_PATH ]; then
  echo 'Configuration error: POOL_PATH must be set'
  exit 1
fi

if [ -z $TAUTULLI_JAIL_NAME ]; then
  echo 'Configuration error: TAUTULLI_JAIL_NAME must be set'
  exit 1
fi


if [ -z $APPS_PATH ]; then
  echo 'Configuration error: APPS_PATH must be set'
  exit 1
fi
if [ -z $TAUTULLI_SOURCE ]; then
  echo 'Configuration error: TAUTULLI_SOURCE must be set'
  exit 1
fi
if [ -z $TAUTULLI_DESTINATION ]; then
  echo 'Configuration error: TAUTULLI_DESTINATION must be set'
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
if [ ! -d "${POOL_PATH}/${APPS_PATH}/${TAUTULLI_SOURCE}" ]; then
  echo
  echo "You made a TautulliBackup-config error the TAUTULLI_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_SOURCE} does not exist"
  mkdir -p ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_SOURCE}
  chown -R 109:109 ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_SOURCE}
  echo
  echo "The TAUTULLI_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_SOURCE} has been created for you"
  echo
  echo "Please run the script again to use that directory or edit the TautulliBackup-config"
  exit 1
fi

if [ ${POOL_PATH} == "/" ]; then
POOL_PATH=""
fi

echo $POOL_PATH
#cron="yes"
#TAUTULLI_JAIL_NAME="tautulli"
#POOL_PATH="/mnt/v1"
#APPS_PATH="apps"
#TAUTULLI_SOURCE="tautulli"
#TAUTULLI_DESTINATION="tautulli"
#BACKUP_PATH="apps"
#BACKUP_NAME="tautullibackup.tar.gz"

if [ "$cron" != "yes" ]; then
 read -p "Enter '(B)ackup' to backup Tautulli or '(R)estore' to restore Tautulli: " choice
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
  #tar --exclude=./*.db-* -zcvf /mnt/v1/apps/tautullibackup.tar.gz ./
#  iocage exec ${TAUTULLI_JAIL_NAME} service tautulli stop
  cd ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_SOURCE}
  echo
  echo "cd ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_SOURCE}"
  tar --exclude='./*.lock' --exclude='backups' --exclude='cache' --exclude='logs' --exclude='newsletters' -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*

  echo
  echo "tar --exclude='./*.lock' --exclude='backups' --exclude='cache' --exclude='logs' --exclude='newsletters' -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*"
  echo
  echo "Backup complete file located at ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME}"
  echo
 # iocage exec ${TAUTULLI_JAIL_NAME} service tautulli start
elif [ $choice == "R" ] || [ $choice == "r" ]; then
  # to restore tautullibackup to directory
    if [ ! -d "${POOL_PATH}/${APPS_PATH}/${TAUTULLI_DESTINATION}" ]; then
      mkdir -p ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_DESTINATION}
      echo
      echo "mkdir -p ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_DESTINATION}"
      echo
      chowm -R 109:109 ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_DESTINATION}
      echo "chown -R 109:109 ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_DESTINATION}"
    fi
  #tar xf tautullibackup.tar.gz -C /mnt/v1/apps/plexpass2/
  iocage exec ${TAUTULLI_JAIL_NAME} service tautulli stop
  tar zvxpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_DESTINATION}
  echo
  echo "tar xpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_DESTINATION}"
  echo
  echo "Restore completed at ${POOL_PATH}/${APPS_PATH}/${TAUTULLI_DESTINATION}"
  echo
  iocage exec ${TAUTULLI_JAIL_NAME} service tautulli start
  iocage restart ${TAUTULLI_JAIL_NAME} 
else
  echo
  echo "Must enter '(B)ackup' to backup Tautulli or '(R)estore' to restore Tautulli: "
  echo
fi

