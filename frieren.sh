apt-get update
apt-get install bind9 nginx mariadb-client -y

# test db access
# mariadb --host=192.215.3.2 --port=3306 --user=kelompoke18 --password

apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

apt-get update
apt-get install php8.0-mbstring php8.0-xml php8.0-cli php8.0-common php8.0-intl php8.0-opcache php8.0-readline php8.0-mysql php8.0-fpm php8.0-curl unzip wget -y
apt-get install git nginx -y

wget https://getcomposer.org/download/2.0.13/composer.phar
chmod +x composer.phar
mv composer.phar /usr/bin/composer

git clone https://github.com/martuafernando/laravel-praktikum-jarkom.git

# Rename .env.example to .env
cd laravel-praktikum-jarkom
mv .env.example .env

echo 'APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=192.215.3.2
DB_PORT=3306
DB_DATABASE=dbkelompoke18
DB_USERNAME=kelompoke18
DB_PASSWORD=passworde18

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="${PUSHER APP KEY}"
VITE_PUSHER_HOST="${PUSHER HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER APP CLUSTER}"' > .env

composer update
composer install

php artisan migrate:fresh
php artisan db:seed --class=AiringsTableSeeder
php artisan key:generate
php artisan jwt:secret

echo 'server {
    listen 80;
    server_name riegel.canyon.e18.com;
    root /laravel-praktikum-jarkom/public;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    error_log  /var/log/nginx/your_app_error.log;
    access_log /var/log/nginx/your_app_access.log;
}
' > /etc/nginx/sites-available/default

chown -R www-data.www-data /laravel-praktikum-jarkom/storage

service nginx restart
service php8.0-fpm start
service php8.0-fpm restart

# implement php fpm
echo '[frieren_site]
user = frieren_user
group = frieren_user
listen = /var/run/php/php8.0-fpm-frieren-site.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

; Choose how the process manager will control the number of child processes.

pm = dynamic
pm.max_children = 75
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.process_idle_timeout = 10s

;contoh diatas konfigurasi untuk mengatur jumalh proses PHP-FPM yang berjalan
' > /etc/php/8.0/fpm/pool.d/frieren.conf

groupadd frieren_user
useradd -g frieren_user frieren_user

service php8.0-fpm restart

echo 'server {
    listen 80;
    server_name riegel.canyon.e18.com;
    root /laravel-praktikum-jarkom/public;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.0-fpm-frieren-site.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    error_log  /var/log/nginx/your_app_error.log;
    access_log /var/log/nginx/your_app_access.log;
}
' > /etc/nginx/sites-available/default

service nginx restart

# try 2
echo '[frieren_site]
user = frieren_user
group = frieren_user
listen = /var/run/php/php8.0-fpm-frieren-site.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

; Choose how the process manager will control the number of child processes.

pm = dynamic
pm.max_children = 90
pm.start_servers = 25
pm.min_spare_servers = 20
pm.max_spare_servers = 35
pm.process_idle_timeout = 10s

;contoh diatas konfigurasi untuk mengatur jumalh proses PHP-FPM yang berjalan
' > /etc/php/8.0/fpm/pool.d/frieren.conf

service php8.0-fpm restart

# try 3
echo '[frieren_site]
user = frieren_user
group = frieren_user
listen = /var/run/php/php8.0-fpm-frieren-site.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

; Choose how the process manager will control the number of child processes.

pm = dynamic
pm.max_children = 105
pm.start_servers = 40
pm.min_spare_servers = 35
pm.max_spare_servers = 50
pm.process_idle_timeout = 10s

;contoh diatas konfigurasi untuk mengatur jumalh proses PHP-FPM yang berjalan
' > /etc/php/8.0/fpm/pool.d/frieren.conf

service php8.0-fpm restart