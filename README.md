# docker-observium-ce

Yet another containerised version of Observium Community Edition, though this one includes:
1. rsyslog to support device log collection via syslog
2. php-ldap for LDAP authentication support
3. A /status.php endpoint to ensure testing of both Apache availability and PHP functionality when conducting health monitoring
4. Timezone management for php
5. Database auto-creation including creation of a default set of alerting rules
6. logrotate based rotation of both Apache and Observium logs
7. Zero requirement to inject a config.php file, database configuration and base URL variables are all taken from environment variables and so can be controlled by the container definition.

You can still inject the config.php file, which may be necessary for more complex configurations, e.g. LDAP based authentication.

This image does not include a SQL server of any kind, you're expected to have one elsewhere or you should add another service definition to the compose file as appropriate.

HTTPS is not enabled by default, only HTTP.

Container images are published via [Docker Hub](https://hub.docker.com/r/colinstubbs/observium-ce)