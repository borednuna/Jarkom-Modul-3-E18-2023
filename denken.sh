apt-get update
apt-get install mariadb-server -y
service mysql start

# will evoke prompt for password for root, here I set it to ajke18
mysql -u root -p -e "CREATE USER 'kelompoke18'@'%' IDENTIFIED BY 'passworde18'; \
CREATE USER 'kelompoke18'@'localhost' IDENTIFIED BY 'passworde18'; \
CREATE DATABASE dbkelompoke18; \
GRANT ALL PRIVILEGES ON dbkelompoke18.* TO 'kelompoke18'@'%'; \
GRANT ALL PRIVILEGES ON dbkelompoke18.* TO 'kelompoke18'@'localhost'; \
FLUSH PRIVILEGES;"

echo '[mysqld]
skip-networking=0
skip-bind-address' >> /etc/mysql/my.cnf

# will evoke prompt for password for root, here I set it to ajke18
mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'kelompoke18'@'192.215.1.4' IDENTIFIED BY 'passworde18' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'kelompoke18'@'192.215.1.5' IDENTIFIED BY 'passworde18' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'kelompoke18'@'192.215.1.6' IDENTIFIED BY 'passworde18' WITH GRANT OPTION; FLUSH PRIVILEGES;"

service mysql restart