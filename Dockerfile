FROM ubuntu:22.04
LABEL maintainer="Andre Sartori <andre@aph.dev.br>"
ARG VERSION
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Update and install
RUN apt update && apt install -y apache2 libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl libnet-dns-perl \
    libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl \
    libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl libyaml-perl libarchive-zip-perl \
    libcrypt-eksblowfish-perl libencode-hanextra-perl libmail-imapclient-perl libtemplate-perl libdatetime-perl \
    libmoo-perl bash-completion libyaml-libyaml-perl libjavascript-minifier-xs-perl libcss-minifier-xs-perl \
    libauthen-sasl-perl libauthen-ntlm-perl wget cron && apt clean
# Download and install znuny
RUN cd /opt && wget https://download.znuny.org/releases/znuny-${VERSION}.tar.gz && \
    tar xfz znuny-${VERSION}.tar.gz && ln -s /opt/znuny-${VERSION} /opt/znuny && \
    cp /opt/znuny/Kernel/Config.pm.dist /opt/znuny/Kernel/Config.pm && \
    useradd -d /opt/znuny -c 'Znuny user' -g www-data -s /bin/bash -M -N znuny && /opt/znuny/bin/znuny.SetPermissions.pl
# Config crontab
RUN su - znuny && cd /opt/znuny/var/cron && for foo in *.dist; do cp $foo `basename $foo .dist`; done
# Config Apache
RUN ln -s /opt/znuny/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/znuny.conf && \
    a2enmod perl headers deflate filter cgi && a2dismod mpm_event && a2enmod mpm_prefork && a2enconf znuny && \
    echo 'ServerName znuny' >> /etc/apache2/apache2.conf
# Config znuny
RUN sed -i 's/\$HOME/\/opt\/znuny/g' /opt/znuny/var/cron/znuny_daemon && ln -sf /dev/stdout /var/log/cron && ln -sf /dev/stdout /var/log/apache2/access.log && ln -sf /dev/stderr /var/log/apache2/error.log
ADD start-znuny.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start-znuny.sh && update-rc.d cron defaults
EXPOSE 80 443
CMD ["start-znuny.sh"]
