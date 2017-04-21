#! /bin/bash
CERTS_PATH=~/LetsEncryptCerts

docker pull jwilder/nginx-proxy:alpine

docker run -d -p 80:80 -p 443:443 \
  --name reverse-proxy \
  --restart=always \
  -v $CERTS_PATH:/etc/nginx/certs:ro \
  -v /etc/nginx/vhost.d \
  -v /usr/share/nginx/html \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  -e ENABLE_IPV6=true \
  jwilder/nginx-proxy:alpine
  
# Improve times & co: https://github.com/jwilder/nginx-proxy#replacing-default-proxy-settings && https://github.com/jwilder/nginx-proxy/blob/master/nginx.tmpl#L58-L71 a poner en el archivo de configuración
echo "Docker nginx-proxy (reverse-proxy)"
echo "The docker use the certs in $CERTS_PATH"
