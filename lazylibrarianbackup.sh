#!/bin/sh
#backup and restore Lazy Librarian data

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

# Initialize defaults
cron=""
LAZYLIBRARIAN_JAIL_NAME=""
POOL_PATH=""
APPS_PATH=""
LAZYLIBRARIAN_SOURCE=""
LAZYLIBRARIAN_DESTINATION=""
BACKUP_PATH=""
BACKUP_NAME=""

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
. $SCRIPTPATH/LazylibrarianBackup-config
CONFIGS_PATH=$SCRIPTPATH/configs

# Check for LazylibrarianBackup-config and set configuration
if ! [ -e $SCRIPTPATH/LazylibrarianBackup-config ]; then
  echo "$SCRIPTPATH/LazylibrarianBackup-config must exist."
  exit 1
fi

# Check that necessary variables were set by LazylibrarianBackup-config
if [ -z $POOL_PATH ]; then
  echo 'Configuration error: POOL_PATH must be set'
  exit 1
fi

if [ -z $LAZYLIBRARIAN_JAIL_NAME ]; then
  echo 'Configuration error: LAZYLIBRARIAN_JAIL_NAME must be set'
  exit 1
fi


if [ -z $APPS_PATH ]; then
  echo 'Configuration error: APPS_PATH must be set'
  exit 1
fi
if [ -z $LAZYLIBRARIAN_SOURCE ]; then
  echo 'Configuration error: LAZYLIBRARIAN_SOURCE must be set'
  exit 1
fi
if [ -z $LAZYLIBRARIAN_DESTINATION ]; then
  echo 'Configuration error: LAZYLIBRARIAN_DESTINATION must be set'
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
if [ ! -d "${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_SOURCE}" ]; then
  echo
  echo "You made a LazylibrarianBackup-config error the LAZYLIBRARIAN_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_SOURCE} does not exist"
  mkdir -p ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_SOURCE}
  chown -R media:media ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_SOURCE}
  echo
  echo "The LAZYLIBRARIAN_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_SOURCE} has been created for you"
  echo
  echo "Please run the script again to use that directory or edit the LazylibrarianBackup-config"
  exit 1
fi

if [ ${POOL_PATH} == "/" ]; then
POOL_PATH=""
fi

echo $POOL_PATH
#cron="yes"
#LAZYLIBRARIAN_JAIL_NAME="lazylibrarian"
#POOL_PATH="/mnt/v1"
#APPS_PATH="apps"
#LAZYLIBRARIAN_SOURCE="lazylibrarian"
#LAZYLIBRARIAN_DESTINATION="lazylibrarian"
#BACKUP_PATH="apps"
#BACKUP_NAME="lazylibrarianbackup.tar.gz"

if [ "$cron" != "yes" ]; then
 read -p "Enter '(B)ackup' to backup Lazylibrarian or '(R)estore' to restore Lazylibrarian: " choice
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
#  iocage exec ${LAZYLIBRARIAN_JAIL_NAME} service lazylibrarian stop
  cd ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_SOURCE}
  echo
  echo "cd ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_SOURCE}"
  tar -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*

  echo
  echo "tar -zcpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./*"
  echo
  echo "Backup complete file located at ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME}"
  echo
#  iocage exec ${LAZYLIBRARIAN_JAIL_NAME} service lazylibrarian start
elif [ $choice == "R" ] || [ $choice == "r" ]; then
  # to restore lazylibrarianbackup to directory
    if [ ! -d "${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_DESTINATION}" ]; then
      mkdir -p ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_DESTINATION}
      echo
      echo "mkdir -p ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_DESTINATION}"
      echo
      chowm -R media:media ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_DESTINATION}
      echo "chown -R media:media ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_DESTINATION}"
    fi
  iocage exec ${LAZYLIBRARIAN_JAIL_NAME} service lazylibrarian stop
  tar zvxpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_DESTINATION}
  echo
  echo "tar xpf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_DESTINATION}"
  echo
  echo "Restore completed at ${POOL_PATH}/${APPS_PATH}/${LAZYLIBRARIAN_DESTINATION}"
  echo
  iocage exec ${LAZYLIBRARIAN_JAIL_NAME} service lazylibrarian start
  iocage restart ${LAZYLIBRARIAN_JAIL_NAME} 
else
  echo
  echo "Must enter '(B)ackup' to backup Lazylibrarian or '(R)estore' to restore Lazylibrarian: "
  echo
fi

