apt-get update
apt-get install nginx bind9 php7.3 php7.3-fpm apache2-utils -y

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

## To setup web page
apt install python3 python3-pip -y
pip3 install gdown

gdown --id 1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1

apt-get install unzip -y
unzip granz.channel.yyy.com.zip
rm granz.channel.yyy.com.zip

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
        fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
' > /etc/nginx/sites-available/default

service nginx restart

# pastikan listen ke socket php
# nano /etc/php/7.3/fpm/pool.d/www.conf

# bagian ini
# listen = /var/run/php/php7.3-fpm.sock

service php7.3-fpm start -v
service php7.3-fpm restart -v

# load balance no 7
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

# load balance no 8
# unweighted round robin
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

# load balance least connection
echo '#Default menggunakan Round Robin
upstream backend  {
    least_conn;
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

# load balance ip hash
echo '#Default menggunakan Round Robin
upstream backend  {
    ip_hash;
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

# load balance generic hash
echo '#Default menggunakan Round Robin
upstream backend  {
    hash $request_uri consistent;
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

# authorize (will invoke prompt)
mkdir /etc/nginx/rahasisakita/
htpasswd -c /etc/nginx/rahasisakita/.htpasswd netics

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

# proxy pass
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

# Selanjutnya LB ini hanya boleh 
# diakses oleh client dengan IP [Prefix IP].3.69, [Prefix IP].3.70, [Prefix IP].4.167, 
# dan [Prefix IP].4.168. (12) hint: (fixed in dulu clinetnya)
# (NEED TO TEST)
# echo '#Default menggunakan Round Robin
# upstream backend  {
#     server 192.215.4.4; #IP Lawine
#     server 192.215.4.3; #IP Linie
#     server 192.215.4.2; #IP Lugner
# }

# server {
#     listen 80;
#     server_name granz.channel.e18.com;

#     allow 192.215.3.69;
#     allow 192.215.3.70;
#     allow 192.215.4.167;
#     allow 192.215.4.168;
#     deny all;

#             location / {
#                     proxy_pass http://backend;
#                     proxy_set_header    X-Real-IP $remote_addr;
#                     proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
#                     proxy_set_header    Host $http_host;

#                     auth_basic "Administrator'\''s Area";
#                     auth_basic_user_file /etc/nginx/rahasisakita/.htpasswd;
#             }

#             location ~ /\.ht {
#                 deny all;
#             }

#             location /its {
#                     proxy_pass https://www.its.ac.id;
#                     proxy_set_header X-Forwarded-Proto $scheme;
#             }

#     error_log /var/log/nginx/lb_error.log;
#     access_log /var/log/nginx/lb_access.log;

# }
# ' > /etc/nginx/sites-available/default

# service nginx restart

# setup riegel canyon
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

# echo '
# ; BIND data file for local loopback interface
# ;
# $TTL    604800
# @       IN      SOA     riegel.canyon.e18.com. root.riegel.canyon.e18.com. (
#                         2023110101    ; Serial
#                         604800        ; Refresh
#                         86400         ; Retry
#                         2419200       ; Expire
#                         604800 )      ; Negative Cache TTL
# ;
# 3.215.192.in-addr.arpa.         IN      NS      riegel.canyon.e18.com.
# 3                               IN      PTR     riegel.canyon.e18.com.
# ' > /etc/bind/jarkom/3.215.192.in-addr.arpa

service bind9 restart

# setup riegel canyon nginx
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

# proxy bind
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

# use least_con
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
