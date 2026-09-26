#!/bin/bash

set -eu

# Match the PHP series installed in the image (PHP_VERSION, default 8.3).
echo "date.timezone = ${TZ}" > "/etc/php/${PHP_VERSION:-8.3}/mods-available/timezone.ini"

# shellcheck source=/dev/null
source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND

# EOF
