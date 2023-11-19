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

## Soal 14
## Soal 15
## Soal 16
## Soal 17
## Soal 18
## Soal 19
## Soal 20