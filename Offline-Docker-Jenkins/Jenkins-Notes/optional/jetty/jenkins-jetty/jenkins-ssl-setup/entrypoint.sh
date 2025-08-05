#!/bin/bash

# Auto-map nginx container IP in /etc/hosts (avoid duplicate entries)
NGINX_IP=$(getent hosts jenkins-nginx | awk '{ print $1 }')
grep -q "jenkins.isrd.cair.drdo" /etc/hosts || echo "$NGINX_IP jenkins.isrd.cair.drdo" >> /etc/hosts

# Trust Jenkins CA
cp /etc/ssl/certs/jenkins-ca.crt /usr/local/share/ca-certificates/jenkins-ca.crt
update-ca-certificates

# Trust Tuleap CA
keytool -import -noprompt -trustcacerts -alias tuleap \
  -keystore /opt/java/openjdk/lib/security/cacerts \
  -file /etc/ssl/certs/tuleap.crt \
  -storepass changeit

# Start Jenkins
exec /usr/local/bin/jenkins.sh

