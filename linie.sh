apt-get update
apt-get install nginx php7.3 php7.3-fpm htop -y

## To setup web page
apt install python3 python3-pip -y
pip3 install gdown

gdown --id 1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1

apt-get install unzip -y
unzip granz.channel.yyy.com.zip
rm granz.channel.yyy.com.zip

apt-get install php7.3 php7.3-fpm -y

cp -r /modul-3/* /var/www/html

echo 'server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;  # Replace with the actual path to your web files

    index index.php index.html index.htm index.php;

    server_name _;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
' > /etc/nginx/sites-available/default

service nginx restart

service php7.3-fpm start
service php7.3-fpm restart
