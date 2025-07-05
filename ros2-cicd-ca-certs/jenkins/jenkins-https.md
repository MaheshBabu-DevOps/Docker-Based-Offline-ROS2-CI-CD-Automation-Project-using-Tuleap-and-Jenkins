								JENKINS

/srv/jenkins/jenkins-ssl-setup/certs/
├── jenkins.crt.pem              ← Copy from jenkins.isrd.cair.drdo-cert.crt
├── jenkins.key.pem              ← Copy from jenkins.isrd.cair.drdo-private-key.pem
├── internal-ca.crt.pem          ← Copy from ca-cert.crt


ssl_certificate         /etc/nginx/certs/jenkins.crt.pem;
ssl_certificate_key     /etc/nginx/certs/jenkins.key.pem;
ssl_trusted_certificate /etc/nginx/certs/internal-ca.crt.pem;

..........................................................................................................................................

#process

# Create required directories
sudo mkdir -p /srv/jenkins/jenkins-ssl-setup/{certs,nginx,ca-certificates}

# Create entrypoint scripts and placeholder certificate
sudo touch entrpoint.sh nginx-entrypoint.sh tuleap.crt


# Go to cert source
cd ~/keys/keys-and-cert-jenkins.isrd.cair.drdo/


#✅ — NGINX fully accepts .pem format for both certificates and private keys.
# Copy and rename to match NGINX config
sudo cp jenkins.isrd.cair.drdo-cert.crt /srv/jenkins/jenkins-ssl-setup/certs/jenkins.crt.pem
sudo cp jenkins.isrd.cair.drdo-private-key.pem /srv/jenkins/jenkins-ssl-setup/certs/jenkins.key.pem


# Copy the CA cert
cp ~/keys/CA-key-and-cert/ca-cert.crt /srv/jenkins/jenkins-ssl-setup/certs/zentyal-ca.crt.pem

or

cp ~/keys/CA-key-and-cert/ca-cert.crt /srv/jenkins/jenkins-ssl-setup/certs/jenkins-ca.crt


ls -l /srv/jenkins/jenkins-ssl-setup/certs/

#host
sudo rm /usr/local/share/ca-certificates/jenkins-ca.crt
sudo update-ca-certificates --fresh
sudo cp ca-cert.crt /usr/local/share/ca-certificates/jenkins-ca.crt
sudo update-ca-certificates



#note
✅ .pem files are standard and recommended.

✅ NGINX uses PEM format internally for SSL/TLS.

✅ NGINX requires PEM format, and accepts files with .pem, .crt, or .key extensions — as long as the format inside is correct.



#✅ jenkins.conf
server {
    listen 8443 ssl;
    server_name jenkins.isrd.cair.drdo;

    ssl_certificate /etc/nginx/certs/jenkins.crt.pem;
    ssl_certificate_key /etc/nginx/certs/jenkins.key.pem;
    ssl_trusted_certificate /etc/nginx/certs/internal-ca.crt.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://jenkins:8080;

        # ✅ REQUIRED HEADERS for Jenkins reverse proxy
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Port 8443;
        proxy_set_header X-Forwarded-Host $host;

        proxy_redirect http:// https://;

        # Optional, but recommended
        proxy_read_timeout 90;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name jenkins.isrd.cair.drdo;
    return 301 https://$host$request_uri;
}

#save and exit!


#docker-compose file

version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts-jdk17
    hostname: jenkins    # Short hostname
    container_name: jenkins
    user: root
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock  # Security risk! Only use in trusted environments.
      - /usr/bin/docker:/usr/bin/docker
      - /srv/jenkins/jenkins-ssl-setup/certs:/var/jenkins_home/ssl
      - /srv/jenkins/jenkins-ssl-setup/ca-certificates/jenkins-ca.crt:/etc/ssl/certs/jenkins-ca.crt
#      - /srv/jenkins/jenkins-ssl-setup/tuleap.crt:/etc/ssl/certs/tuleap.crt
      - /srv/jenkins/jenkins-ssl-setup/entrypoint.sh:/entrypoint.sh
    environment:
      - JENKINS_HOME=/var/jenkins_home
      - JENKINS_OPTS=--httpPort=8080 --httpsPort=-1  # Disable built-in HTTPS (Nginx handles SSL)
    entrypoint: /entrypoint.sh
    networks:
      - jenkins-network
    restart: unless-stopped


  nginx:
    image: nginx:latest
    container_name: jenkins-nginx
    ports:
      - "80:80"
      - "8443:8443"
    volumes:
      - /srv/jenkins/jenkins-ssl-setup/nginx/jenkins.conf:/etc/nginx/conf.d/default.conf
      - /srv/jenkins/jenkins-ssl-setup/certs:/etc/nginx/certs
#      - /srv/jenkins/jenkins-ssl-setup/ca-certificates/jenkins-ca.crt:/usr/local/share/ca-certificates/jenkins-ca.crt
#      - /srv/jenkins/jenkins-ssl-setup/nginx-entrypoint.sh:/etc/nginx/nginx-entrypoint.sh
    depends_on:
      - jenkins
#    entrypoint: /etc/nginx/nginx-entrypoint.sh
    networks:
      jenkins-network:
        aliases:
          - jenkins.isrd.cair.drdo
    restart: unless-stopped

volumes:
  jenkins_home:

networks:
  jenkins-network:
    driver: bridge

#save and exit!


#✅note
use port 443 instead of 8443 must update the NGINX listen directive and headers accordingly.
# REMOVE THIS unless you use certs in jobs:
# - /srv/jenkins/jenkins-ssl-setup/certs:/var/jenkins_home/ssl




#✅ entrypoint(jenkins)

sudo entrypoint.sh 

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

#save and exit



#sudo  nginx-entrypoint.sh (nginx)

#!/bin/bash

# Trust Jenkins CA
cp /etc/ssl/certs/jenkins-ca.crt /usr/local/share/ca-certificates/jenkins-ca.crt
update-ca-certificates

# Start NGINX in foreground
exec nginx -g 'daemon off;'

#save and exit

sudo chmod +x entrypoint.sh
sudo chmod +x nginx-entrypoint.sh




#cd /srv/jenkins/jenkins-ssl-setup/certs(optional)
--------------------------------------------------
| Use Case                 | Need JKS? | PEM OK? |
| ------------------------ | --------- | ------- |
| Jenkins HTTPS directly   | ✅ Yes     | ❌ No |
| Jenkins **behind NGINX** | ❌ No      | ✅ Yes|
-------------------------------------------------

#🧾 Why conversion is needed:
Java (like Jenkins) does not understand PEM files directly. It needs certificates in JKS format (Java Keystore).
---------------------------------------------------------------------------------------------------------------------------
| Step | What you're doing                                                               | Resulting file                  |
| ---- | ------------------------------------------------------------------------------- | ------------------------------- |
| 1️⃣  | Combine your `.crt` and `.key` into one file that Java can read using `openssl` | ✅ `jenkins.p12` (PKCS12 format) |
| 2️⃣  | Convert that `.p12` file into a Java-friendly format using `keytool`            | ✅ `jenkins.jks` (Java Keystore) |
----------------------------------------------------------------------------------------------------------------------------


sudo openssl pkcs12 -export   -in jenkins.crt.pem   -inkey jenkins.key.pem   -certfile internal-ca.crt.pem   -out jenkins.p12   -name jenkins-keypair


sudo keytool -importkeystore   -srckeystore jenkins.p12   -srcstoretype PKCS12   -destkeystore jenkins.jks   -deststoretype JKS   -alias jenkins-keypair


# ls /srv/jenkins/jenkins-ssl-setup/certs

internal-ca.crt.pem       # Your CA certificate (trust anchor)
jenkins.crt.pem           # Server certificate
jenkins.key.pem           # Private key
jenkins.p12               # PKCS12 keystore (bundle of key+cert+CA)---optional
jenkins.jks               # Java Keystore (JKS) for Java-based apps---optional


#certs
internal-ca.crt.pem  jenkins.crt.pem  jenkins.jks  jenkins.key.pem  jenkins.p12


#docker-compose

docker-compose down
docker-compose up  -d


#✅output
-------------------------------------------------------------------------------------------------
| Container Name  | Image                       | Ports                         | Purpose       |
| --------------- | --------------------------- | ----------------------------- | ------------- |
| `jenkins`       | `jenkins/jenkins:lts-jdk17` | 8080 (web UI), 50000 (agents) | Jenkins core  |
| `jenkins-nginx` | `nginx:latest`              | 80 (HTTP), **8443 (HTTPS)**   | Reverse proxy |
-------------------------------------------------------------------------------------------------

#firefox
Settings → Privacy & Security → Certificates → View Certificates--import

/srv/jenkins/jenkins-ssl-setup/certs/jenkins-ca.crt

#note
Firefox (and most browsers) do not trust your internal CA (CAIR Authority Certificate) by default.
Your certificate is valid — but it’s not issued by a public Certificate Authority like DigiCert or Let's Encrypt, so the browser warns users for safety.


#🧪 Now Test
https://jenkins.isrd.cair.drdo

...................................................................................................................................................

✅ Verify:
curl -vk https://jenkins.isrd.cair.drdo:8443
openssl s_client -connect jenkins.isrd.cair.drdo:8443 -showcerts
curl -v --cacert internal-ca.crt.pem https://jenkins.isrd.cair.drdo
openssl x509 -in ca-cert.crt -noout -text


Verify the certificate’s domain (CN/SAN)
openssl x509 -in /srv/jenkins/jenkins-ssl-setup/certs/jenkins.crt.pem -noout -text | grep -A 1 "Subject Alternative Name"
openssl x509 -in jenkins.isrd.cair.drdo-cert.crt -noout -text | grep -A1 "Subject Alternative Name"

❌ certificate has no Subject Alternative Name (SAN) field.



#verifiy
openssl x509 -in jenkins.isrd.cair.drdo-cert.crt -noout -text | grep -A1 "Subject Alternative Name"


-------------------------------------------------------------------------------------------------------------------------------------------------

#container
cat /etc/hosts

172.18.0.2  jenkins.isrd.cair.drdo jenkins
The name jenkins.isrd.cair.drdo resolves to 172.18.0.2, which is the IP of the Jenkins container itself, not NGINX.

#verify
docker network inspect jenkins_jenkins-network 


#So this command fails:
openssl s_client -connect jenkins.isrd.cair.drdo:8443
Because it tries to connect to itself (jenkins), and Jenkins is not listening on port 8443 (that’s NGINX's job).


#nginx
    networks:
      jenkins-network:
        aliases:
          - jenkins.isrd.cair.drdo


docker-compose down
docker-compose up -d


-------------------------------------------------------------------------------------
| Entry                               | Purpose                                     |
| ----------------------------------- | ------------------------------------------- |
| `127.0.0.1 localhost`               | Self-reference in IPv4                      |
| `::1 localhost`                     | Self-reference in IPv6                      |
| `172.18.0.2 jenkins`                | Docker container's own name/IP              |
| `172.18.0.3 jenkins.isrd.cair.drdo` | Domain name resolves to NGINX (HTTPS proxy) |
-------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
#docker-compose.yaml-(explain)--final
#Jenkins Container

#without hostname and alias and extra hosts

172.18.0.2    93488cbcfab4           # Random container ID (default)
172.18.0.3    jenkins.isrd.cair.drdo # Added by Docker's DNS


The FQDN (jenkins.isrd.cair.drdo) resolves to 172.18.0.3 (Nginx's IP)

This allows SSL to work (openssl s_client connects to Nginx, not Jenkins itself)


#Nginx Container

172.18.0.3    4fc0d3ea8c0c           # Only has its own container ID

No automatic FQDN resolution because:

No other containers reference jenkins.isrd.cair.drdo in Nginx's network

Nginx doesn't need to resolve itself via FQDN



#The Problem (Long-Term Risks)
Debugging Difficulties

Random container IDs (93488cbcfab4) make logs hard to read

Self-Connection Issues

If Jenkins ever needs to call itself via FQDN, it will fail


#Recommended Fix--------------------------------------------------1

Define hostname in docker-compose.yml
services:
  jenkins:
    hostname: jenkins  # <<< Add this line
    container_name: jenkins
    
#/etc/hosts in Jenkins container will show:
172.18.0.2    jenkins               # From hostname setting
172.18.0.3    jenkins.isrd.cair.drdo # Auto-added by Docker DNS

jenkins.isrd.cair.drdo resolves to Nginx's IP (172.18.0.3) because:

Docker's internal DNS automatically manages FQDN resolution between containers

Nginx is configured to handle SSL for this domain

Without hostname: Docker uses random container IDs (e.g., 83e65d43328b) in /etc/hosts

With hostname: jenkins: Forces a clean, readable hostname (172.18.0.2 jenkins)


#SSL Connectivity
openssl s_client -connect jenkins.isrd.cair.drdo:8443 succeeds because:
The FQDN points to Nginx (which listens on 8443)
Certificates match perfectly (CN=jenkins.isrd.cair.drdo)



#Why You Should Add the Alias------------------------------------2

#🧠 What is aliases in Docker Compose?

Give this container an extra name inside the Docker network.
You want one container (e.g., nginx) to access another container (e.g., jenkins) using a custom name like jenkins.isrd.cair.drdo.
#🧪 Test 
curl -vk https://jenkins.isrd.cair.drdo:8443

#🔹 With aliases
networks:
  jenkins-network:
    aliases:
      - jenkins.isrd.cair.drdo


✅ Definition:
Creates an extra DNS name for the container within the Docker network, allowing other containers to resolve it using that alias.

✅ Use Case:
When you want to access a container (like Jenkins) via a custom FQDN (e.g., jenkins.isrd.cair.drdo) from another container (like NGINX proxy).


#🔹 Without aliases
networks:
  - jenkins-network

🚫 Definition:
Only the container name (or hostname if set) is used for resolution. No extra DNS name.

🚫 Use Case:
Other containers must refer to it by container name (e.g., jenkins) — FQDN won't resolve unless mapped manually or with aliases.

--------------------------------------------------------------------------------------------------------------
| Feature                     | With `aliases`                           | Without `aliases`                 |
| --------------------------- | ---------------------------------------- | --------------------------------- |
| Custom FQDN inside network  | ✅ Works (e.g., `jenkins.isrd.cair.drdo`) | ❌ Not available                |
| Use in NGINX `proxy_pass`   | ✅ Use alias                              | 🔁 Must use `http://jenkins:8080`|
| Docker internal DNS mapping | ✅ Adds alias → IP                        | 🟡 Only container name → IP    |
| Flexibility in large setups | ✅ High (e.g., domain matching certs)     | 🔁 Limited to container name only |
----------------------------------------------------------------------------------------------------------------


#✅ Why Jenkins container does not need the alias:
---------------------------------------------------------------------------------------------------------
| Role   | Container | Needs alias? | Why?                                                               |
| ------ | --------- | ------------ | ------------------------------------------------------------------ |
| Server | Jenkins   | ❌ No         | Just listens, doesn't care how clients reach it                   |
| Client | NGINX     | ✅ Yes        | Needs to resolve `jenkins.isrd.cair.drdo` to connect (proxy\_pass)|
----------------------------------------------------------------------------------------------------------

--alias adds a DNS name inside Docker network.

--It’s only needed in containers that act as clients, not servers.

--That’s why NGINX needs it (to reach Jenkins via FQDN), but Jenkins doesn’t.

#Jenkins is the backend, it does not need to resolve its own FQDN.

#NGINX proxies to Jenkins using proxy_pass https://jenkins.isrd.cair.drdo:8443;, so it needs the alias.

#Docker’s internal DNS (because of aliases:) makes jenkins.isrd.cair.drdo resolve correctly inside the jenkins-nginx container.



#Correct Placement (Nginx Service)
services:
   container_name: jenkins-nginx
    networks:
      jenkins-network:
        aliases:
          - jenkins.isrd.cair.drdo  # <<< # FQDN points to Nginx
          
          
 
 
 
 
 


#container_name: jenkins-nginx or nginx-------------------------------------3
✅ Use container_name: nginx → fine for simple local dev, but not scalable.

✅ Use container_name: jenkins-nginx → clear ownership, avoids naming conflicts, best for production & CI/CD pipelines.
 
#🔄 Comparison: nginx vs jenkins-nginx as container_name
--------------------------------------------------------------------------------------------------------------------------------------------------
| **Scenario**            | `container_name: nginx`                          | `container_name: jenkins-nginx`                                     |
| ----------------------- | ------------------------------------------------ | ------------------------------------------------------------------- |
| **CLI Access**          | `docker exec -it nginx bash`                     | `docker exec -it jenkins-nginx bash`                                |
| **Logs/Monitoring**     | Generic; not clear in multi-service projects     | Explicitly tied to Jenkins; easy to search & grep                   |
| **Multi-Container Env** | Can cause name clashes (e.g., with other NGINX)  | Unique and context-specific; better in complex setups               |
| **Network Resolution**  | **Same** (hostname/FQDN resolves via Docker DNS) | **Same** (no impact on `aliases`, `hostname`, or service discovery) |
| **Readability**         | Short, simple, but ambiguous in multi-app setups | Clear, namespaced, great for larger infrastructure                  |
| **Best Practice**       | OK for small/local setups                        | **Recommended** for production, CI/CD, microservices                ----------------------------------------------------------------------------------------------------------------------------------------------------

#container name
services:
  nginx:
    container_name: jenkins-nginx  # Explicit container name






#Mount CA cert into nginx container(optional)-----------------------------------------4
🔧 Use When:
Add CA when:
✅ Backend services use internal/self-signed TLS
✅ You want secure reverse proxying

Don't add CA when:
⚠️ Backend is HTTP-only
⚠️ You temporarily skip validation (not recommended for prod)

#process

volumes:
 - /srv/jenkins/jenkins-ssl-setup/ca-certificates/jenkins-ca.crt:/usr/local/share/ca-certificates/jenkins-ca.crt
 - /srv/jenkins/jenkins-ssl-setup/nginx-entrypoint.sh:/etc/nginx/nginx-entrypoint.sh


#sudo nano nginx-entrypoint.sh

#!/bin/bash

# Trust Jenkins CA
cp /etc/ssl/certs/jenkins-ca.crt /usr/local/share/ca-certificates/jenkins-ca.crt
update-ca-certificates

# Start NGINX in foreground
exec nginx -g 'daemon off;'

sudo chmod +x nginx-entrypoint.sh

#save and exit!





#compsoe

docker-compose down
docker-compose up -d



#verify(host and container)------------------------------5
docker exec -it jenkins bash

#verify
#host
netstat -tulnp | grep 8443
docker exec -it jenkins-nginx bash -c "nginx -t"
ss -tulnp | grep 8443
curl -vk https://localhost:8443

#container
docker exec -it jenkins bash
openssl s_client -connect jenkins.isrd.cair.drdo:8443
curl -vk https://jenkins.isrd.cair.drdo:8443
curl -v --cacert /etc/ssl/certs/jenkins-ca.crt https://jenkins.isrd.cair.drdo:8443

#Logs 
docker logs jenkins
docker logs -f jenkins
docker exec jenkins-nginx nginx -t


#verify 
#Host and container verify the certificates
openssl s_client --connect jenkins.isrd.cair.drdo:443
docker exec -it jenkins keytool -list -keystore  opt/java/openjdk/lib/security/cacerts -storepass changeit | grep tuleap
keytool -list -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit | grep tuleap

#✅ Check Java Truststore (cacerts) for Your CA
$ keytool -list -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit | grep tuleap

# Host: Check full cert chain is valid(host~container)
curl -Iv https://jenkins.isrd.cair.drdo

#jenkins~tuleap
curl -Iv https://tuleap.isrd.cair.drdo

#eg:-
✅ Jenkins can reach Tuleap via HTTPS.

✅ Jenkins trusts Tuleap’s certificate.

✅ Tuleap is working properly on port 443 and responds correctly.

🌐 The domain tuleap.isrd.cair.drdo resolves inside Jenkins.

#tuleap~jenkins
curl -Iv https://jenkins.isrd.cair.drdo


------------------------------------------------------------------------------------------------------------------------------------------------
						docker-compose.yml(file)


#✅ version: '3.8'
Specifies the version of the Docker Compose file format.

3.8 is compatible with newer Docker engines and supports advanced networking and volume features.


#🧱 Services Section
🔧 Service: jenkins

#image: jenkins/jenkins:lts-jdk17
Uses the Jenkins LTS (Long-Term Support) image with JDK 17.


#Sets the internal container hostname to jenkins.
hostname: jenkins


#Names the container jenkins for easier reference (instead of random auto-generated name).
container_name: jenkins


#Runs the Jenkins container as root
user: root


#📁 Jenkins Volumes (Bind Mounts + Named)

#bind mount
When you use a bind mount, a file or directory on the host machine is mounted from the host into a container.

#volumes
Volumes are persistent data stores for containers, created and managed by Docker


# Stores Jenkins data in a Docker volume named jenkins_home.
- jenkins_home:/var/jenkins_home

# Allows Jenkins (inside container) to access Docker daemon on host.
- /var/run/docker.sock:/var/run/docker.sock

# Mount Docker CLI binary — needed for Jenkins jobs to run docker commands
- /usr/bin/docker:/usr/bin/docker


# (Optional) Makes certs available to Jenkins jobs inside the container at /var/jenkins_home/ssl.
- /srv/jenkins/jenkins-ssl-setup/certs:/var/jenkins_home/ssl


# Add internal CA cert into Jenkins container so it trusts Tuleap/Jenkins HTTPS
- /srv/jenkins/jenkins-ssl-setup/ca-certificates/jenkins-ca.crt:/etc/ssl/certs/jenkins-ca.crt


# Custom startup script for Jenkins container (sets /etc/hosts, installs CA, etc.)
- /srv/jenkins/jenkins-ssl-setup/entrypoint.sh:/entrypoint.sh




#🌍 Environment
--Environment variables are settings you give to an application from outside, like passwords, ports, or file paths.
--In Docker, they help you control how a container behaves without changing the code or image.


#Explicitly sets the Jenkins data directory.
- JENKINS_HOME=/var/jenkins_home
-------------------------------------------------------------
| Part                | Meaning                              |
| ------------------- | ------------------------------------ |
| `JENKINS_HOME`      | ✅ **Environment variable name**      |
| `/var/jenkins_home` | ✅ **Value assigned to the variable** |
---------------------------------------------------------------


#Disables Jenkins internal HTTPS — NGINX will handle SSL.

#Jenkins will only listen on port 8080 (HTTP).
- JENKINS_OPTS=--httpPort=8080 --httpsPort=-1



#🚪 Entrypoint
In Docker, entrypoint overrides the default startup command defined in the Docker image. It defines what script or binary will run when the container starts.
--------------------------------------------------------------------------------------------------------------------------
| Part                                           | Meaning                                                               |
| ---------------------------------------------- | --------------------------------------------------------------------- |
| `/srv/jenkins/jenkins-ssl-setup/entrypoint.sh` | 🔧 The **host-side script** file on your Ubuntu system                |
| `/entrypoint.sh`                               | 📦 The **path inside the container** (overrides default `ENTRYPOINT`) |
---------------------------------------------------------------------------------------------------------------------------

- entrypoint: /entrypoint.sh



#🔗 Network
#Connects this service to a custom Docker bridge network so jenkins and nginx containers can talk internally.
networks:
  - jenkins-network



#🔁 Restart policy
#Automatically restarts Jenkins if it crashes or the host reboots, unless you manually stop it.

restart: unless-stopped


#🌐 Service: nginx (SSL Reverse Proxy)
#Uses the latest NGINX image.
image: nginx:latest


#Names the container jenkins-nginx.
container_name: jenkins-nginx


#Exposes:

Port 80: handles unencrypted HTTP (auto-redirects to HTTPS).

Port 443: handles secure HTTPS traffic.

ports:
  - "80:80"
  - "443:443"



#📁 Volumes
#Mounts your custom NGINX config file into the container.
- /srv/jenkins/jenkins-ssl-setup/nginx/jenkins.conf:/etc/nginx/conf.d/default.conf


#Provides NGINX access to your SSL certificates and keys.
- /srv/jenkins/jenkins-ssl-setup/certs:/etc/nginx/certs


#(Optional) Makes internal CA trusted by NGINX (not always needed).
- /srv/jenkins/jenkins-ssl-setup/ca-certificates/jenkins-ca.crt:/usr/local/share/ca-certificates/jenkins-ca.crt


#Custom entrypoint script for NGINX to update CA trust or dynamically configure settings.

- /srv/jenkins/jenkins-ssl-setup/nginx-entrypoint.sh:/etc/nginx/nginx-entrypoint.sh


#📦 depends_on
#Ensures Jenkins starts before NGINX.

depends_on:
  - jenkins



#🔗 Network + Alias
#Adds DNS alias inside Docker network so NGINX can call Jenkins by the domain name jenkins.isrd.cair.drdo.
networks:
  jenkins-network:
    aliases:
      - jenkins.isrd.cair.drdo


#🚪 Entrypoint
#Runs your custom NGINX entrypoint script before the main server starts.

entrypoint: /etc/nginx/nginx-entrypoint.sh



#📦 Volumes
#Declares named volume jenkins_home for Jenkins persistent storage.

volumes:
  jenkins_home:


#🌐 Networks
#Creates a custom Docker bridge network so services can securely talk to each other.

networks:
  jenkins-network:
    driver: bridge



#note
# two volume parts
Top = Use this volume inside Jenkins.

Bottom = Declare this volume so Docker knows to create it.

#✅ Summary
-----------------------------------------------------------------------------------------
| Component             | Role                                                           |
| --------------------- | -------------------------------------------------------------- |
| `jenkins`             | Main Jenkins server (HTTP only, port 8080)                     |
| `nginx`               | Reverse proxy that terminates SSL, runs on ports 80/443        |
| `jenkins.conf`        | NGINX config to route HTTPS to Jenkins                         |
| `entrypoint.sh`       | Jenkins script to trust internal CA, map DNS                   |
| `nginx-entrypoint.sh` | Optional NGINX CA update script                                |
| SSL certs             | Stored in `/srv/jenkins/jenkins-ssl-setup/certs/` (PEM format) |
| Network               | Custom bridge with alias: `jenkins.isrd.cair.drdo`             |
------------------------------------------------------------------------------------------



-------------------------------------------

#errors
🔴 Your client machine can resolve the hostname jenkins.isrd.cair.drdo, but cannot establish a TCP connection on port 8443 — because the Jenkins server (or its NGINX reverse proxy) is not listening on port 8443.


  nginx:
    ...
    ports:
      - "8443:443"  # ✅ Must be this (host:container)

docker-compose down
docker-compose up -d

docker ps | grep nginx
docker exec -it jenkins-nginx netstat -tuln | grep 443
sudo ufw allow 8443

#✅ Test directly from Jenkins host
curl -vk https://localhost:443

curl -vk https://jenkins.isrd.cair.drdo:8443

| ✅ Checkpoint                        | What to Confirm                                   |
| ----------------------------------- | -------------------------------------------------- |
| `docker-compose.yml` has `8443:443` | Correct port mapping from host to container        |
| NGINX is running                    | `docker ps` shows NGINX container active           |
| NGINX listens on 443 inside         | `netstat` or `ss` shows port 443 in container      |
| UFW allows port 8443                | `sudo ufw allow 8443` if needed                    |
| DNS is resolving                    | `ping jenkins.isrd.cair.drdo` from client succeeds |

















