echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt-get update
apt-get install dnsutils lynx apache2-utils vsftpd -y

echo 'nameserver 192.215.3.3
nameserver 8.8.8.8' > /etc/resolv.conf

# try accessing eisen
# lynx http://granz.channel.e18.com/

# benchmark
cd /root/
mkdir benchmark && cd benchmark
# testing dengan 1000 request dan 100 request/second
ab -n 1000 -c 100 -g eisen.data http://granz.channel.e18.com/
ab -n 1000 -c 100 -g lawine.data http://lawine.granz.channel.e18.com/
ab -n 1000 -c 100 -g linie.data http://linie.granz.channel.e18.com/
ab -n 1000 -c 100 -g lugner.data http://lugner.granz.channel.e18.com/

# testing dengan 200 request dan 10 request/second
ab -n 200 -c 10 -g eisen.data http://granz.channel.e18.com/
# testing dengan 100 request dan 10 request/second
ab -n 100 -c 10 -g eisen.data http://granz.channel.e18.com/

# testing with auth
ab -A netics:ajke18 -n 100 -c 100 http://granz.channel.e18.com/
ab -A netics:abc123 -n 100 -c 100 http://granz.channel.e18.com/

# Riegel Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada grimoire.
# POST /auth/register (15)
echo '{
    "username": "e18_nuna",
    "password": "pass_e18_nuna"
}' > register_payload.json

ab -n 100 -c 10 -H "Content-Type: application/json" -p register_payload.json http://riegel.canyon.e18.com/api/auth/register
curl -X POST -H "Content-Type: application/json" -d @register_payload.json http://riegel.canyon.e18.com/api/auth/register > ab_register_responses.txt

# # POST /auth/login (16)
ab -n 100 -c 10 -H "Content-Type: application/json" -p register_payload.json http://riegel.canyon.e18.com/api/auth/login
curl -X POST -H "Content-Type: application/json" -d @register_payload.json http://riegel.canyon.e18.com/api/auth/login > ab_login_responses.txt

# # GET /me (17)
ab -n 100 -c 10 -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUZI1NiJ9.eyJpc3MiOiJodHRwOi8vcm11Z2VsLmNhbnlvbi5lMTguY29tL2FwaS9hdXRoL2xvZ2luIiwiaWF01joxNzAwMTY2NTkzLCJleHAiOjE3MDAxNzAxOTMsIm5iZiI6MTcwMDE2NjU5MywianRpIjoicUdFMUhYNUk4SXNmZzlJcilsInNlYiI6IjIiLCJwcnYiOiIyM2JkNWM40TQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3In0.WFMlqv2lifzpZZ_2yf9DH6VH2EXPfFDbzk-KY-B23zQ" http://frieren.riegel.canyon.e18.com/api/me
curl -X GET -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUZI1NiJ9.eyJpc3MiOiJodHRwOi8vcm11Z2VsLmNhbnlvbi5lMTguY29tL2FwaS9hdXRoL2xvZ2luIiwiaWF01joxNzAwMTY2NTkzLCJleHAiOjE3MDAxNzAxOTMsIm5iZiI6MTcwMDE2NjU5MywianRpIjoicUdFMUhYNUk4SXNmZzlJcilsInNlYiI6IjIiLCJwcnYiOiIyM2JkNWM40TQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3In0.WFMlqv2lifzpZZ_2yf9DH6VH2EXPfFDbzk-KY-B23zQ" http://frieren.riegel.canyon.e18.com/api/me > me_response.txt

# testing php fpm
ab -n 100 -c 10 -g eisen.data http://riegel.canyon.e18.com/