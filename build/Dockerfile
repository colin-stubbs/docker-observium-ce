# Docker container for Observium Community Edition

FROM ubuntu:latest

LABEL maintainer "colin.stubbs@hq.cavalryscout.com"
LABEL version="1.6"
LABEL description="Docker container for Observium Community Edition"

# set environment variables
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV OBSERVIUM_ADMIN_USER=$OBSERVIUM_ADMIN_USER
ENV OBSERVIUM_ADMIN_PASS=$OBSERVIUM_ADMIN_PASS
ENV OBSERVIUM_DB_HOST=$OBSERVIUM_DB_HOST
ENV OBSERVIUM_DB_USER=$OBSERVIUM_DB_USER
ENV OBSERVIUM_DB_PASS=$OBSERVIUM_DB_PASS
ENV OBSERVIUM_DB_NAME=$OBSERVIUM_DB_NAME
ENV OBSERVIUM_BASE_URL=$OBSERVIUM_BASE_URL

# install prerequisites and cleanup
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && \
    apt-get install -y php8.3-cli php8.3-mysql php8.3-gd php8.3-bcmath php8.3-mbstring php8.3-opcache \
    php8.3-curl php-apcu php-pear php8.3-ldap snmp fping mysql-client rrdtool subversion whois mtr-tiny ipmitool \
    libvirt-clients python3-mysqldb python3-pymysql python-is-python3 libapache2-mod-php8.3 graphviz \
    imagemagick apache2 && \
    apt-get install -y libvirt-clients && \
    apt-get install -y cron curl locales supervisor wget && \
    apt-get install -y logrotate && \
    apt-get install -y libphp-phpmailer && \
    apt-get install -y rsyslog && \
    apt-get clean all && \
    rm -f /etc/apache2/sites-available/* && \
    rm -f /etc/cron.d/* && \
    rm -f /etc/cron.hourly/* && \
    rm -f /etc/cron.daily/* && \
    rm -f /etc/cron.weekly/* && \
    rm -f /etc/cron.monthly/* && \
    rm -f /etc/logrotate.d/* && \
    rm -f /etc/supervisord/conf.d/* && \
    rm -fr /var/log/* && \
    rm -fr /var/www && \
    mkdir /var/log/apache2 && \
    locale-gen en_US.UTF-8 && \
    mkdir -p /opt/observium /opt/observium/logs /opt/observium/rrd && \
    cd /opt && \
    wget http://www.observium.org/observium-community-latest.tar.gz && \
    tar zxvf observium-community-latest.tar.gz && \
    rm -f observium-community-latest.tar.gz && \
    cd /opt/observium && \
    cp config.php.default config.php && \
    sed -i -e "s/= 'localhost';/= getenv('OBSERVIUM_DB_HOST');/g" config.php && \
    sed -i -e "s/= 'USERNAME';/= getenv('OBSERVIUM_DB_USER');/g" config.php && \
    sed -i -e "s/= 'PASSWORD';/= getenv('OBSERVIUM_DB_PASS');/g" config.php && \
    sed -i -e "s/= 'observium';/= getenv('OBSERVIUM_DB_NAME');/g" config.php && \
    echo "\$config['base_url'] = getenv('OBSERVIUM_BASE_URL');" >> config.php

COPY observium-init.sh /opt/observium/observium-init.sh
COPY apache-init.sh /opt/observium/apache-init.sh
COPY status.php /opt/observium/html/status.php
COPY alerting.sql /opt/observium/scripts/alerting.sql
COPY apache24.conf /etc/apache2/sites-available/000-default.conf
COPY logrotate.conf /etc/logrotate.conf
COPY logrotate.cron /etc/cron.d/logrotate
COPY observium.cron /etc/cron.d/observium
COPY supervisord.conf /etc/supervisord.conf
COPY rsyslog.conf /etc/rsyslog.conf

RUN chmod a+x /opt/observium/observium-init.sh /opt/observium/apache-init.sh && \
    chown -R www-data:www-data /opt/observium && \
    [ -f /opt/observium/VERSION ] && \
    cat /opt/observium/VERSION && \
    echo "date.timezone = UTC" > /etc/php/8.3/mods-available/timezone.ini && \
    phpenmod timezone && \
    phpenmod mcrypt && \
    a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php8.3 && \
    a2enmod rewrite && \
    chmod 644 /etc/apache2/sites-available/000-default.conf && \
    chmod 644 /etc/logrotate.conf /etc/cron.d/logrotate /etc/cron.d/observium

# configure working directory
WORKDIR /opt/observium

# configure entry point
ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

# expose tcp port
EXPOSE 80/tcp
EXPOSE 443/tcp
EXPOSE 514/udp
EXPOSE 514/tcp
EXPOSE 6514/tcp

# set volumes
VOLUME ["/opt/observium/logs","/opt/observium/rrd"]