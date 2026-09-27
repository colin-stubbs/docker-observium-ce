# Docker container for Observium Community Edition
#
# Pin the Ubuntu LTS that ships the PHP series we install. ubuntu:latest
# tracks the newest release (26.04 Resolute uses PHP 8.5 and has no php8.3-*).
FROM ubuntu:26.04

ARG PHP_VERSION=8.3

ENV PHP_VERSION=${PHP_VERSION} \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

LABEL maintainer="colin.stubbs@hq.cavalryscout.com" \
      version="1.9" \
      description="Docker container for Observium Community Edition"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# One COPY + one RUN: overlay files and the install stay in a single layer.
COPY . /tmp/image/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      php${PHP_VERSION}-cli php${PHP_VERSION}-mysql php${PHP_VERSION}-gd \
      php${PHP_VERSION}-bcmath php${PHP_VERSION}-mbstring php${PHP_VERSION}-opcache \
      php${PHP_VERSION}-curl php${PHP_VERSION}-ldap php${PHP_VERSION}-xml \
      php-apcu php-pear \
      libapache2-mod-php${PHP_VERSION} \
      apache2 \
      snmp fping mysql-client rrdtool subversion whois mtr-tiny ipmitool \
      libvirt-clients python3-mysqldb python3-pymysql python-is-python3 \
      graphviz imagemagick \
      cron curl locales supervisor wget logrotate libphp-phpmailer rsyslog \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/apache2/sites-available/* && \
    rm -f /etc/cron.d/* /etc/cron.hourly/* /etc/cron.daily/* \
          /etc/cron.weekly/* /etc/cron.monthly/* && \
    rm -f /etc/logrotate.d/* /etc/supervisord/conf.d/* && \
    rm -fr /var/log/* /var/www && \
    mkdir /var/log/apache2 && \
    locale-gen en_US.UTF-8 && \
    mkdir -p /opt/observium/logs /opt/observium/rrd && \
    wget -q -O /tmp/observium-community-latest.tar.gz \
      https://www.observium.org/observium-community-latest.tar.gz && \
    tar zxf /tmp/observium-community-latest.tar.gz -C /opt && \
    rm -f /tmp/observium-community-latest.tar.gz && \
    cp /opt/observium/config.php.default /opt/observium/config.php && \
    sed -i \
      -e "s/= 'localhost';/= getenv('OBSERVIUM_DB_HOST');/g" \
      -e "s/= 'USERNAME';/= getenv('OBSERVIUM_DB_USER');/g" \
      -e "s/= 'PASSWORD';/= getenv('OBSERVIUM_DB_PASS');/g" \
      -e "s/= 'observium';/= getenv('OBSERVIUM_DB_NAME');/g" \
      /opt/observium/config.php && \
    echo "\$config['base_url'] = getenv('OBSERVIUM_BASE_URL');" >> /opt/observium/config.php && \
    cp /tmp/image/observium-init.sh /opt/observium/observium-init.sh && \
    cp /tmp/image/apache-init.sh /opt/observium/apache-init.sh && \
    cp /tmp/image/status.php /opt/observium/html/status.php && \
    cp /tmp/image/alerting.sql /opt/observium/scripts/alerting.sql && \
    cp /tmp/image/apache24.conf /etc/apache2/sites-available/000-default.conf && \
    cp /tmp/image/logrotate.conf /etc/logrotate.conf && \
    cp /tmp/image/logrotate.cron /etc/cron.d/logrotate && \
    cp /tmp/image/observium.cron /etc/cron.d/observium && \
    cp /tmp/image/supervisord.conf /etc/supervisord.conf && \
    cp /tmp/image/rsyslog.conf /etc/rsyslog.conf && \
    rm -rf /tmp/image && \
    chmod a+x /opt/observium/observium-init.sh /opt/observium/apache-init.sh && \
    chmod 644 /etc/apache2/sites-available/000-default.conf \
              /etc/logrotate.conf /etc/cron.d/logrotate /etc/cron.d/observium && \
    chown -R www-data:www-data /opt/observium && \
    test -f /opt/observium/VERSION && cat /opt/observium/VERSION && \
    echo "date.timezone = UTC" > /etc/php/${PHP_VERSION}/mods-available/timezone.ini && \
    phpenmod timezone && \
    a2dismod mpm_event && \
    a2enmod mpm_prefork php${PHP_VERSION} rewrite

WORKDIR /opt/observium

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

EXPOSE 80/tcp 443/tcp 514/udp 514/tcp 6514/tcp

VOLUME ["/opt/observium/logs", "/opt/observium/rrd"]

HEALTHCHECK --interval=60s --timeout=10s --start-period=3s --retries=3 \
  CMD ["curl", "--silent", "--fail", "--output", "/dev/null", "http://localhost:80/status.php"]
