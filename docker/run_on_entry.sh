#!/bin/bash

# Need to add trust anchor repo
touch /etc/yum.repos.d/EGI-trustanchors.repo
echo -e "# EGI Software Repository - REPO META (releaseId,repositoryId,repofileId) - (10824,-,2000)\n[EGI-trustanchors]\nname=EGI-trustanchors\nbaseurl=http://repository.egi.eu/sw/production/cas/1/current/\nenabled=1\ngpgcheck=1\ngpgkey=http://repository.egi.eu/sw/production/cas/1/GPG-KEY-EUGridPMA-RPM-3" >> /etc/yum.repos.d/EGI-trustanchors.repo

# install IGTF trust bundle
yum -y install ca-policy-egi-core

# make dir for ssl keys
mkdir -p /etc/httpd/ssl

# create self signed certificates
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/ssl/apache.key -out /etc/httpd/ssl/apache.crt -subj "/C=GB/ST=Example/L=Example/O=Example/OU=Example/CN=$HOST_NAME"

# Create an APEL user in mysql
#mysql -u root -h $MYSQL_PORT_3306_TCP_ADDR -p$MYSQL_ROOT_PASSWORD -e "CREATE USER 'apel'@'%' IDENTIFIED BY '$MYSQL_APEL_PASSWORD'"

# Grant the APEL user privileges
#mysql -u root -h $MYSQL_PORT_3306_TCP_ADDR -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON apel_rest.* TO 'apel'@'%' WITH GRANT OPTION"

# Flush the privileges
#mysql -u root -h $MYSQL_PORT_3306_TCP_ADDR -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES"

# configure mysql
echo "[client]
user=apel
password=PutYourPassWordAPEL
host=10.254.10.20" >> /etc/my.cnf

# add clouddb.cfg, so that the default user of mysql is APEL
echo "[db]
# type of database
backend = mysql
# host with database
hostname = 10.254.10.20
# port to connect to
port = 3306
# database name
name = apel_rest
# database user
username = apel
# password for database
password = 10.254.10.20
# how many records should be put/fetched to/from database
# in single query
records = 1000
# option for summariser so that SummariseVMs is called
type = cloud" >> /etc/apel/clouddb.cfg

# start apache
service httpd start

#start cron
service crond start

# start the loader service
service apeldbloader-cloud start

# Make cloud spool dir owned by apache
chown apache -R /var/spool/apel/cloud/

#keep docker running
while true
do
  sleep 1
done
