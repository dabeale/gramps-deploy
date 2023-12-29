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
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout data/nginx/certs/nginx.key -out data/nginx/certs/nginx.crt
openssl dhparam -out data/nginx/dhparam/dhparam.pem 4096

# Create the docker containers
docker compose up -d

# Enable ssl
sed -i 's/if (.*) {/if 0 {/g'
docker exec nginx-proxy service nginx reload


