# Znuny docker image.
FROM ubuntu:20.04
LABEL maintainer="Andre Sartori <dev@aph.dev.br>"
# Variables
#ENV ZNUNY_Version=6.0.36
ARG ZNUNY_VERSION
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Update and install
RUN apt update && apt install -y apache2 libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl libnet-dns-perl \
    libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl \
    libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl libyaml-perl libarchive-zip-perl \
    libcrypt-eksblowfish-perl libencode-hanextra-perl libmail-imapclient-perl libtemplate-perl libdatetime-perl \
    libmoo-perl bash-completion libyaml-libyaml-perl libjavascript-minifier-xs-perl libcss-minifier-xs-perl \
    libauthen-sasl-perl libauthen-ntlm-perl wget && apt clean
# Download and install znuny
RUN cd /opt && wget https://download.znuny.org/releases/znuny-${ZNUNY_VERSION}.tar.gz && \
    tar xfz znuny-${ZNUNY_VERSION}.tar.gz && ln -s /opt/znuny-${ZNUNY_VERSION} /opt/otrs && \
    cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm
# Add user and set permission
RUN useradd -d /opt/otrs -c 'Znuny user' -g www-data -s /bin/bash -M -N otrs
RUN /opt/otrs/bin/otrs.SetPermissions.pl
# Config crontab
RUN su - otrs && cd /opt/otrs/var/cron && for foo in *.dist; do cp $foo `basename $foo .dist`; done
# Config Apache
RUN ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/znuny.conf && \
    a2enmod perl headers deflate filter cgi && a2dismod mpm_event && a2enmod mpm_prefork && a2enconf znuny
EXPOSE 80 443
CMD ["apache2ctl","-DFOREGROUND"]