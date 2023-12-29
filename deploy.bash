#!/usr/bin/env bash

# Run from script location
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

# Create the directory structure
for ds in certs dhparam conf; do
  mkdir -p data/nginx/$ds
done
for ds in users index thumbnail_cache db media; do
  mkdir -p data/gramps/$ds
done

# Add the my_proxy configuration
cp my_proxy.conf data/nginx/conf

# Create the ssl certificates
CERTS=data/nginx/certs
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $CERTS/nginx.key -out $CERTS/nginx.crt
#openssl dhparam -out data/nginx/dhparam/dhparam.pem 4096

for ct in key crt; do
  cp $CERTS/nginx.$ct $CERTS/default.$ct
done

# Create the docker containers
docker compose up -d

# Wait for configuration
CONF=data/nginx/conf/default.conf
while [ ! -f $CONF ]; do
  echo "Waiting for configuration file..."
  sleep 5
done
sleep 1

# Enable ssl
sed -i 's/return 500;//g' $CONF
sed -i 's/default.key/nginx.key/g' $CONF
sed -i 's/default.crt/nginx.crt/g' $CONF

docker exec nginx-proxy service nginx reload

