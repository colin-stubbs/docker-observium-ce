#!/bin/bash

set -u

count=0
rc=1

while [ "${rc}" -ne 0 ]
do
   count=$((count + 1))
   echo "[${count}] Verifying connection to observium database."
   mysql -h "${OBSERVIUM_DB_HOST}" -u "${OBSERVIUM_DB_USER}" --password="${OBSERVIUM_DB_PASS}" -e "select 1" "${OBSERVIUM_DB_NAME}" >/dev/null
   rc=$?
   [ "${rc}" -ne 0 ] && sleep 5
done

echo "Connected to observium database successfully."

tables=$(mysql -h "${OBSERVIUM_DB_HOST}" -u "${OBSERVIUM_DB_USER}" --password="${OBSERVIUM_DB_PASS}" -e "show tables" "${OBSERVIUM_DB_NAME}" 2>/dev/null)

if [ -z "${tables}" ]
then
   echo "Setting /opt/observium/rrd directory to www-data:www-data."
   chown -v www-data:www-data /opt/observium/rrd
   echo "Initializing database schema in first time running for observium."
   /opt/observium/discovery.php -u
   /opt/observium/adduser.php "${OBSERVIUM_ADMIN_USER}" "${OBSERVIUM_ADMIN_PASS}" 10
   echo "Creating default alert tests."
   if [ -r /opt/observium/scripts/alerting.sql ]
   then
     mysql -h "${OBSERVIUM_DB_HOST}" -u "${OBSERVIUM_DB_USER}" --password="${OBSERVIUM_DB_PASS}" "${OBSERVIUM_DB_NAME}" < /opt/observium/scripts/alerting.sql
   fi
else
  echo "Database schema initialization has been done already."
  sleep 5
fi

{
  printf 'export OBSERVIUM_ADMIN_USER=%q\n' "${OBSERVIUM_ADMIN_USER}"
  printf 'export OBSERVIUM_ADMIN_PASS=%q\n' "${OBSERVIUM_ADMIN_PASS}"
  printf 'export OBSERVIUM_DB_HOST=%q\n' "${OBSERVIUM_DB_HOST}"
  printf 'export OBSERVIUM_DB_USER=%q\n' "${OBSERVIUM_DB_USER}"
  printf 'export OBSERVIUM_DB_PASS=%q\n' "${OBSERVIUM_DB_PASS}"
  printf 'export OBSERVIUM_DB_NAME=%q\n' "${OBSERVIUM_DB_NAME}"
} > /opt/observium/observium-setenv.sh

exit 0

# EOF
