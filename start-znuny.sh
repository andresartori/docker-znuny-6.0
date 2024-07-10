#!/bin/bash

# Set Permission on all files
/opt/znuny/bin/otrs.SetPermissions.pl
# Update Database
su -c "/opt/znuny/scripts/MigrateToZnuny6_1.pl" -s /bin/bash znuny
# Start cron
su -c "/opt/znuny/bin/Cron.sh start" -s /bin/bash znuny
service cron start
# Start Apache
apachectl -D FOREGROUND
