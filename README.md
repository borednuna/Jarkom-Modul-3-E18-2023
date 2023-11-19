# Jarkom-Modul-3-E18-2023

Anggota Kelompok ''E18'' 
| Nama                      | NRP        |
|---------------------------|------------|
| Hanun Shaka Puspa         | 5025211051 |
| Cholid Junoto             | 5025201038 |

## Soal 1
## Soal 2
## Soal 3
## Soal 4
## Soal 5
## Soal 6
Pada Eisen sebagai load balancer, dipanggil command berikut untuk menginstall packages yang diperlukan
```
apt-get update
apt-get install nginx bind9 php7.3 php7.3-fpm apache2-utils -y
```
Lalu dilakukan setup untuk server yang memiliki subdomain Lawine, Linie, dan Lugner
```
echo 'zone "granz.channel.e18.com" {
        type master;
        file "/etc/bind/jarkom/granz.channel.e18.com";
};

zone "3.215.192.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/3.215.192.in-addr.arpa";
};' > /etc/bind/named.conf.local

mkdir /etc/bind/jarkom

echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     granz.channel.e18.com. root.granz.channel.e18.com. (
			    2023110101    ; Serial
                        604800        ; Refresh
                        86400         ; Retry
                        2419200       ; Expire
                        604800 )      ; Negative Cache TTL
;
@               IN      NS      granz.channel.e18.com.
@               IN      A       192.215.3.3 ; IP Eisen
www             IN      CNAME   granz.channel.e18.com.
lawine      IN      A       192.215.4.4 ; IP Lawine
linie          IN      A       192.215.4.3 ; IP Linie
lugner         IN      A       192.215.4.2 ; IP Lugner
' > /etc/bind/jarkom/granz.channel.e18.com

echo '
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     granz.channel.e18.com. granz.channel.e18.com. (
                        2023110101    ; Serial
                        604800        ; Refresh
                        86400         ; Retry
                        2419200       ; Expire
                        604800 )      ; Negative Cache TTL
;
3.215.192.in-addr.arpa.         IN      NS      granz.channel.e18.com.
3                               IN      PTR     granz.channel.e18.com.
' > /etc/bind/jarkom/3.215.192.in-addr.arpa

service bind9 restart
```
Kemudian pada masing-masing worker Lawine, Linie, dan Lugner, serta Load Balancer Eisen dilakukan hal-hal berikut.
Pertama, persiapkan packages yang dibutuhkan.
```
apt-get update
apt-get install nginx php7.3 php7.3-fpm htop -y
```
Diinstall juga pip gdown untuk mendownload file website, lalu unzip file website-nya dan dipindahkan ke `/var/www/html`
```
apt install python3 python3-pip -y
pip3 install gdown

gdown --id 1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1

apt-get install unzip -y
unzip granz.channel.yyy.com.zip
rm granz.channel.yyy.com.zip

cp -r /modul-3/* /var/www/html
```
Lalu dilakukan setup untuk server nginx. Disini website yang telah didownload dianggap sebagai default website nginx.
```
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
        fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
' > /etc/nginx/sites-available/default
```
Lalu restart service nginx dan php.
```
service nginx restart
service php7.3-fpm start -v
service php7.3-fpm restart -v
```

## Soal 7
Karena telah diberikan spesifikasi hardware untuk tiap server worker, maka load balancing dapat dilakukan dengan weighted round robin. Pada LB Eisen, dispesifikasikan IP tiap workernya dan juga weight untuk tiap workernya. Karena Lawine memiliki spesifikasi paling tinggi, maka diberikan weight paling berat. Sebaliknya Lugner diberikan weight paling ringan karena memiliki spesifikasi paling rendah.
```
echo '#Default menggunakan Round Robin
upstream backend  {
    server 192.215.4.4 weight=4; #IP Lawine
    server 192.215.4.3 weight=2; #IP Linie
    server 192.215.4.2 weight=1; #IP Lugner
}

server {
    listen 80;
    server_name granz.channel.e18.com;

            location / {
                    proxy_pass http://backend;
                    proxy_set_header    X-Real-IP $remote_addr;
                    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header    Host $http_host;
            }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;

}
' > /etc/nginx/sites-available/default

service nginx restart
```
## Soal 8
Untuk setiap kali percobaan algoritma load balancing, dilakukan setup berikut pada LB Eisen, menggunakan unweughted round robin konfigurasinya adalah sebagai berikut.
```
echo '#Default menggunakan Round Robin
upstream backend  {
    server 192.215.4.4; #IP Lawine
    server 192.215.4.3; #IP Linie
    server 192.215.4.2; #IP Lugner
}

server {
    listen 80;
    server_name granz.channel.e18.com;

            location / {
                    proxy_pass http://backend;
                    proxy_set_header    X-Real-IP $remote_addr;
                    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header    Host $http_host;
            }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;

}
' > /etc/nginx/sites-available/default

service nginx restart
```
Kemudian, pada client Sein atau Stark, dipanggil command berikut.
```
echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt-get update
apt-get install dnsutils lynx apache2-utils vsftpd -y

echo 'nameserver 192.215.3.3
nameserver 8.8.8.8' > /etc/resolv.conf
```
Nameserver setelah menginstall packages dialihkan ke IP Eisen supaya dapat mengakses load balancer. Kemudian untuk melakukan benchmarking 100 request dengan 10 request/second, dipanggil command berikut.
```
ab -n 200 -c 10 -g eisen.data http://granz.channel.e18.com/
```
Dicatat request per seconds nya, kemudian disesuaikan lagi algoritma load balancing pada Eisen dengan menyesuaikan konfigurasi nginx nya dan dicatat hasil benchmarkingnya. Untuk weighted round robin menjadi seperti berikut.
```
...
upstream backend  {
    server 192.215.4.4 weight=4; #IP Lawine
    server 192.215.4.3 weight=2; #IP Linie
    server 192.215.4.2 weight=1; #IP Lugner
}
...
```
Menggunakan least connection menjadi seperti berikut.
```
...
upstream backend  {
    least_conn;
    server 192.215.4.4; #IP Lawine
    server 192.215.4.3; #IP Linie
    server 192.215.4.2; #IP Lugner
}
...
```
Kemudian menggunakan IP Hash,
```
...
upstream backend  {
    ip_hash;
    server 192.215.4.4; #IP Lawine
    server 192.215.4.3; #IP Linie
    server 192.215.4.2; #IP Lugner
}
...
```
Dan menggunakan generic hash.
```
...
upstream backend  {
    hash $request_uri consistent;
    server 192.215.4.4; #IP Lawine
    server 192.215.4.3; #IP Linie
    server 192.215.4.2; #IP Lugner
}
...
```
## Soal 9
Pada LB Eisen, disesuaikan konfigurasi nginx-nya.
```
echo '#Default menggunakan Round Robin
upstream backend  {
    server 192.215.4.4; #IP Lawine
    server 192.215.4.3; #IP Linie
    server 192.215.4.2; #IP Lugner
}

server {
    listen 80;
    server_name granz.channel.e18.com;

            location / {
                    proxy_pass http://backend;
                    proxy_set_header    X-Real-IP $remote_addr;
                    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header    Host $http_host;
            }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;

}
' > /etc/nginx/sites-available/default

service nginx restart
```
Tanpa mematikan service nginx di tiga worker, pada client, dipanggil command :
```
ab -n 100 -c 10 -g eisen.data http://granz.channel.e18.com/
```
Dicatat hasilnya, kemudian untuk menguji dengan dua worker, matikan service nginx pada salah satu worker dengan command berikut :
```
service nginx stop
```
Lalu dilakukan benchmarking lagi pada client :
```
ab -n 100 -c 10 -g eisen.data http://granz.channel.e18.com/
```
Lalu dimatikan satu lagi worker dan dilakukan benchmarking lagi di client dan dicatat hasil benchmarkingnya.
## Soal 10
Pada Eisen, dibuat direktori rahasisakita
```
mkdir /etc/nginx/rahasisakita/
```
Kemudian, buat password untuk user baru :
```
htpasswd -c /etc/nginx/rahasisakita/.htpasswd netics
```
Command tersebut akan memicu prompt, dimana kita akan memasukkan password untuk netics yaitu "ajke18". Konfigurasikan server nginx-nya.
```
echo '#Default menggunakan Round Robin
upstream backend  {
    server 192.215.4.4; #IP Lawine
    server 192.215.4.3; #IP Linie
    server 192.215.4.2; #IP Lugner
}

server {
    listen 80;
    server_name granz.channel.e18.com;

            location / {
                    proxy_pass http://backend;
                    proxy_set_header    X-Real-IP $remote_addr;
                    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header    Host $http_host;

                    auth_basic "Administrator'\''s Area";
                    auth_basic_user_file /etc/nginx/rahasisakita/.htpasswd;
            }

             location ~ /\.ht {
                deny all;
            }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;

}
' > /etc/nginx/sites-available/default

service nginx restart
```
Untuk testing, dipanggil command berikut pada client
```
ab -A netics:ajke18 -n 100 -c 100 http://granz.channel.e18.com/
```
## Soal 11
Pada LB Eisen, dikonfigurasikan lagi nginx-nya.
```
echo '#Default menggunakan Round Robin
upstream backend  {
    server 192.215.4.4; #IP Lawine
    server 192.215.4.3; #IP Linie
    server 192.215.4.2; #IP Lugner
}

server {
    listen 80;
    server_name granz.channel.e18.com;

            location / {
                    proxy_pass http://backend;
                    proxy_set_header    X-Real-IP $remote_addr;
                    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header    Host $http_host;

                    auth_basic "Administrator'\''s Area";
                    auth_basic_user_file /etc/nginx/rahasisakita/.htpasswd;
            }

            location ~ /\.ht {
                deny all;
            }

            location /its {
                    proxy_pass https://www.its.ac.id;
                    proxy_set_header X-Forwarded-Proto $scheme;
            }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;

}
' > /etc/nginx/sites-available/default

service nginx restart
```
Pada konfigurasi di atas, dispesifikasikan proxy pass untuk menuju website ITS, yaitu pada bagian :
```
location /its {
        proxy_pass https://www.its.ac.id;
        proxy_set_header X-Forwarded-Proto $scheme;
}
```
## Soal 12
Dikonfigurasikan LB Eisen sebagai berikut :
```
echo '#Default menggunakan Round Robin
upstream backend  {
    server 192.215.4.4; #IP Lawine
    server 192.215.4.3; #IP Linie
    server 192.215.4.2; #IP Lugner
}

server {
    listen 80;
    server_name granz.channel.e18.com;

    allow 192.215.3.69;
    allow 192.215.3.70;
    allow 192.215.4.167;
    allow 192.215.4.168;
    deny all;

            location / {
                    proxy_pass http://backend;
                    proxy_set_header    X-Real-IP $remote_addr;
                    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header    Host $http_host;

                    auth_basic "Administrator'\''s Area";
                    auth_basic_user_file /etc/nginx/rahasisakita/.htpasswd;
            }

            location ~ /\.ht {
                deny all;
            }

            location /its {
                    proxy_pass https://www.its.ac.id;
                    proxy_set_header X-Forwarded-Proto $scheme;
            }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;

}
' > /etc/nginx/sites-available/default

service nginx restart
```
Pada konfigurasi di atas, hanya memperbolehkan akses dari IP tertentu, yaitu di bagian :
```
allow 192.215.3.69;
allow 192.215.3.70;
allow 192.215.4.167;
allow 192.215.4.168;
deny all;
```
## Soal 13
Pada Denken, dipersiapkan packages yang diperlukan
```
apt-get update
apt-get install mariadb-server -y
service mysql start
```
Dibuat user yang nantinya dapat diakses dari server worker.
```
mysql -u root -p -e "CREATE USER 'kelompoke18'@'%' IDENTIFIED BY 'passworde18'; \
CREATE USER 'kelompoke18'@'localhost' IDENTIFIED BY 'passworde18'; \
CREATE DATABASE dbkelompoke18; \
GRANT ALL PRIVILEGES ON dbkelompoke18.* TO 'kelompoke18'@'%'; \
GRANT ALL PRIVILEGES ON dbkelompoke18.* TO 'kelompoke18'@'localhost'; \
FLUSH PRIVILEGES;"
```
Lalu, dikonfigurasi supaya dapat diakses dari server luar.
```
echo '[mysqld]
skip-networking=0
skip-bind-address' >> /etc/mysql/my.cnf
```
Diberikan akses penuh ke database dari IP Flamme, Fern, dan Frieren.
```
mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'kelompoke18'@'192.215.1.4' IDENTIFIED BY 'passworde18' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'kelompoke18'@'192.215.1.5' IDENTIFIED BY 'passworde18' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'kelompoke18'@'192.215.1.6' IDENTIFIED BY 'passworde18' WITH GRANT OPTION; FLUSH PRIVILEGES;"
```
Lalu pada client server, setup untuk client database nya
```
apt-get update
apt-get install bind9 nginx mariadb-client -y

apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
```

## Soal 14
Setup zona baru riegel canyon pada LB Eisen
```
echo 'zone "granz.channel.e18.com" {
        type master;
        file "/etc/bind/jarkom/granz.channel.e18.com";
};

zone "3.215.192.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/3.215.192.in-addr.arpa";
};

zone "riegel.canyon.e18.com" {
        type master;
        file "/etc/bind/jarkom/riegel.canyon.e18.com";
};
' > /etc/bind/named.conf.local

echo ';
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     riegel.canyon.e18.com. root.riegel.canyon.e18.com. (
                        2023110101    ; Serial
                        604800        ; Refresh
                        86400         ; Retry
                        2419200       ; Expire
                        604800 )      ; Negative Cache TTL
;
@               IN      NS      riegel.canyon.e18.com.
@               IN      A       192.215.3.3 ; IP Eisen
www             IN      CNAME   riegel.canyon.e18.com.
frieren         IN      A       192.215.1.4 ; IP Frieren
flamme          IN      A       192.215.1.5 ; IP Flamme
fern            IN      A       192.215.1.6 ; IP Fern
' > /etc/bind/jarkom/riegel.canyon.e18.com

service bind9 restart

echo '#Default menggunakan Round Robin
upstream backend_riegel {
    server 192.215.1.4; #IP Frieren
    server 192.215.1.5; #IP Flamme
    server 192.215.1.6; #IP Fern
}

server {
    listen 80;
    server_name riegel.canyon.e18.com;

            location / {
                    proxy_pass http://backend_riegel;
                    proxy_set_header    X-Real-IP $remote_addr;
                    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header    Host $http_host;
            }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;
}
' > /etc/nginx/sites-available/riegel.canyon.e18.com

ln -s /etc/nginx/sites-available/riegel.canyon.e18.com /etc/nginx/sites-enabled/

service nginx restart
```
Lalu, pada server worker riegel canyon,
```
apt-get update
apt-get install php8.0-mbstring php8.0-xml php8.0-cli php8.0-common php8.0-intl php8.0-opcache php8.0-readline php8.0-mysql php8.0-fpm php8.0-curl unzip wget -y
apt-get install git nginx -y

wget https://getcomposer.org/download/2.0.13/composer.phar
chmod +x composer.phar
mv composer.phar /usr/bin/composer
```
Clone laravel servernya, kemudian di setup laravel app-nya
```
git clone https://github.com/martuafernando/laravel-praktikum-jarkom.git
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
```
Lalu setup servernya
```
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
```
## Soal 15
Untuk melakukan benchmarking POST, dipanggil command berikut pada client.
```
echo '{
    "username": "e18_nuna",
    "password": "pass_e18_nuna"
}' > register_payload.json

ab -n 100 -c 10 -H "Content-Type: application/json" -p register_payload.json http://riegel.canyon.e18.com/api/auth/register
curl -X POST -H "Content-Type: application/json" -d @register_payload.json http://riegel.canyon.e18.com/api/auth/register > ab_register_responses.txt

```
## Soal 16
Untuk melakukan benchmarking login, dipanggil command berikut pada client
```
ab -n 100 -c 10 -H "Content-Type: application/json" -p register_payload.json http://riegel.canyon.e18.com/api/auth/login
curl -X POST -H "Content-Type: application/json" -d @register_payload.json http://riegel.canyon.e18.com/api/auth/login > ab_login_responses.txt
```
## Soal 17
Untuk melakukan benchmarking ME, dipanggil command berikut pada client
```
ab -n 100 -c 10 -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUZI1NiJ9.eyJpc3MiOiJodHRwOi8vcm11Z2VsLmNhbnlvbi5lMTguY29tL2FwaS9hdXRoL2xvZ2luIiwiaWF01joxNzAwMTY2NTkzLCJleHAiOjE3MDAxNzAxOTMsIm5iZiI6MTcwMDE2NjU5MywianRpIjoicUdFMUhYNUk4SXNmZzlJcilsInNlYiI6IjIiLCJwcnYiOiIyM2JkNWM40TQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3In0.WFMlqv2lifzpZZ_2yf9DH6VH2EXPfFDbzk-KY-B23zQ" http://frieren.riegel.canyon.e18.com/api/me
curl -X GET -H "Authorization: (Token dari login)" http://frieren.riegel.canyon.e18.com/api/me > me_response.txt
```
## Soal 18
Proxy bind dikonfigurasikan pada LB Eisen
```
echo '#Default menggunakan Round Robin
upstream backend_riegel {
    server 192.215.1.4; #IP Frieren
    server 192.215.1.5; #IP Flamme
    server 192.215.1.6; #IP Fern
}

server {
    listen 80;
    server_name riegel.canyon.e18.com;

            location / {
                    proxy_pass http://backend_riegel;
                    proxy_set_header    X-Real-IP $remote_addr;
                    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header    Host $http_host;
            }

            location /frieren {
                proxy_bind 192.215.1.4;
                proxy_pass http://backend_riegel;
            }

            location /flamme {
                proxy_bind 192.215.1.5;
                proxy_pass http://backend_riegel;
            }

            location /fern {
                proxy_bind 192.215.1.6;
                proxy_pass http://backend_riegel;
            }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;
}
' > /etc/nginx/sites-available/riegel.canyon.e18.com

service nginx restart
```
## Soal 19
Pada masing-masing worker, dipanggil command berikut
```
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
```
## Soal 20
Pada Eisen, disesuaikan nginx untuk riegel canyon
```
echo '#Default menggunakan Round Robin
upstream backend_riegel {
    least_conn;
    server 192.215.1.4; #IP Frieren
    server 192.215.1.5; #IP Flamme
    server 192.215.1.6; #IP Fern
}

server {
    listen 80;
    server_name riegel.canyon.e18.com;

            location / {
                    proxy_pass http://backend_riegel;
                    proxy_set_header    X-Real-IP $remote_addr;
                    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header    Host $http_host;
            }

            location /frieren {
                proxy_bind 192.215.1.4;
                proxy_pass http://backend_riegel;
            }

            location /flamme {
                proxy_bind 192.215.1.5;
                proxy_pass http://backend_riegel;
            }

            location /fern {
                proxy_bind 192.215.1.6;
                proxy_pass http://backend_riegel;
            }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;
}
' > /etc/nginx/sites-available/riegel.canyon.e18.com

service nginx restart
```
