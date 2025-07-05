#!/bin/bash

# Trust Jenkins CA
cp /etc/ssl/certs/jenkins-ca.crt /usr/local/share/ca-certificates/jenkins-ca.crt
update-ca-certificates

# Start NGINX in foreground
exec nginx -g 'daemon off;'
