#/!bin/bash
# Script installation automatique du GLPI sur un DEBIAN 10 Buster
# TSSR 2020 WIN_DOS.XIII // Yoyo
# Power to the people!!!
sleep 2
clear
echo "8888888                   888             888 888          888    d8b                         .d8888b.  888      8888888b. 8888888 ";
echo "  888                     888             888 888          888    Y8P                        d88P  Y88b 888      888   Y88b  888   ";
echo "  888                     888             888 888          888                               888    888 888      888    888  888   ";
echo "  888   88888b.  .d8888b  888888  8888b.  888 888  8888b.  888888 888  .d88b.  88888b.       888        888      888   d88P  888   ";
echo "  888   888 \"88b 88K      888        \"88b 888 888     \"88b 888    888 d88\"\"88b 888 \"88b      888  88888 888      8888888P\"   888   ";
echo "  888   888  888 \"Y8888b. 888    .d888888 888 888 .d888888 888    888 888  888 888  888      888    888 888      888         888   ";
echo "  888   888  888      X88 Y88b.  888  888 888 888 888  888 Y88b.  888 Y88..88P 888  888      Y88b  d88P 888      888         888   ";
echo "8888888 888  888  88888P'  \"Y888 \"Y888888 888 888 \"Y888888  \"Y888 888  \"Y88P\"  888  888       \"Y8888P88 88888888 888       8888888 ";
echo "                                                                                                                                   ";
echo "                                                                                                                                   ";
echo "                                                                                                                                   ";

sleep 5
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

#fonction pour afficher la fin du script
tssr2020 () {
echo "88888888888 .d8888b.   .d8888b.  8888888b.        .d8888b.   .d8888b.   .d8888b.   .d8888b.  ";
echo "    888    d88P  Y88b d88P  Y88b 888   Y88b      d88P  Y88b d88P  Y88b d88P  Y88b d88P  Y88b ";
echo "    888    Y88b.      Y88b.      888    888             888 888    888        888 888    888 ";
echo "    888     \"Y888b.    \"Y888b.   888   d88P           .d88P 888    888      .d88P 888    888 ";
echo "    888        \"Y88b.     \"Y88b. 8888888P\"        .od888P\"  888    888  .od888P\"  888    888 ";
echo "    888          \"888       \"888 888 T88b        d88P\"      888    888 d88P\"      888    888 ";
echo "    888    Y88b  d88P Y88b  d88P 888  T88b       888\"       Y88b  d88P 888\"       Y88b  d88P ";
echo "    888     \"Y8888P\"   \"Y8888P\"  888   T88b      888888888   \"Y8888P\"  888888888   \"Y8888P\"  ";
echo "                                                                                             ";
echo "                                                                                             ";
echo "                                                                                             ";
}

#fonction pour double verification du MDP root MYSQL
password_check () {
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
userpassword_check () {
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

#fonction pour continuer apres qu'une touche soit pressée et pour effacer le fichier install.php de GLPI
presskey_check () {
echo ""
while [ true ] ; do
read -t 1200 -n 1
if [ $? = 0 ] ; then
rm /var/www/glpi/install/install.php && sleep 1 && tssr2020
exit;
fi
done
}


###MISE A JOUR DES DEPOTS
#on va effacer l'ancien fichier sources.list
echo -e "$Red \n MISE A JOUR DES DEPOTS DEBIAN $Color_Off"
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
echo "Mise a jour suite a la commande apt update"
sleep 3
#faire une mise a jour avec apt update
sudo apt update

#faire la mise a jour des paquets qui ont une mise a jour sur les depots
sudo apt upgrade -y

#installation apache
echo -e "$Cyan \n Installation de apache2 $Color_Off"
sleep 3
sudo apt install apache2 apache2-doc apache2-utils libexpat1 ssl-cert -y

#installation PHP
echo -e "$Yellow \n Installation de PHP $Color_Off"
sleep 3
apt install curl net-tools php7.3 php7.3-curl php7.3-zip php7.3-gd php7.3-intl php-pear php-imagick php7.3-imap php-memcache php7.3-pspell php7.3-recode php7.3-tidy php7.3-xmlrpc php7.3-xsl php7.3-mbstring php-gettext php7.3-ldap php-cas php-apcu libapache2-mod-php7.3 php7.3-mysql libbz2-dev php7.3-bz2 -y

#restart apache2
echo -e "$Red \n Redemarrage apache2 $Color_Off"
sleep 3
sudo systemctl restart apache2 &> /dev/null

#installation mariaBD
echo -e "$Green \n Installation de MariaDB $Color_Off"
apt-get install mariadb-server mariadb-client -y
sleep 3

#parametrage du MDP root pour MYSQL
echo "---------------------------------------------------------------------------------------------------"
echo -e "$Cyan \n| MYSQL n'a pas de MDP defini. Merci d'entrer un MDP pour l'utilisateur root dans MYSQL |${Color_Off}"
echo "---------------------------------------------------------------------------------------------------"
echo ""
password_check
echo ""
mysqladmin -u root password $DATABASE_PASS

# mysql_secure_installation.sql
echo -e "$Red \n Sécurisation du serveur MySQL ${Color_Off}"
sleep 3
mysql -uroot -p${DATABASE_PASS} -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -uroot -p${DATABASE_PASS} -e "DELETE FROM mysql.user WHERE User='';"
mysql -uroot -p${DATABASE_PASS} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
mysql -uroot -p${DATABASE_PASS} -e "FLUSH PRIVILEGES;"

#creation base de donnees GLPI
echo "---------------------------------------------------------------------------------------------------"
echo -n -e "$Red \n Entrez le nom de la base de donnees que vous voulez creer pour GLPI: ${Color_Off}";read dbname
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo -e "$Red \n Creation de la nouvelle base de donnees ${dbname} dans MySQL... ${Color_Off}"
mysql -uroot -p${DATABASE_PASS} -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
echo -e "$Red \n Creation OK!${Color_Off}"
echo ""
echo -e "$Red \n Listez les base de donnees existantes... ${Color_Off}"
mysql -uroot -p${DATABASE_PASS} -e "show databases;"
echo ""
sleep 2
echo -n -e "$Red \n Entrez le nom de l'utilisateur/administrateur pour la nouvelle base de donnees ${dbname}: ${Color_Off}";read username
echo -e "$Red \n Entrez le mot de passe pour l'utilisateur/administrateur ${username} (Info : le MDP va etre caché quand vous le tapez): ${Color_Off}"
echo ""
userpassword_check
echo ""
echo ""
echo -e "$Red \n Creation du nouvel l'utilisateur/administrateur ${username} dans MYSQL... ${Color_Off}"
mysql -uroot -p${DATABASE_PASS} -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
echo -e "$Red \n Creation OK! ${Color_Off}"
echo ""
echo -e "$Red \n Granting ALL privileges on ${dbname} to ${username}! ${Color_Off}"
mysql -uroot -p${DATABASE_PASS} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';"
mysql -uroot -p${DATABASE_PASS} -e "FLUSH PRIVILEGES;"

#telecharger la derniere version du glpi depuis github
echo -e "$Cyan \n Telechargement de la dernier version de GLPI $Color_Off"
cd /tmp
wget https:$(wget https://github.com/glpi-project/glpi/releases/latest.tgz -O - | egrep '/.*/.*/.*tgz' -o)
sleep 3

#dezarchiver glpi
echo -e "$Cyan \n Desarchiver GLPI $Color_Off"
tar -xzvf glpi-*.tgz &> /dev/null
sleep 3

#deplacer glpi dans /var/www
echo -e "$Green \n Deplacer GLPI dans le dossier /var/www $Color_Off"
cp -r glpi /var/www
echo -e "$Green \n Changement des droits d'access sur le dossier /var/www/glpi pour www-data $Color_Off"
chown -R www-data /var/www/glpi

#parametrage glpi.conf
echo -e "$Red \n Creation et modification du fichier conf de glpi.conf pour apache2.. ${Color_Off}"
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
echo -e "$Cyan \n Activation du hote glpi dans apache2.. ${Color_Off}"
sudo ln -s /etc/apache2/sites-available/glpi.conf /etc/apache2/sites-enabled/glpi.conf
sleep 3
echo -e "$Cyan \n Activation des modules apache2... ${Color_Off}"
sudo a2enmod rewrite &> /dev/null
sleep 3
echo -e "$Cyan \n Redemarrage apache2... ${Color_Off}"
sudo systemctl restart apache2 &> /dev/null
sleep 3
chgrp www-data /var/www/glpi/{config,files,files/_{dumps,sessions,cron,graphs,lock,plugins,tmp,rss,uploads,pictures,log}}
echo "---------------------------------------------------------------------------------------------------"
echo -e "$Green \n SUCCESS! Votre MDP root pour MySQL password est: ${DATABASE_PASS} ${Color_Off}"

#chercher l'addresse IP du serveur GLPI
IPAD=`ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p'`

#affichage des infos pour le serveur GLPI
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo -e "$Red \n L'adresse IP du GLPI: http://$IPAD/ ${Color_Off}"
echo "---------------------------------------------------------------------------------------------------"
echo -e "$Red \n Pour vous connecter pour la premiere fois sur la base de donnees GLPI merci d'utiliser: ${Color_Off}"
echo "---------------------------------------------------------------------------------------------------"
echo -e "$Yellow \n| Adresse IP du GLPI : http://$IPAD/ ${Color_Off}|"
echo -e "$Yellow \n| Serveur SQL (Maria DB ou MYSQL) : localhost ${Color_Off}|"
echo -e "$Yellow \n| Utilisateur SQL: ${username} ${Color_Off}|"
echo -e "$Yellow \n| Mot de passe SQL: ${userpass} ${Color_Off}|"
echo "---------------------------------------------------------------------------------------------------"
echo ""
echo -e "$Red \n Merci d'attendre 15 seconds SVP... ${Color_Off}"

sleep 15
#affichage des infos supplementaires et appelle de la fonction presskey
echo -e "$Red \n Pour des raisons de securité le fichier install.php de GLPI sera effacé a la fin de ce script. ${Color_Off}"
echo -e "$Red \n Merci de bien parametrer GLPI jusqu'a la FIN avant de valider en appuyant sur n'importe quelle touche .. ${Color_Off}"
presskey_check
