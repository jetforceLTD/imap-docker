#!/bin/bash

echo "#################################################"
echo "# starting container boot up script (start.sh)  #"
echo "#################################################"

list=$(ls -1 /etc/supervisor/boot.d/* 2>/dev/null)
for i in $list ; do
  echo "execute : <$i>"
  $i
done

echo "#################################################"
echo "# check for disabled services"
echo "#"

for task in $DISABLED_SERVICES ; do
  echo "disable : $task"
  sed  -i "/program:$task/a autostart=false"  /etc/supervisor/services.d/$task
done

echo "#################################################"
echo "# execute init scripts for enabled services"
echo "#"

list=$(ls -1 /etc/supervisor/init.d/* 2>/dev/null)
for i in $list ; do
  if [ -e $i ] ; then
    task=`basename $i`
     if [ "$(grep 'autostart=false' /etc/supervisor/services.d/${task})" = "" ] ; then
       echo "execute: <$task>"
       $i
     fi
  fi
done

# wait until mysql server is available
while ! mysqladmin ping -h"$DB_HOST" --silent; do
    echo "Waiting for mysql server <$DB_HOST> ..."
    sleep 1
done
sleep 1
#echo "Check if database <${DB_NAME}.mail_virtual_users> exists ..."
#mysql -h ${DB_HOST} -u${DB_USER} -p${DB_PASSWORD} -e "desc ${DB_NAME}.mail_virtual_users" >/dev/null 2>&1
#if [ "$?" != "0" ] ; then
#  echo "Creating mysql tables ..."
#  mysql -h ${DB_HOST} -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < /mailschema.sql
#fi

echo "#################################################"
echo "# start supervisord"
echo "#"

trap 'kill -TERM $PID; wait $PID' TERM
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf &
PID=$!
wait $PID

echo "#################################################"
echo "# shutdown container"
echo "#"
list=$(ls -1 /etc/supervisor/shutdown.d/* 2>/dev/null)
for i in $list ; do
  echo "execute: <$i>"
  $i
done

