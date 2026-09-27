#!/bin/bash

set -e

# Match the PHP series installed in the image (PHP_VERSION, default 8.3).
echo "date.timezone = ${TZ}" > "/etc/php/${PHP_VERSION:-8.3}/mods-available/timezone.ini"

# envvars tests $APACHE_CONFDIR before it is set. nounset exits on that.
set +u
# shellcheck source=/dev/null
source /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND

# EOF
