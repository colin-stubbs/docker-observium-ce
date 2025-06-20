#!/bin/bash

# ensure PHP will update to the timezone that should be used
echo "date.timezone = ${TZ}" > /etc/php/8.3/mods-available/timezone.ini

source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND

# EOF
