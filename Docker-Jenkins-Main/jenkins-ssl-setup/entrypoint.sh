# Update CA certificates on Jenkins server
update-ca-certificates

# Import Tuleap's CA cert into Jenkins Java truststore
keytool -import -noprompt -trustcacerts -alias tuleap \
  -keystore /opt/java/openjdk/lib/security/cacerts \
  -file /etc/ssl/certs/tuleap.crt \
  -storepass changeit

# Start Jenkins
exec /usr/local/bin/jenkins.sh

