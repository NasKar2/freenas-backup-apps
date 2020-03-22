#!/bin/sh
#backup and restore wordpress data

# Check for root privileges
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run with root privileges"
   exit 1
fi

# Initialize defaults

cron=""
POOL_PATH=""
APPS_PATH=""
CONFIG_PATH=""
JAIL_NAME=""
WP_SOURCE=""
WP_DESTINATION=""
BACKUP_PATH=""
BACKUP_NAME=""
DATABASE_NAME=""
DB_BACKUP_NAME=""
DB_PASSWORD=""

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
. $SCRIPTPATH/WordpressBackup-config
CONFIGS_PATH=$SCRIPTPATH/configs

# Check for WordpressBackup-config and set configuration
if ! [ -e $SCRIPTPATH/WordpressBackup-config ]; then
  echo "$SCRIPTPATH/WordpressBackup-config must exist."
  exit 1
fi

# Check that necessary variables were set by WordpressBackup-config
if [ -z $POOL_PATH ]; then
  echo 'Configuration error: POOL_PATH must be set'
  exit 1
fi

if [ -z $APPS_PATH ]; then
  echo 'Configuration error: APPS_PATH must be set'
  exit 1
fi

if [ -z $CONFIG_PATH ]; then
  echo 'Configuration error: CONFIG_PATH must be set'
  exit 1
fi

if [ -z $JAIL_NAME ]; then
  echo 'Configuration error: JAIL_NAME must be set'
  exit 1
fi


if [ -z $WP_SOURCE ]; then

  echo 'Configuration error: WP_SOURCE must be set'
  exit 1

fi

if [ -z $WP_DESTINATION ]; then

  echo 'Configuration error: WP_DESTINATION must be set'

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

if [ -z $DB_PASSWORD ]; then
  echo 'Configuration error: DB_PASSWORD must be set'
  exit 1
fi


if [ ! -d "${POOL_PATH}/${APPS_PATH}/${WP_SOURCE}" ]; then
  echo
  echo "You made a WordpressBackup-config error the WP_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${WP_SOURCE} does not exist"
  mkdir -p ${POOL_PATH}/${APPS_PATH}/${WP_SOURCE}
  echo
  echo "The WP_SOURCE directory ${POOL_PATH}/${APPS_PATH}/${WP_SOURCE} has been created for you"
  echo
  echo "Please run the script again to use that directory or edit the WordpressBackup-config"
  exit 1
fi

if [ ${POOL_PATH} == "/" ]; then
POOL_PATH=""
fi

echo $POOL_PATH
#cron="yes"
#POOL_PATH="/mnt/v1"
#APPS_PATH="apps"
#WP_SOURCE="wordpresspass"
#WP_DESTINATION="wordpresspass2"
#BACKUP_PATH="apps"
#BACKUP_NAME="wordpressbackup.tar.gz"

if [ "$cron" != "yes" ]; then
 read -p "Enter '(B)ackup' to backup Wordpress or '(R)estore' to restore Wordpress: " choice
fi
echo
if [ "${cron}" == "yes" ]; then
    choice="B"
#echo "cron = $cron"
fi
echo
if [ ${choice} == "B" ] || [ ${choice} == "b" ]; then
    if [ ! -d "${POOL_PATH}/${BACKUP_PATH}" ]; then
      mkdir -p ${POOL_PATH}/${BACKUP_PATH}
      echo "mkdir -p ${POOL_PATH}/${BACKUP_PATH}"
    fi
  # to backup
  #tar --exclude=./Plex\ Media\ Server/Cache -zcvf /mnt/v1/apps/wordpressbackup.tar.gz ./
#iocage exec ${JAIL_NAME} "mysqldump --single-transaction -h localhost -u "root" -p"${DB_PASSWORD}" "${DATABASE_NAME}" > "/${POOL_PATH}/${APPS_PATH}/${WP_SOURCE}/${DB_BACKUP_NAME}""
iocage exec ${JAIL_NAME} "mysqldump --single-transaction -h localhost -u "root" -p"${DB_PASSWORD}" "${DATABASE_NAME}" > "/${CONFIG_PATH}/${DB_BACKUP_NAME}""
#iocage exec ${JAIL_NAME} "mysqldump --defaults-extra-file=.my.cnf -u root "${DATABASE_NAME}" --single-transaction --quick --lock-tables=false > "/${CONFIG_PATH}/${DB_BACKUP_NAME}""
echo "Wordpress database backup ${DB_BACKUP_NAME} complete"
#ls -l /${POOL_PATH}/${BACKUP_PATH}/
  cd ${POOL_PATH}/${APPS_PATH}/${WP_SOURCE}
  echo "cd ${POOL_PATH}/${APPS_PATH}/${WP_SOURCE}"
  tar -zcf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./
  echo "tar-zcvf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} ./"
  echo "Backup complete file located at ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME}"
  chmod 400 ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME}
elif [ $choice == "R" ] || [ $choice == "r" ]; then
  # to restore wordpressbackup to directory wordpresspass2
    if [ ! -d "${POOL_PATH}/${APPS_PATH}/${WP_DESTINATION}" ]; then
      mkdir -p ${POOL_PATH}/${APPS_PATH}/${WP_DESTINATION}
      echo "mkdir -p ${POOL_PATH}/${APPS_PATH}/${WP_DESTINATION}"
    fi
  #tar xf wordpressbackup.tar.gz -C /mnt/v1/apps/wordpresspass2/
  tar zvxf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${WP_DESTINATION}
  echo "tar xf ${POOL_PATH}/${BACKUP_PATH}/${BACKUP_NAME} -C ${POOL_PATH}/${APPS_PATH}/${WP_DESTINATION}"
echo "restore database"
#iocage exec ${JAIL_NAME} "mysqldump --single-transaction -h localhost -u "root" -p"${DB_PASSWORD}" --databases "${DATABASE}" < "/${CONFIG_PATH}/${DB_BACKUP_NAME}""
iocage exec ${JAIL_NAME} "mysql -u "root" -p"${DB_PASSWORD}" "${DATABASE_NAME}" < "/${CONFIG_PATH}/${DB_BACKUP_NAME}""
#iocage exec wordpress "mysql -u "root" -p "wordpress" < "/${CONFIG_PATH}/wordpressorig.sql""
echo "mysql -u root -p wordpress < /${CONFIG_PATH}/${DB_BACKUP_NAME}"
  echo "Restore completed at ${POOL_PATH}/${APPS_PATH}/${WP_DESTINATION}"
else
  echo "Must enter '(B)ackup' to backup Wordpress or '(R)estore' to restore Wordpress: "
fi


