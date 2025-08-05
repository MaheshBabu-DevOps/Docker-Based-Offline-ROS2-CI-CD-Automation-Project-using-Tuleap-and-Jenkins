#Tuleap server certificate--------1

Jenkins (Java app) can securely connect to Tuleap over HTTPS, we need to make two levels of trust available inside the Jenkins container:


| Layer      | Command / Action                                                          | Purpose                                    |
| ---------- | ------------------------------------------------------------------------- | ------------------------------------------ |
| **Linux**  | `update-ca-certificates`                                                  | Allows `curl`, `wget` etc. to trust Tuleap |
| **Java**   | `keytool -import ... -alias tuleap`                                       | Allows Jenkins itself to trust Tuleap      |
| **Verify** | `openssl x509 -in /etc/ssl/certs/tuleap.crt -text`<br>`keytool -list ...` | Confirms installation and visibility       |


/srv/jenkins/jenkins-ssl-setup/tuleap.crt:/etc/ssl/certs/tuleap.crt  # Trusts Tuleap's CA


| Part                                        | Meaning                                                                                         |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `/srv/jenkins/jenkins-ssl-setup/tuleap.crt` | Path **on the host system** (Ubuntu/Linux) where the **Tuleap server's certificate** is stored. |
| `/etc/ssl/certs/tuleap.crt`                 | Path **inside the Jenkins container** where the certificate will be available.                  |


/etc/ssl/certs/tuleap.crt              ✅  <-- This is your Tuleap certificate (mounted)
/etc/ssl/certs/ca-certificates.crt     ✅  <-- Bundle of all trusted CA certificates


#✅ #verify the jenins container inside
$ openssl x509 -in tuleap.crt -text  #This should display the details of the Tuleap certificate.

/etc/ssl/certs is a directory on a Linux system where SSL/TLS certificates are stored.

This directory typically contains:

1. CA certificates: Trusted Certificate Authority (CA) certificates used to verify the identity of servers and clients.
2. Server certificates: Certificates used by servers to establish secure connections (e.g., HTTPS).
3. Client certificates: Certificates used by clients to authenticate with servers.


#✅ Check Java Truststore (cacerts) for Your CA
$ keytool -list -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit | grep tuleap




#explain
# Update CA certificates on Jenkins server
update-ca-certificates---------------------------1

This command:

Scans /usr/local/share/ca-certificates/ and /etc/ssl/certs/

Appends valid .crt files to /etc/ssl/certs/ca-certificates.crt

✅ Makes Tuleap's cert trusted by system tools like curl

$ openssl x509 -in /etc/ssl/certs/tuleap.crt -text



#Java Truststore Update (Used by Jenkins itself)-------------------2
# Import Tuleap's CA cert into Jenkins Java truststore
keytool -import -noprompt -trustcacerts -alias tuleap \
  -keystore /opt/java/openjdk/lib/security/cacerts \
  -file /etc/ssl/certs/tuleap.crt \
  -storepass changeit

--Imports the tuleap.crt file into Java's trusted CA store (cacerts).
--This is needed because Jenkins is a Java application, and Java uses its own truststore.

✅ Result: Jenkins can now safely communicate with Tuleap over HTTPS, even if Tuleap uses a self-signed/internal CA.

✅ Purpose:
To ensure that Java-based applications like Jenkins can trust the HTTPS certificate used by your Tuleap server — especially if Tuleap uses a self-signed or internal CA cert.


# Start Jenkins--------------------------3
exec /usr/local/bin/jenkins.sh

This starts Jenkins after:

--System trust (update-ca-certificates)

--Java trust (keytool -import)

#This starts Jenkins after both trust updates — ensuring Jenkins plugins and webhooks can connect to Tuleap securely.

🔁 Summary Workflow Diagram

Host:                             Jenkins Container:
-----                             ------------------

tuleap.crt  ─────────────┐
                         │   Docker volume mount
                         ▼
                   /etc/ssl/certs/tuleap.crt

                       entrypoint.sh runs:
                       ┌────────────────────────────┐
                       │ update-ca-certificates     │  → Linux system trusts Tuleap CA
                       │ keytool -import ...        │  → Java (Jenkins) trusts Tuleap CA
                       │ exec jenkins.sh            │  → Jenkins starts
                       └────────────────────────────┘


#🔐 Why Needed?
Java (and Jenkins) do not use Linux’s /etc/ssl/certs trust by default.
They have their own truststore (cacerts).
Without importing the Tuleap cert here, Jenkins will fail to connect with HTTPS errors like:
----PKIX path building failed: unable to find valid certification path

-----------------------------------------------------------------------------------
| Trust Location                  | Used by                                       |
| ------------------------------- | --------------------------------------------- |
| `/etc/ssl/certs`                | Linux system utilities (like curl, apt, etc.) |
| `/opt/java/openjdk/.../cacerts` | Java applications (like Jenkins)              |
-----------------------------------------------------------------------------------

Tuleap is running with HTTPS, using its own SSL certificate (likely self-signed or signed by a custom internal CA).

Jenkins needs to communicate with Tuleap (for webhook triggers, project integration, etc.).

Since Tuleap uses a certificate not issued by a public CA, Jenkins doesn’t trust it by default.

To fix that, you mount Tuleap's certificate into Jenkins and then add it to the trusted certificate store inside Jenkins, so HTTPS communication doesn't fail.









#jenkins CA(jenkins-ca.crt)----------2


| File                         | Purpose                                                                          |
| ---------------------------- | -------------------------------------------------------------------------------- |
| `jenkins-ca.crt`             | CA cert that signed Jenkins’s server certificate                                 |
| Use on other systems         | So they trust Jenkins’s HTTPS (e.g., Tuleap, browser, curl)                      |
| Use inside Jenkins container | Only if Jenkins needs to trust this CA too (mount it + `update-ca-certificates`) |


| Use of `jenkins-ca.crt`                              | Required?  |
| ---------------------------------------------------- | ---------  |
| Inside Jenkins container                             | ❌ No      |
| On Tuleap (to trust Jenkins)                         | ✅ Yes     |
| On any machine using curl/wget to call Jenkins HTTPS | ✅ Yes     |


#host machine
#/usr/local/share/ca-certificates/jenkins-ca.crt

The host system trust the Jenkins server’s certificate, which is the right step for trusting self-signed/internal Jenkins HTTPS certs.


#sudo update-ca-certificates
👉 It adds the CA certificate to the system’s trusted CA bundle (typically /etc/ssl/certs/ca-certificates.crt on Ubuntu).



#🔒 Result:
Now the host system will:

✅ Trust Jenkins when accessed via curl https://jenkins.isrd.cair.drdo or browser

✅ Not throw “insecure” or “untrusted certificate” warnings

✅ Allow Tuleap (if running on the host or trusting the same CA) to securely connect to Jenkins over HTTPS


| Location                                          | Purpose                                              | Needed?                  |
| ------------------------------------------------- | ---------------------------------------------------- | -----------------------  |
| `/usr/local/share/ca-certificates/jenkins-ca.crt` | Trusted CA on **host**                               | ✅ Yes, to trust Jenkins |
| Inside Jenkins container                          | Jenkins does **not** need to trust its own cert      | ❌ Not needed            |
| Inside Tuleap container                           | To trust Jenkins HTTPS (add to truststore or system) | ✅ Yes                   |















#- JENKINS_OPTS=--httpPort=8080 --httpsPort=-1  # NGINX handles SSL-------3

✅ --httpPort=8080
Jenkins will listen on HTTP port 8080 inside the container.

NGINX will proxy incoming HTTPS traffic (from port 443) to this HTTP port.


✅ --httpsPort=-1
This tells Jenkins to disable its internal HTTPS server.

-1 is a special value that means "don't enable HTTPS at all".

Why? Because you're already handling SSL via NGINX reverse proxy — there’s no need for Jenkins to duplicate it.


| Option            | Value                                                  | Meaning |
| ----------------- | ------------------------------------------------------ | ------- |
| `--httpPort=8080` | Jenkins listens on HTTP port 8080                      |         |
| `--httpsPort=-1`  | Jenkins disables HTTPS (because NGINX does it instead) |         |









#🔹 For the NGINX container------------4
This block is for the reverse proxy in front of Jenkins, which handles HTTPS:
volumes:
  - /srv/jenkins/jenkins-ssl-setup/nginx/jenkins.conf:/etc/nginx/conf.d/default.conf
  - /srv/jenkins/jenkins-ssl-setup/certs:/etc/nginx/certs



| Host Path                                           | Container Path                   | Purpose                                                                                                |
| --------------------------------------------------- | -------------------------------- | ---------------------------------------------------
| `/srv/jenkins/jenkins-ssl-setup/nginx/jenkins.conf` | `/etc/nginx/conf.d/default.conf` | ✅ NGINX config that enables HTTPS and reverse proxies to Jenkins 

| `/srv/jenkins/jenkins-ssl-setup/certs`              | `/etc/nginx/certs`               | ✅ Stores the TLS certificate and private key (like `jenkins.crt.pem`, `jenkins.key.pem`) used by NGINX |




| Container   | Purpose                                                            | Volumes Used                                                                                          |
| ----------- | ------------------------------------------------------------------ | ------------------------------------------------------
| **Jenkins** | - Runs Jenkins<br>- Trusts Tuleap CA<br>- Starts via custom script | - `tuleap.crt` → for trusting Tuleap<br>- `entrypoint.sh` → imports Tuleap CA<br>- `certs` (optional) 


| **NGINX**   | - Acts as HTTPS reverse proxy to Jenkins                           | - `jenkins.conf` for config<br>- `certs` for SSL cert and key                                         |


#🧩 What it does:
Tells NGINX to listen on port 443 (HTTPS)

Configures the SSL certificate and key path

Proxies incoming HTTPS requests to Jenkins (e.g., at http://jenkins:8080)











#manually
In /etc/environment, add or verify:
NO_PROXY=jenkins.isrd.cair.drdo,localhost,127.0.0.1
source /etc/environment

# Copy Jenkins CA to trusted CA directory
docker cp /etc/pki/tls/certs/jenkins-ca.crt /etc/pki/ca-trust/source/anchors/

# Update CA trust store
update-ca-trust extract


cd /srv/jenkins
docker compose down
docker compose up -d






#Check with curl inside Jenkins container

#jenkins
curl -v https://jenkins.isrd.cair.drdo

1.       - /srv/jenkins/jenkins-ssl-setup/ca-certificates/jenkins-ca.crt:/etc/ssl/certs/jenkins-ca.crt

2.     extra_hosts:
      - "jenkins.isrd.cair.drdo:172.18.0.3"

3.     entrypoint: /entrypoint.sh

4. 

#entrypoint.sh 

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


5. 
cd /srv/jenkins
docker compose down
docker compose up -d

6. 
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/jenkins-ca.crt

7. curl -v https://jenkins.isrd.cair.drdo


#tuleap
✅ Goal:
Add Tuleap (inside Docker) to trust Jenkins's HTTPS certificate issued by your internal CA.

1. sudo mkdir -p /srv/tuleap/tuleap-ssl-setup/ca-trust

2. services:
  tuleap:
    ...
    volumes:
      - /srv/tuleap/tuleap-ssl-setup/ca-trust/jenkins-ca.crt:/etc/pki/ca-trust/source/anchors/jenkins-ca.crt


3. - NO_PROXY=jenkins.isrd.cair.drdo,localhost,127.0.0.1

4. cd /srv/tuleap
docker compose down
docker compose up -d

5. docker exec -it tuleap bash
echo $NO_PROXY

6. curl -v https://tuleap.isrd.cair.drdo





#Find NGINX container's IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jenkins-nginx
docker exec -it jenkins bash
echo "172.18.0.3 jenkins.isrd.cair.drdo" >> /etc/hosts



-----------------------------------------------------------------------------------------------------------------------------------------------
#🎯 GOAL(MAIL)-----5

					   **Offline Jenkins + Zentyal mail system over LAN**
					   

Make Jenkins send build email notifications (success/failure) using Zentyal as the SMTP server — fully offline within LAN.
➡️ Jenkins sends job result notifications via Zentyal Mail Server
➡️ All communication is offline (LAN only)
✅ Email Sender & Receiver in Jenkins + Zentyal Setup



#🔧 Zentyal Mail Server Setup (Receiver + SMTP Server)
🧱 STEP 1 Go to:

Dashboard → Module Status
| Module           | Purpose                         |
| ---------------- | ------------------------------- |
| Mail             | SMTP (Postfix) + IMAP (Dovecot) |
| Mail Filter      | Optional, for spam checking     |
| Users and Groups | To create mail users            |
| DNS              | (Optional, useful in LAN)       |


📧 STEP 2: Configure Mail Domain

Mail → Virtual Domains → Add

| Field       | Value         |
| ----------- | ------------- |
| Domain name | `zentyal.lan` |

✅ Save.

👤 STEP 3: Create Users (Sender & Receiver)

 Users and Computers → Users → Add
 
 | Field    | Value                          |
| -------- | ------------------------------  |
| Username | `jenkins`                       |
| Password | `jenkins@123`                   |
| Email    | Auto → `jenkins@zentyal.lan` ✅ 


➤ Create Receiver (Admin)
| Field    | Value                             |
| -------- | --------------------------------- |
| Username | `isrd-admin`                      |
| Password | `caiar@123`                       |
| Email    | Auto → `isrd-admin@zentyal.lan` ✅ 

✅ Both users must be enabled and active in Zentyal.



✉️ STEP 4: (Optional) Enable Webmail (SOGo) to View Mail
Go to Software → Components

Install: Webmail (SOGo)

Access it: https://<zentyal-ip>/SOGo

Login as: isrd-admin / caiar@123



#⚙️ Jenkins Configuration (Sender)

Manage Jenkins → Manage Users → Click isrd-admin → Configure
🧾 Field: E-mail address
| **Field**          | **Value to Enter**         |
| ------------------ | -------------------------- |
| **E-mail address** | `isrd-admin@zentyal.lan` ✅ |





🧩 STEP 1: Install Email Plugins

Go to:
Manage Jenkins → Plugin Manager → Available

Search and install:

---Email Extension Plugin

---Mailer Plugin


Restart Jenkins if needed.


#📬 STEP 2: Configure Global SMTP Settings

 Manage Jenkins → Configure System

#🔹 Section: E-mail Notification (from Mailer Plugin)-------1

| Field                     | Value                          |
| ------------------------- | ------------------------------ |
| SMTP server               | `zentyal.lan` or `192.168.3.3` |
| Default user email suffix | `@zentyal.lan`                 |
| Use SMTP Auth             | ✅ Yes                         |
| SMTP Username             | `jenkins@zentyal.lan`          |
| SMTP Password             | `jenkins@123`                  |
| Use SSL                   | ❌ No                          |
| Use TLS                   | ✅ Yes                         |
| SMTP Port                 | `25`                           |
| Reply-To Address          | `jenkins@zentyal.lan`          |


✅ Click "Test configuration by sending test e-mail"

    To: isrd-admin@zentyal.lan

✅ Should succeed



#🔹 Section: Extended E-mail Notification (from Email Extension Plugin)-----2

| **Field**         | **What to Enter**                                                                   |
| ----------------- | ----------------------------------------------------------------------------------- |
| **SMTP server**   | `zentyal.lan` or `192.168.3.3` (Zentyal’s IP/hostname)                              |
| **SMTP Port**     | `25`                                                                                |
| **Credentials**   | Create if needed:<br>`Username`: `jenkins@zentyal.lan`<br>`Password`: `jenkins@123` |
| **Use SSL**       | ❌ **Unchecked**                                                                     |
| **Use TLS**       | ✅ **Checked** (STARTTLS)                                                            |
| **Use OAuth 2.0** | ❌ **Unchecked**                                                                     |



#💡 Advanced Email Properties
| **Field**                     | **What to Enter**                    |
| ----------------------------- | ------------------------------------ |
| **Default user email suffix** | `@zentyal.lan`                       |
| **Charset**                   | `UTF-8`                              |
| **Additional accounts**       | Leave blank                          |
| **Default Content Type**      | `text/plain` or `text/html`          |
| **List ID**                   | Leave blank                          |
| **Add 'Precedence: bulk'**    | ✅ Checked (optional but recommended) |


#📬 Routing & Filtering

| **Field**                               | **What to Enter**                                  |
| --------------------------------------- | -------------------------------------------------- |
| **Default Recipients**                  | `isrd-admin@zentyal.lan` (or another Zentyal user) |
| **Reply-To List**                       | `jenkins@zentyal.lan`                              |
| **Emergency reroute**                   | Leave blank                                        |
| **Allowed Domains**                     | `zentyal.lan`                                      |
| **Excluded Recipients**                 | Leave blank                                        |
| **Allow sending to unregistered users** | ✅ Checked (helpful in LAN)                         |


#📧 Email Content

| **Field**                   | **What to Enter**                                               |
| --------------------------- | --------------------------------------------------------------- |
| **Default Subject**         | `$PROJECT_NAME - Build #$BUILD_NUMBER - $BUILD_STATUS`          |
| **Maximum Attachment Size** | `10` (in MB, or leave blank)                                    |
| **Default Content**         | <pre>\$PROJECT\_NAME - Build #\$BUILD\_NUMBER - \$BUILD\_STATUS |






#✅ Absolute Minimum to Work (Quick View)

| Field                     | Example                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------ |
| SMTP server               | `192.168.3.3`                                                                              |
| SMTP port                 | `25`                                                                                       |
| Credentials               | `jenkins@zentyal.lan` / `jenkins@123`                                                      |
| Use TLS                   | ✅ Yes                                                                                      |
| Default user email suffix | `@zentyal.lan`                                                                             |
| Default Recipients        | `isrd-admin@zentyal.lan`                                                                   |
| Default Subject           | `$PROJECT_NAME - Build #$BUILD_NUMBER - $BUILD_STATUS`                                     |
| Default Content           | `$PROJECT_NAME - Build #$BUILD_NUMBER - $BUILD_STATUS\nCheck console output at $BUILD_URL` |




============================================================================================================================================
 								**Recap**



#🔧 ZENTYAL SIDE:----------------------6

✅ Modules Enabled:

    Mail

    Users and Groups

    Mail Filter

    DNS (optional)

✅ Domain:

    zentyal.lan
    
    
✅ Users:
  
| Username     | Password      | Email Address              |
| ------------ | ------------- | -------------------------- |
| `jenkins`    | `jenkins@123` | `jenkins@zentyal.lan` ✅    |
| `isrd-admin` | `caiar@123`   | `isrd-admin@zentyal.lan` ✅ |

✅ Optional Webmail (SOGo):
Can view inbox via https://<zentyal-ip>/SOGo









#⚙️ JENKINS SIDE:----------------2

✅ Plugins Installed:

    Mailer Plugin

    Email Extension Plugin


#✅ Global SMTP Setup in two places:


#🔹 1. Mailer Plugin Section-----1

| Field          | Value                          |
| -------------- | ------------------------------ |
| SMTP Server    | `zentyal.lan` or `192.168.3.3` |
| SMTP Port      | `25`                           |
| Use TLS        | ✅ Yes                          |
| Use SSL        | ❌ No                           |
| SMTP Auth      | ✅ Yes                          |
| Username       | `jenkins@zentyal.lan`          |
| Password       | `jenkins@123`                  |
| Reply-To       | `jenkins@zentyal.lan`          |
| Default Suffix | `@zentyal.lan`                 |

✅ Test mail → To: isrd-admin@zentyal.lan
✔️ Should succeed via LAN




#🔹 2. Extended E-mail Notification Section---2

| Field       | Value                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------ |
| SMTP Server | `192.168.3.3`                                                                              |
| Port        | `25`                                                                                       |
| Use TLS     | ✅ Yes                                                                                      |
| Use SSL     | ❌ No                                                                                       |
| Credentials | `jenkins@zentyal.lan / jenkins@123` ✅                                                      |
| Recipients  | `isrd-admin@zentyal.lan`                                                                   |
| Subject     | `$PROJECT_NAME - Build #$BUILD_NUMBER - $BUILD_STATUS`                                     |
| Content     | `$PROJECT_NAME - Build #$BUILD_NUMBER - $BUILD_STATUS\nCheck console output at $BUILD_URL` |



| Role              | Email Address            | Purpose                    |
| ----------------- | ------------------------ | -------------------------- |
| **Sender (SMTP)** | `jenkins@zentyal.lan`    | Authenticates with Zentyal |
| **Receiver**      | `isrd-admin@zentyal.lan` | Gets Jenkins job results   |



====================================================================================================================================


🚀 Next Step (Optional): Test Email via Jenkins Job

Create Freestyle job

Add "Editable Email Notification" in Post-Build Actions

Set:

    Recipients: isrd-admin@zentyal.lan

    Triggers: Success/Failure

Run job

Confirm email in SOGo or mail client (LAN)


| Field                  | Value                                                                                      |
| ---------------------- | ------------------------------------------------------------------------------------------ |
| Project Recipient List | `isrd-admin@zentyal.lan`                                                                   |
| Project Reply-To List  | `jenkins@zentyal.lan`                                                                      |
| Content Type           | `text/plain`                                                                               |
| Default Subject        | `$PROJECT_NAME - Build #$BUILD_NUMBER - $BUILD_STATUS`                                     |
| Default Content        | `$PROJECT_NAME - Build #$BUILD_NUMBER - $BUILD_STATUS\nCheck console output at $BUILD_URL` |
| Attach Build Log       | ✅ (optional)                                                                              



















==============================================================================================================================================================================

							cair-keys-jenkins-----7



~/keys/
├── CA-key-and-cert/
│   ├── ca-cert.crt          # Your CA's public certificate
│   └── ca-public-key.pem    # Your CA's public key (likely same as cert)
└── keys-and-cert-jenkins.isrd.cair.drdo/
    ├── jenkins.isrd.cair.drdo-cert.crt      # Jenkins server certificate
    ├── jenkins.isrd.cair.drdo-private-key.pem  # Jenkins private key
    ├── jenkins.isrd.cair.drdo-public-key.pem   # Jenkins public key
    └── jenkins.isrd.cair.drdo.p12             # PKCS12 bundle


jenkins.isrd.cair.drdo-cert.crt — Jenkins SSL certificate

jenkins.isrd.cair.drdo.p12 — PKCS#12 format certificate bundle (this likely contains your certificate and key)

jenkins.isrd.cair.drdo-private-key.pem — Jenkins private key

jenkins.isrd.cair.drdo-public-key.pem — Public key (usually not needed unless you’re sharing or verifying)


#1. Verify Certificate & Private Key Match
# Check if certificate and private key modulus match (should return SAME hash)
openssl x509 -noout -modulus -in jenkins.isrd.cair.drdo-cert.crt | openssl md5
openssl rsa -noout -modulus -in jenkins.isrd.cair.drdo-private-key.pem | openssl md5


#2. Validate Certificate Chain

# Verify the certificate is signed by your CA
openssl verify -CAfile ../CA-key-and-cert/ca-cert.crt jenkins.isrd.cair.drdo-cert.crt


#3. Inspect Certificate Details
# Show full certificate info (validity, subject, issuer, extensions)
openssl x509 -in jenkins.isrd.cair.drdo-cert.crt -text -noout

# Check Subject Alternative Names (SANs)
openssl x509 -in jenkins.isrd.cair.drdo-cert.crt -text -noout | grep -A1 "Subject Alternative Name"




#4. Verify Private Key Integrity

# Check if private key is valid (no output = good)
openssl rsa -in jenkins.isrd.cair.drdo-private-key.pem -check -noout


#5. Test PKCS12 File (Keystore)
# Verify PKCS12 file integrity (replace password)
openssl pkcs12 -info -in jenkins.isrd.cair.drdo.p12 -nodes -passin pass:yourpassword


#7. Verify Public Key Match

# Compare public key from cert vs. private key
openssl x509 -in jenkins.isrd.cair.drdo-cert.crt -pubkey -noout | openssl md5
openssl rsa -in jenkins.isrd.cair.drdo-private-key.pem -pubout | openssl md5


#8. Check Certificate Expiry

# Show expiry date
openssl x509 -in jenkins.isrd.cair.drdo-cert.crt -noout -enddate













sudo mkdir -p /srv/jenkins/jenkins-ssl-setup/{certs,nginx}

# Copy CA certificate
sudo cp ~/keys/CA-key-and-cert/ca-cert.crt /srv/jenkins/jenkins-ssl-setup/certs/internal-ca.crt.pem

# Copy Jenkins certificates
sudo cp ~/keys/keys-and-cert-jenkins.isrd.cair.drdo/jenkins.isrd.cair.drdo-cert.crt /srv/jenkins/jenkins-ssl-setup/certs/jenkins.crt.pem
sudo cp ~/keys/keys-and-cert-jenkins.isrd.cair.drdo/jenkins.isrd.cair.drdo-private-key.pem /srv/jenkins/jenkins-ssl-setup/certs/jenkins.key.pem
sudo cp ~/keys/keys-and-cert-jenkins.isrd.cair.drdo/jenkins.isrd.cair.drdo.p12 /srv/jenkins/jenkins-ssl-setup/certs/jenkins.p12




sudo chmod 644 /srv/jenkins/jenkins-ssl-setup/certs/*.crt.pem
sudo chmod 600 /srv/jenkins/jenkins-ssl-setup/certs/*.key.pem

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
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name jenkins.isrd.cair.drdo;
    return 301 https://$host:8443$request_uri;
}




version: '3'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: unless-stopped
    volumes:
      - jenkins_home:/var/jenkins_home
      - /srv/jenkins/jenkins-ssl-setup/certs/jenkins.p12:/etc/jenkins/ssl/jenkins.p12
      - /srv/jenkins/jenkins-ssl-setup/certs/internal-ca.crt.pem:/etc/ssl/certs/internal-ca.crt.pem
    environment:
      - JENKINS_OPTS="--httpPort=-1 --httpsPort=8080 --httpsKeyStore=/etc/jenkins/ssl/jenkins.p12 --httpsKeyStorePassword=cair123"
    networks:
      - jenkins-net

  nginx:
    image: nginx:latest
    container_name: jenkins-nginx
    restart: unless-stopped
    ports:
      - "8443:8443"
      - "80:80"
    volumes:
      - /srv/jenkins/jenkins-ssl-setup/nginx/jenkins.conf:/etc/nginx/conf.d/default.conf
      - /srv/jenkins/jenkins-ssl-setup/certs:/etc/nginx/certs
    networks:
      - jenkins-net

networks:
  jenkins-net:
    driver: bridge

volumes:
  jenkins_home:
  
  
  cd /srv/jenkins
docker-compose up -d



curl -vk --cacert /srv/jenkins/jenkins-ssl-setup/certs/internal-ca.crt.pem https://jenkins.isrd.cair.drdo:8443

openssl s_client -connect jenkins.isrd.cair.drdo:8443 -showcerts -CAfile /srv/jenkins/jenkins-ssl-setup/certs/internal-ca.crt.pem


=========================================================================================================================================================

✅ Goal
After every Jenkins pipeline run, send a success/failure email using Zentyal Mail Server.
💡 This works fully offline over LAN, no internet required

#🧠 Conceptual Flow Diagram

[Jenkins (Docker) on S2]
       |
       |  SMTP Email via LAN
       v
[Zentyal Mail Server (VirtualBox) on S1]
       |
       v
[isrd-admin@isrd.cair.drdo] — Receives Jenkins build notifications


| Server | Role                                                   | OS/Platform        |
| ------ | ------------------------------------------------------ | ------------------ |
| **S1** | Zentyal Mail Server (Postfix + Dovecot + Webmail/SOGo) | VirtualBox Ubuntu  |
| **S2** | Jenkins (CI Server, Dockerized)                        | Ubuntu with Docker |

#This must be a real mail user in Zentyal, and it should match the authenticated SMTP account.


[Jenkins job runs] ──▶ Send mail using:
   FROM: jenkins@zentyal.lan
     TO: isrd-admin@zentyal.lan
         |
         └─🧾 Receiver mailbox (on Zentyal, viewable via SOGo or IMAP client)






--------------------------------------------------------------------------------------------------------------------------------------------------
						#Zentyal Mail Server Configuration (S1)
				Sending Jenkins email notifications via a Zentyal mail server over LAN


#✅ OVERALL ARCHITECTURE

+------------------+                         +----------------------------+
| Server 2 (Host)  |                         | Server 1 (Host)            |
| Ubuntu (Base OS) |                         | Ubuntu (Base OS)           |
| └── Docker Engine|                         | └── VirtualBox             |
|     └─ Jenkins   |                         |     └─ Zentyal Mail Server |
|     └─ NGINX     |                         |        (SMTP+IMAP)         |
+------------------+                         +----------------------------+
        |                                                  ^
        |     LAN Network (192.168.3.0/24)                 |
        |                                                  |
        +--------------------------------------------------+


#✅ Updated Network Layout (Your LAN)

--------------------------------------------------------------------------------
| Component             | IP Address    | Role                                 |
| --------------------- | ------------- | ------------------------------------ |
| **Server 1 (Ubuntu)** | `192.168.3.1` | Runs **Tuleap** (in Docker)          |
| **Zentyal (VM)**      | `192.168.3.2` | Runs **Mail Server** (SMTP/IMAP)     |
| **Server 2 (Ubuntu)** | `192.168.3.3` | Runs **Jenkins + NGINX** (in Docker) |
--------------------------------------------------------------------------------


#✅ How Jenkins (Docker on Server2) Talks to Zentyal (192.168.3.2)
🔗 Flow of Email from Jenkins to Zentyal:

[Jenkins Docker container]
        │
        ▼
[Docker Bridge Network]
        │
        ▼
[Server2 Host Network: 192.168.3.3]
        │
        ▼
[LAN switch/router]
        │
        ▼
[Zentyal at 192.168.3.2 (SMTP)]


#✅ Required Setup for This to Work
🔧 On Zentyal (192.168.3.2):
Virtual domain: isrd.cair.drdo

Users: jenkins, isrd-admin

Enable services:

✅ SMTP

✅ IMAP

✅ SMTP authentication

✅ TLS optional


#🧪 On Server2 (192.168.3.3, Jenkins host)
From inside Jenkins container, test access to Zentyal:

docker exec -it jenkins ping 192.168.3.2
docker exec -it jenkins telnet 192.168.3.2 25


#✅ Jenkins Configuration (GUI):
In Jenkins → Manage Jenkins → Configure System → Extended Email Notification:

| Setting                  | Value                    |
| ------------------------ | ------------------------ |
| SMTP server              | `192.168.3.2`            |
| SMTP port                | `25`                     |
| Use SMTP authentication? | ✅ Yes                  |
| Username                 | `jenkins@isrd.cair.drdo` |
| Password                 | `cair@123`               |
| Use SSL                  | ❌ No                    |
| Use TLS                  | ✅ Yes                   |
| Default domain suffix    | `@isrd.cair.drdo`        |
| System admin email       | `jenkins@isrd.cair.drdo` |

#✅ Optional: Resolve by hostname (zentyal.isrd.cair.drdo)
If you want Jenkins to connect using zentyal.isrd.cair.drdo instead of 192.168.3.2:

In docker-compose.yml for Jenkins:
extra_hosts:
  - "zentyal.isrd.cair.drdo:192.168.3.2"


#🧪 Final Test Scenario
--From Jenkins GUI:

--Send a test mail from jenkins@isrd.cair.drdo

--To: isrd-admin@isrd.cair.drdo

--Zentyal will deliver to isrd-admin mailbox

--Login to: https://192.168.3.2/SOGo

Username: isrd-admin

Password: cair@123

✅ See the test email there


docker exec -it jenkins ping zentyal.isrd.cair.drdo



















#✅ HOW IT WORKS (Jenkins ➝ Zentyal Mail)
#1. Zentyal as External SMTP Server
Zentyal Mail Server acts like an external SMTP mail relay inside your LAN. It's not inside Docker, but that's perfectly fine — Docker containers can talk to outside systems via LAN.

Zentyal handles:

SMTP (Send mail)

IMAP (Read mail)

Authentication

TLS optional

Jenkins (inside Docker) will connect to Zentyal via IP 192.168.3.3:25 using STARTTLS + authentication.


#2. Jenkins Configuration Sends Emails via Zentyal
Jenkins inside Docker:

Uses Email Extension Plugin

Configured via:

SMTP server: 192.168.3.3

Port: 25

Auth: jenkins@isrd.cair.drdo / cair@123

TLS: ✅ Yes

SSL: ❌ No

Reply-to: jenkins@isrd.cair.drdo

Sends test email to: isrd-admin@isrd.cair.drdo

✅ This works because Jenkins container can reach Zentyal server on LAN directly.
[Jenkins Container] → [Docker Bridge Network] → [Host Network Interface] → [LAN] → [Zentyal at 192.168.3.3]



#3. Zentyal Receives Mail, Stores in Mailbox
Zentyal will deliver the email to the correct virtual domain mailbox (/var/vmail/...).

You can verify it by logging into SOGo Webmail 


#4.✅ docker-compose.yml — Do You Need to Modify?
✅ Only one line is needed inside the jenkins service to help with name resolution (optional if you're using IP directly):
extra_hosts:
  - "zentyal.isrd.cair.drdo:192.168.3.2"


#✅ Summary (Full Workflow)
---------------------------------------------------------------------------------------------------------------------
| Step | Action                                                                                                     |
| ---- | ---------------------------------------------------------------------------------------------------------- |
| 1️⃣  | Zentyal (in VirtualBox) is configured with domain `isrd.cair.drdo` and users like `jenkins`, `isrd-admin`. |
| 2️⃣  | Zentyal Mail → SMTP + IMAP enabled, TLS optional.                                                          |
| 3️⃣  | Jenkins container (on Ubuntu Server 2) connects via LAN to `192.168.3.3:25` with authentication.           |
| 4️⃣  | Jenkins sends test/build emails to `isrd-admin@isrd.cair.drdo`.                                            |
| 5️⃣  | Zentyal receives and stores mail in admin mailbox.                                                         |
| 6️⃣  | Admin verifies via SOGo or IMAP client.                                                                    |
--------------------------------------------------------------------------------------------------------------------







--------------------------------------------------------------------------------------------------------------------------------------------------
								#process
								 ZENTYAL

Navigate to Mail > Virtual Domains in the Zentyal interface
#Mail → Virtual Domains → Add
------------------------------------
| Field       | Value              |
| ----------- | ------------------ |
| Domain name | `isrd.cair.drdo` ✅|
------------------------------------

👉 This is the domain used for email addresses like jenkins@isrd.cair.drdo

✅ Click Add Domain


#Create Mail Users
You'll need two users: one for Jenkins to send from and another for the administrator to receive notifications.

#Create Users for Jenkins & Admin
Users and Computers → Users → Add

#➤ Create Jenkins Mail Sender:
--------------------------------------------------------
| Field    | Value                                     |
| -------- | ----------------------------------------- |
| Username | `jenkins`                                 |
| Password | `cair@123`                                |
| Email    | Will auto-become `jenkins@isrd.cair.drdo` |
--------------------------------------------------------

#➤ Create Admin Mail Receiver:
-----------------------------------------------------------
| Field    | Value                                        |
| -------- | -------------------------------------------- |
| Username | `isrd-admin`                                 |
| Password | `cair@123`                                  |
| Email    | Will auto-become `isrd-admin@isrd.cair.drdo` |
-----------------------------------------------------------

#Enable SMTP + IMAP in Mail Settings
Ensure your Zentyal server is set up to send and receive mail.

Go to Mail → General

✅ SMTP Service is enabled

✅ IMAP/POP3 Service is enabled

✅ Authentication is enabled for SMTP

✅ TLS is optional but recommended


#Access SOGo Webmail (Verification)

Go to: https://192.168.3.2/SOGo

Login as:

User: isrd-admin

Password: caiar@123

#✅ You should see the inbox of isrd-admin@isrd.cair.drdo




--------------------------------------------------------------------------------------------------------------------------------------------------
							#✅ Jenkins Configuration (S2)

Update docker-compose.yml
version: '3.8'
services:
  jenkins:
    # ... other Jenkins configurations ...
    extra_hosts:
      - "zentyal.isrd.cair.drdo:192.168.3.3" # Add this line
    # ... rest of your Jenkins service definition ...


#Configure Jenkins Mail from GUI
This is the crucial step to tell Jenkins how to connect to your Zentyal server.

Access your Jenkins dashboard.

🧩 STEP 1: Install Email Plugins

Go to:
Manage Jenkins → Plugin Manager → Available

Search and install:

---Email Extension Plugin

---Mailer Plugin


#Restart Jenkins if needed.


Navigate to Manage Jenkins > Configure System.

Scroll down to the Extended E-mail Notification section (or similar, depending on your email plugin). If you don't see this, you might need to install the Email Extension Plugin via Manage Jenkins > Plugins.

--SMTP server: 192.168.3.3 (Your Zentyal server's IP address)

--Default user e-mail suffix:  @isrd.cair.drdo

--Use SMTP Authentication?: ✅ Yes 

Username: jenkins@isrd.cair.drdo

Password: cair@123

--Use SSL: ❌ No (We are using TLS)

--Use TLS: ✅ Yes

--SMTP port: 25

--Reply-To Address: jenkins@isrd.cair.drdo (This is the email address that recipients will reply to if they hit "reply")

--Charset: UTF-8 (This is generally a good default)

#Test configuration by sending test e-mail
Recipient (for test email): isrd-admin@isrd.cair.drdo

Click the Test configuration button.


#Important: Click the Test Configuration button. Jenkins will attempt to send a test email.

------------------------------------------------------------------------------------------------------------------------------------------------
#JENKINS

1.  For https://jenkins.isrd.cair.drdo:8443/manage/configure (System Configuration):

# System Admin e-mail address: jenkins@isrd.cair.drdo

#note
This address is typically used as the "From" address for system-generated emails (like build notifications, if not overridden by the Extended E-mail Notification plugin) and as the return path for bounce messages. It represents Jenkins itself.



2. For https://jenkins.isrd.cair.drdo:8443/user/admin/account/ (Admin User's Profile Configuration):

# E-mail address: isrd-admin@isrd.cair.drdo

#note
This is the personal email address for the admin user in Jenkins. This is where notifications specifically directed to the Jenkins admin user (e.g., failed login attempts, critical system alerts, or specific job notifications configured to go to the build initiator) would be sent. Since isrd-admin is your designated receiver, this is the correct address for the admin user's profile.



--System-wide email (manage/configure): jenkins@isrd.cair.drdo

--Admin user's personal email (user/admin/account): isrd-admin@isrd.cair.drdo

--------------------------------------------------------------------------------------------------------------------------------------------------

#note
#Add in /etc/hosts of the Docker host
#Or use extra_hosts: in docker-compose.yml
extra_hosts:
  - "zentyal.isrd.cair.drdo:192.168.3.2"



----------------------------------------------------------------------------------------------------------------------------------------------
#✅ Minimal Setup for Testing Jenkins + Zentyal Email Flow
🖥️ Server 1 (Physical Host)
--OS: Ubuntu

Running:

--Docker

--Jenkins (Docker container)

--NGINX (Docker container)

--VirtualBox

--Zentyal (Mail server VM)



#[Jenkins (inside Docker)]
        │
     SMTP Email
        │
[Zentyal Mail Server (inside VirtualBox)]

--------------------------------------------------------------------------------------------------------------------------------------------------




























































------------------------------------------------------------------
#mail
✅ Before:
Mail sending done via Mailhog (Docker image)

Jenkins or Tuleap pointed to:
--MAILER_SMTP_HOST=mailhog
--MAILER_SMTP_PORT=1025

#✅ Now:
You're switching to a real mail server (Zentyal) installed on Server 1 (not in Docker)

Zentyal includes real SMTP (Postfix), real IMAP, and webmail (SOGo)

No image like Mailhog is needed anymore


#before
Forget .env + MAILER_SMTP_* for Jenkins
That .env was only useful for Mailhog. Zentyal is not a container, so:

✅ Remove all MAILER_SMTP_* env variables from docker-compose.yml

✅ Remove the mailhog service completely

You don’t set Zentyal mail config via environment variables. You do it inside Jenkins GUI.

-------------------------------------------------------------------------------------------------------


#🔧 Next Step: Configure Jenkins to Use This Mail Account
Manage Jenkins → Configure System

#Configure Jenkins Mail from GUI (Not docker-compose!)
| Field                   | Value                       |
| ----------------------- | --------------------------- |
| SMTP server             | `192.168.3.3` (Zentyal IP)  |
| SMTP port               | `25`                        |
| Use SSL                 | ❌ No                        |
| Use TLS                 | ✅ Yes                       |
| Use SMTP Authentication | ✅ Yes                       |
| Username                | `jenkins@isrd.cair.drdo`    |
| Password                | `cair@123`                  |
| Sender Email            | `jenkins@isrd.cair.drdo`    |
| Recipient (test)        | `isrd-admin@isrd.cair.drdo` |


In your docker-compose.yml, inside the Jenkins service, add:

    extra_hosts:
      - "zentyal.isrd.cair.drdo:192.168.3.3"

#Check Mail in Zentyal (SOGo)
On Server 1 (Zentyal):

Open browser:
https://192.168.3.3/SOGo

Login as: isrd-admin / caiar@123

✅ You should see the email sent from Jenkins!





























|

