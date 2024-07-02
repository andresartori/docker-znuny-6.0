#!/bin/bash

# Set Permission on all files
/opt/otrs/bin/otrs.SetPermissions.pl
# Update Database
if [ $ZNUNY_UPDATE == 'yes' ]; then
        echo "Opção Update selecionada"
	su -c "/opt/otrs/scripts/DBUpdate-to-6.pl" -s /bin/bash otrs
elif [ $ZNUNY_UPGRADE == 'yes' ]; then
        echo "Opção Upgrade selecionada"
else
	echo "Nenhuma opção selecionada"
fi
# Start cron
su -c "/opt/otrs/bin/Cron.sh start" -s /bin/bash otrs
service cron start
# Start Apache
apachectl -D FOREGROUND
