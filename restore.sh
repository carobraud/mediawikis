NAME=$1
DATE=$2
SNAME=$3
HOME=/home/braud/WIKIs

# copy old database
tar -xvzf $HOME/Wiki$NAME.$DATE.tgz
sudo cp $HOME/Wiki$NAME.sql /opt/mediawiki/
sudo cp -rf $HOME/home/chroot/httpd/www/mediawiki/$NAME.data /opt/mediawiki/

# create new database
cd /opt/mediawiki
sudo tar -xvf mediawiki-1.20.3.tar
sudo mv mediawiki-1.20.3 $NAME.mediawiki-1.20.3
## restore LOGO (!!not always available!!)
sudo cp /home/braud/WIKIs/home/chroot/httpd/www/mediawiki/$NAME.mediawiki-1.9.3/logo_Wiki$NAME.png /opt/mediawiki/$NAME.mediawiki-1.20.3/
sudo chmod 777 /opt/mediawiki/$NAME.mediawiki-1.20.3/logo_Wiki$NAME.png
##
cd $HOME
sed  's/TMP/'$SNAME'/g' create_newdb.sql.tmp > create_newdb.sql
mysql -u root -pmysqlpass < create_newdb.sql
rm create_newdb.sql
## load old database
sudo mysql --default-character-set=latin1 \
      -h localhost -D wikidb_$SNAME \
      -u wikiuser_$SNAME -p$SNAME'4db' < Wiki$NAME.sql


# make alias
cd /var/www/html/
sudo mkdir $NAME.data
sudo mkdir $NAME
cd $HOME
sed  's/TMP/'$NAME'/g' alias.txt.tmp > alias.txt
sudo cp alias.txt  /etc/apache2/conf.d/
rm alias.txt
cd /etc/apache2/conf.d/
cat alias.txt >> mediawiki.conf


# Modify LocalSettings.php
cd $HOME
sed  's/TMP/'$NAME'/g' LocalSettings.php.tmp > LocalSettings.php.tmp2
sed  's/STEMP/'$SNAME'/g' LocalSettings.php.tmp2 > LocalSettings.php
sudo mv LocalSettings.php /opt/mediawiki/$NAME.mediawiki-1.20.3/
rm LocalSettings.php.tmp2

# Update mediawiki
cd /opt/mediawiki/$NAME.mediawiki-1.20.3/maintenance/
php update.php

# Restart apache2
sudo service apache2 restart

