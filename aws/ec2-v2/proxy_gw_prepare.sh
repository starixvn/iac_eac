#! /bin/bash

PASSWORD="1qaz@WSX"
USERNAME="vndeployer"
SV="$(hostname)"

if id -u "$USERNAME" >/dev/null 2>&1; then
    userdel -r -f $USERNAME
    useradd -m -p $PASSWORD -s /bin/bash $USERNAME
    usermod -a -G sudo $USERNAME
    echo $USERNAME:$PASSWORD | chpasswd
    echo "$USERNAME  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers

else
    useradd -m -p $PASSWORD -s /bin/bash $USERNAME
    usermod -a -G sudo $USERNAME
    echo $USERNAME:$PASSWORD | chpasswd
    echo "$USERNAME  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers
fi
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo service ssh restart

##### HAPROXY
sudo apt update
sudo add-apt-repository ppa:vbernat/haproxy-3.0 -y
sudo apt update
sudo apt install -y haproxy=3.0.\*
sudo systemctl enable haproxy
sudo rm -f /etc/haproxy/haproxy.cfg
sudo mkdir -p /etc/haproxy/maps/
sudo echo "
echo.luminetsoft.com echo_be
echo2.luminetsoft.com echo2_be
haproxy.luminetsoft.com haproxystats_be
" >> /etc/haproxy/maps/hosts.map
echo "global
  log 127.0.0.1:514 local0 
  stats socket /var/run/haproxy.sock mode 600 expose-fd listeners level user
  server-state-file /var/lib/haproxy/server-state
  chroot /var/lib/haproxy
  user haproxy
  group haproxy
  daemon

defaults
  log global
  mode http
  option httplog
  option dontlognull
  timeout connect 5000
  timeout client 50000
  timeout server 50000
  errorfile 400 /etc/haproxy/errors/400.http
  errorfile 403 /etc/haproxy/errors/403.http
  errorfile 408 /etc/haproxy/errors/408.http
  errorfile 500 /etc/haproxy/errors/500.http
  errorfile 502 /etc/haproxy/errors/502.http
  errorfile 503 /etc/haproxy/errors/503.http
  errorfile 504 /etc/haproxy/errors/504.http

defaults tcp_defaults
  log global
  mode tcp
  maxconn 10000
  timeout client-fin 5s
  timeout server-fin 5s
  retries 3
  option redispatch
  timeout connect 10s
  timeout client 5m
  timeout server 5m
  timeout tunnel        3600s
  timeout http-keep-alive  1s
  timeout http-request    15s
  timeout queue           30s
  timeout tarpit          60s

defaults http_defaults
  log global
  mode http
  load-server-state-from-file global
  option httplog
  option dontlognull
  balance source
  maxconn 10000
  option forwardfor #except 10.0.101.94
  option httpchk
  timeout connect 10s
  timeout client 5m
  timeout server 5m
  timeout http-keep-alive 1s
  timeout http-request 15s
  timeout queue 30s
  errorfile 400 /etc/haproxy/errors/400.http
  errorfile 403 /etc/haproxy/errors/403.http
  errorfile 408 /etc/haproxy/errors/408.http
  errorfile 500 /etc/haproxy/errors/500.http
  errorfile 502 /etc/haproxy/errors/502.http
  errorfile 503 /etc/haproxy/errors/503.http
  http-check expect status 200 #200-399

frontend status-monitor from http_defaults
  bind *:8080
  mode http
  maxconn 20
  stats enable
  stats refresh 300s
  stats show-legends
  stats show-node
  stats show-modules
  stats realm Haproxy\ Statistics
  stats uri /
  monitor-uri /checkstatus
  stats auth admin:1234aa
default_backend default_backend_nodes

frontend cluster_fe from http_defaults
  bind *:80
  option forwardfor
  option httplog
  capture request header Host len 30
  capture request header User-Agent len 200
  capture request header Referer len 800
  capture request header X-Forwarded-For len 20
  option http-keep-alive
  use_backend %[req.hdr(host),lower,map_dom(/etc/haproxy/maps/hosts.map)]
default_backend empty_backend_nodes

backend default_backend_nodes from http_defaults
  mode http
  http-request return status 503 content-type 'text/plain' lf-string '503 Service Unavailable ! Pls contact NexOps if you think this is a mistake...'

backend echo_be from http_defaults
  http-request set-header Host echo.luminetsoft.com
  http-check send meth GET uri / hdr Host "echo.luminetsoft.com"
  server cluster_eks 10.6.7.0:80 check

backend haproxystats_be from http_defaults
  server cluster_eks 10.6.7.0:1024

backend echo2_be from http_defaults
  http-request return status 200 content-type 'text/plain'  lf-string 'echo2_be. LOCAL AWS $SV'

backend empty_backend_nodes from http_defaults
  http-request return status 200 content-type 'text/plain'  lf-string 'I am Testing... $SV'
" >> /etc/haproxy/haproxy.cfg
sudo service haproxy restart