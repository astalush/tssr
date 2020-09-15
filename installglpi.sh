#/!bin/bash
# Script installation automatique du GLPI sur un DEBIAN 10 Buster
# TSSR 2020 WIN_DOS.XIII // Yoyo
# Power to the people!!!
sleep 2
clear

# Color Reset
Color_Off='\033[0m'       # Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

#Les fonctions

#fonction pour double verification du MDP root MYSQL
password_check_mysql () {
checkmdp=$DATABASE_PASS
while true; do
    read -s -p "Entrez le nouveau MDP: " checkmdp
    echo
    read -s -p "Verifier le nouveau MDP: " checkmdp2
    echo
    [ "$checkmdp" = "$checkmdp2" ] && break
    echo "Les MDP ne sont pas identiques. Recommencez!"
done
DATABASE_PASS=$checkmdp
}

#fonction pour double verification mdp utilisateur glpi
userpassword_check_glpi () {
check=$userpass
while true; do
    read -s -p "Entrez le nouveau MDP: " check
    echo
    read -s -p "Verifier le nouveau MDP: " check2
    echo
    [ "$check" = "$check2" ] && break
    echo "Les MDP ne sont pas identiques. Recommencez!"
done
userpass=$check
}

###MISE A JOUR DES DEPOTS
#on va effacer l'ancien fichier sources.list
echo -e "$Red \nMISE A JOUR DES DEPOTS DEBIAN...$Color_Off"
rm /etc/apt/sources.list
sleep 3

#creation du nouveau fichier sources.list et ajout des lignes neccessaires des depots
echo "deb http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list
sleep 3
#faire une mise a jour avec apt update
sudo apt update

#faire la mise a jour des paquets qui ont une mise a jour sur les depots
sudo apt upgrade -y

#installation apache
echo -e "$Cyan \nInstallation apache2 $Color_Off"
sleep 3
sudo apt install apache2 apache2-doc apache2-utils libexpat1 ssl-cert -y

#installation PHP
echo -e "$Green \nInstallation PHP $Color_Off"
sleep 3
apt install curl net-tools php7.3 php7.3-curl php7.3-zip php7.3-gd php7.3-intl php-pear php-imagick php7.3-imap php-memcache php7.3-pspell php7.3-recode php7.3-tidy php7.3-xmlrpc php7.3-xsl php7.3-mbstring php-gettext php7.3-ldap php-cas php-apcu libapache2-mod-php7.3 php7.3-mysql libbz2-dev php7.3-bz2 -y

#restart apache2
echo -e "$Cyan \nRedemarrage apache2 $Color_Off"
sleep 3
sudo systemctl restart apache2 &> /dev/null

#installation mariaBD
echo -e "$Green \nInstallation MariaDB $Color_Off"
apt-get install mariadb-server mariadb-client -y
sleep 3

#parametrage du MDP root pour MYSQL
echo "---------------------------------------------------------------------------------------------------"
echo -e "$Red \n| MYSQL n'a pas de MDP defini. Merci d'entrer un MDP pour l'utilisateur root dans MYSQL |${Color_Off}"
echo "---------------------------------------------------------------------------------------------------"
echo ""
password_check_mysql
echo ""
mysqladmin -u root password $DATABASE_PASS

# mysql_secure_installation.sql
echo -e "$Red \nSécurisation du serveur MySQL ${Color_Off}"
sleep 3
mysql -uroot -p${DATABASE_PASS} -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -uroot -p${DATABASE_PASS} -e "DELETE FROM mysql.user WHERE User='';"
mysql -uroot -p${DATABASE_PASS} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
mysql -uroot -p${DATABASE_PASS} -e "FLUSH PRIVILEGES;"

#creation base de donnees GLPI
echo "---------------------------------------------------------------------------------------------------"
echo -n -e "$Red \nEntrez le nom de la base de donnees que vous voulez creer pour GLPI: ${Color_Off}";read dbname
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo -e "$Red \nCreation de la nouvelle base de donnees ${Color_Off}${dbname}$Red dans MySQL... ${Color_Off}"
mysql -uroot -p${DATABASE_PASS} -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
echo -e "$Red \nCreation OK!${Color_Off}"
echo -e "$Red \nListez les base de donnees existantes... ${Color_Off}"
mysql -uroot -p${DATABASE_PASS} -e "show databases;"
sleep 3
echo -n -e "$Red \nEntrez le nom de l'utilisateur/administrateur pour la nouvelle base de donnees ${Color_Off}${dbname}$Red : ${Color_Off}";read username
echo -e "$Red \nEntrez le mot de passe pour l'utilisateur/administrateur ${Color_Off}${username} $Red(Info : le MDP va etre caché quand vous le tapez): ${Color_Off}"
echo ""
userpassword_check_glpi
echo ""
echo -e "$Red \nCreation du nouvel l'utilisateur/administrateur ${Color_Off}${username} $Red dans MYSQL... ${Color_Off}"
mysql -uroot -p${DATABASE_PASS} -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
echo -e "$Red \nCreation OK! ${Color_Off}"
echo -e "$Red \nGranting ALL privileges on ${Color_Off}${dbname} to ${username}! "
mysql -uroot -p${DATABASE_PASS} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';"
mysql -uroot -p${DATABASE_PASS} -e "FLUSH PRIVILEGES;"

#telecharger la derniere version du glpi depuis github
echo -e "$Cyan \nTelechargement de la dernier version de GLPI... $Color_Off"
cd /tmp
wget https:$(wget https://github.com/glpi-project/glpi/releases/latest.tgz -O - | egrep '/.*/.*/.*tgz' -o)
#wget https://github.com/glpi-project/glpi/releases/download/9.4.1.1/glpi-9.4.1.1.tgz
sleep 3

#dezarchiver glpi
echo -e "$Cyan \nDesarchiver GLPI $Color_Off"
tar -xzvf glpi-*.tgz &> /dev/null
sleep 3

#deplacer glpi dans /var/www
echo -e "$Cyan \nDeplacer GLPI dans le dossier /var/www ...$Color_Off"
sleep 2
cp -r glpi /var/www
echo -e "$Cyan \nChangement des droits d'access sur le dossier /var/www/glpi pour www-data ...$Color_Off"
chown -R www-data /var/www/glpi
sleep 2

#parametrage glpi.conf
echo -e "$Cyan \nCreation et modification du fichier conf de glpi.conf pour apache2... ${Color_Off}"
if [ -e /etc/apache2/sites-available/000-default.conf ];
then rm /etc/apache2/sites-available/000-default.conf
fi
rm /etc/apache2/sites-enabled/000-default.conf &> /dev/null

echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/glpi.conf
echo "" >> /etc/apache2/sites-available/glpi.conf
echo "ServerAdmin admin@glpi" >> /etc/apache2/sites-available/glpi.conf
echo "DocumentRoot /var/www/glpi" >> /etc/apache2/sites-available/glpi.conf
echo "ServerName glpi" >> /etc/apache2/sites-available/glpi.conf
echo "" >> /etc/apache2/sites-available/glpi.conf
echo "<Directory /var/www/glpi>" >> /etc/apache2/sites-available/glpi.conf
echo "Options FollowSymlinks" >> /etc/apache2/sites-available/glpi.conf
echo "AllowOverride All" >> /etc/apache2/sites-available/glpi.conf
echo "Require all granted" >> /etc/apache2/sites-available/glpi.conf
echo "</Directory>" >> /etc/apache2/sites-available/glpi.conf
echo "" >> /etc/apache2/sites-available/glpi.conf
echo "ErrorLog ${APACHE_LOG_DIR}/error.log" >> /etc/apache2/sites-available/glpi.conf
echo "CustomLog ${APACHE_LOG_DIR}/access.log combined" >> /etc/apache2/sites-available/glpi.conf
echo "" >> /etc/apache2/sites-available/glpi.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/glpi.conf
sleep 3

#activation du hote GLPI dans apache2
echo -e "$Cyan \nActivation du hote glpi dans apache2... ${Color_Off}"
sudo ln -s /etc/apache2/sites-available/glpi.conf /etc/apache2/sites-enabled/glpi.conf
sleep 3
echo -e "$Cyan \nActivation des modules apache2... ${Color_Off}"
sudo a2enmod rewrite &> /dev/null
sleep 3
echo -e "$Cyan \nRedemarrage apache2... ${Color_Off}"
sudo systemctl restart apache2 &> /dev/null
sleep 3
chgrp www-data /var/www/glpi/{config,files,files/_{dumps,sessions,cron,graphs,lock,plugins,tmp,rss,uploads,pictures,log}}

#chercher l'addresse IP du serveur GLPI
IPAD=`ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p'`

#timestamps GLPI pour MySQL
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot -p${DATABASE_PASS} mysql &> /dev/null
mysql -uroot -p${DATABASE_PASS} -e "GRANT SELECT ON mysql.time_zone_name TO '${username}'@'localhost';"
php /var/www/glpi/bin/console glpi:migration:timestamps --no-interaction &> /dev/null

#restart MYSQL / MariaDB
echo -e "$Green \nRestart MYSQL / MariaDB et apache2...$Color_Off"
sudo systemctl restart apache2 &> /dev/null
/etc/init.d/mysql restart

#parametrage en CLI pour GLPI
php /var/www/glpi/bin/console db:install -r -f -Lfr_FR -Hlocalhost -P3306 -d$dbname -u$username -p$userpass --no-interaction
php /var/www/glpi/bin/console db:configure -r -Hlocalhost -P3306 -d$dbname -u$username -p$userpass --no-interaction
sleep 5
echo -e "$Cyan \nRedemarrage apache2... ${Color_Off}"

sudo chown -R www-data:www-data /var/www/glpi &> /dev/null
sudo systemctl restart apache2 &> /dev/null
sleep 5

#effacer install.php pour des raisons de securite
echo -e "$Cyan \nEffacer le fichier install du GLPI (/install/install.php) pour des raisons de securite...${Color_Off}"
rm -rf /var/www/glpi/install/install.php
echo ""

#affichage des infos pour le serveur GLPI
echo "---------------------------------------------------------------------------------------------------"
php /var/www/glpi/bin/console glpi:system:check_requirements
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo -e "$Red \nSUCCESS! Votre MDP root pour MySQL est:${Color_Off} ${DATABASE_PASS} "
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo -e "$Cyan \n Infos sur le nouveau GLPI: ${Color_Off}"
echo "---------------------------------------------------------------------------------------------------"
echo -e "$Cyan \n| Adresse IP du GLPI :${Color_Off} http://$IPAD/ |"
echo -e "$Cyan \n| Serveur SQL (Maria DB ou MYSQL) :${Color_Off} localhost ${Color_Off}|"
echo -e "$Cyan \n| Base de donnees MYSQL pour GLPI :${Color_Off} ${dbname} ${Color_Off}|"
echo -e "$Cyan \n| Utilisateur SQL:${Color_Off} ${username} |"
echo -e "$Cyan \n| Mot de passe SQL:${Color_Off} ${userpass} ${Color_Off}|"
echo "---------------------------------------------------------------------------------------------------"
echo ""
