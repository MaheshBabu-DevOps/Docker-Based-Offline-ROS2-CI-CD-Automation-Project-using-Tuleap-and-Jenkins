#Docker-frozen-process--Tuleap, mysql, redis, jenkins

#Information:

1. manifest.json     	#metadata for the web application
2. repositories 	    #image names, and tags
3. Dependencies		    # layer.tar, json, VERSION


#Commands:
$ tar -cvf tuleap-docker-image.tar  <manifest.json>  <repositories>  <dependencies>
$ docker load <tar file name>



#note
tar -cvf` is a command used in Unix-like operating systems, such as Linux and macOS. The command stands for "Tape ARchive

c--tar to create an archive. It initiates the archiving process.
v--tar verbose, meaning it will print out the names of each file as they are being added to the archive.
f--This option tells tar that a filename (or path) following this option is the name of the archive file where files should 
be stored.




#Process:


1. Jenkins:-

$ tar -cvf jenkins-docker-image.tar manifest.json repositories 2ccd0bb1d57d1e6fb3cd7d1ad7319f4e671208d1d862acfb293104439c899155 49812a884771fa33baaa1321b02772aca2f8dd5c05a00912e94f54ab168f698f 6177103f5c064ea17d06473c0cf23eaf483f67acb9cadb11829d786a2f57b5e5 64f6215ad3ffc5ca869af3d97d54bab6cf1a74c287e7d93fba753a08028604c5 6cfa08ca5551568f832df3e780541ad8a6376223b7242e5cd535a1c266a035df 93e105da7459d6b563cc100d5ddfe492f3bc0009bc2bd279354d2452b0998543 bb57e2ae959bd6f7693b91897c23d91af511b1c399bf305f5ff3f4777edfc155 c6441914d456d519d900f24ed684d7c549a669ae83fc5ab957ad9fc425a42ad3 c759a62509748e5231e4c4ad99bb49a6ff324153d2936256025f7a1b70bb6738 d8cb827680dac01e1cb4848f0a855f5d6d9ef37249d963f24525ea9dc85bc5ab e427369623521783fc7b00d3282d85e7f66044bdc9dd38b8a8b8d507ba2d6ec4 ebc211b0113703423a324ba6206b2b82a9cbbdb62402caf9d7cf7ffa8810c075 58550a76f7137eaa0e0e058be8f9ef2dc676b13ea4d1ad34b3bc62d808c3a235.json


$ docker load -i jenkins-docker-image.tar 


2. Redis:-

$ tar -cvf redis-docker-image.tar manifest.json  repositories 6c199afc1dae9c01ae5347c390d379912bb9d56ab37516ec8ad3fb6c4aebbbdd.json 176a2be404a17814ec80ffea1a4ff2cced1c735ad1d6692719049a79c1d46b97/ 1fd500df9d72e65d9e6644c5f581530b1172949e13b570133052a294df6607c0/ 2de0819047371e7f279fe4d32c8063e27b2ea3deb208ee7439f27f84c03fc739/ a782edea84cd3fcc6d3ec94c53fd879901c398c79ab5a434f848cb9771967f73/ aeee48faafefb1dccbe90c83eea6af242ae9d8fd33961bd82cb0623324c7bf05/ c97b9644bbfa48331cdbe39b28430bdc2a90f9b8a12f5b2813b8b2e42d5a2e6b/ d4d635ec7c0f6c51da19c7bff2b78a0254e0e6d2c2af9b1b2e344fd8f158f19c/ d9e2339e3f0581371e697af824e82a2f2c59c26cd1a935163f47c1b9245da436/

$ docker load -i redis-docker-image.tar 


3. Mysql:8.0:

$ tar -cvf mysql-docker-image.tar repositories  manifest.json  1ae74a5a05623fb6695604332d28fbd427235c39c995ecb990a0e8d5afea1f23/ 1d0890f470c1220372c7465c64a50e91d21068787c319b6bacfe996d45aaa60d/ 24ee77c9c1799ba08a3d686f04235f2cc881fea6d5c8cc8023e55c11f5787688/ 2b285da33d18ec6512575cd03871715a6068c76772c72695584fd395f8abeec0/ 47e0adb778451902ffd3c1ff2a03f9e1ce037b4980ec2d34899f4dfae2618182/ 6f6613a806887638e6c43e9d577079399a0d8a8e0de5464c1dc9ac1dbb2d4ad0/ 705a44248a869d3675a86bbf49d16944e3633e80d764903d714f67bab743204a/ 7cae3b6b3ff3c10e427ea69d92d32e69ed30981a8b8622484199b8575d1cdcf6/ a8043ace6e46d1d01a32a1f63485ef1910282b5f438b5310844a424e7b3203da/ dda85aec88321b11e0128f328d9553216a4c66471e549ee07535ffd26f1846a2/ f5bd4fdd9f74600bd47a07095ea868a3373a511227c7b6bce9579be7ab4089eb/ 6c55ddbef96911f9f36d1330ffe3f7557c019d49434e738cafabd1a3dd6b4bac.json

$ docker load -i mysql-docker-image.tar



4. Tuleap:

$ tar -cvf tuleap-docker-image.tar repositories  manifest.json  4ffb9e6f340d635b54d0f9a4e85f259f4e306dab75b17cceb895593c329a0a2f.json  9701a18fba36fbd76961dbbffa4c8fe574e3c6595aba3c9fdbc696ecd078d4b8/

$ docker load -i tuleap-docker-image.tar




#docker images list
$ docker images

jenkins/jenkins:lts-jdk17 
   
tuleap/tuleap-community-edition:latest 
       
mysql:8.0           

redis:latest       






#/data/DevOps-tools/Raygain/project/tuleap-setup
    ├── .env
    └── compose.yaml

         
#cretae .env file 
$ sudo nano .env

TULEAP_FQDN="tuleap.isrd.cair.drdo"
MYSQL_ROOT_PASSWORD="StrongRootPassword123"
TULEAP_SYS_DBPASSWD="TuleapDBPassword456"
SITE_ADMINISTRATOR_PASSWORD="AdminPassword789"
REDIS_PASSWORD="RedisSecurePassword321"









#create a docker-compose file for above images

version: '3.8'

services:
  tuleap:
    image: tuleap/tuleap-community-edition:latest
    hostname: ${TULEAP_FQDN}
    restart: always
    container_name: tuleap
    ports:
      - "80:80"
      - "443:443"
      - "22:22"
    volumes:
      - tuleap-data:/data
    depends_on:
      - db
      - redis
    environment:
      - TULEAP_FQDN=${TULEAP_FQDN}
      - TULEAP_SYS_DBHOST=db
      - TULEAP_SYS_DBPASSWD=${TULEAP_SYS_DBPASSWD}
      - SITE_ADMINISTRATOR_PASSWORD=${SITE_ADMINISTRATOR_PASSWORD}
      - DB_ADMIN_USER=root
      - DB_ADMIN_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - TULEAP_REDIS_HOST=redis
      - TULEAP_REDIS_PASSWORD=${REDIS_PASSWORD}
    networks:
      - shared-network

  db:
    image: mysql:8.0
    command: ["--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci", "--sql-mode=NO_ENGINE_SUBSTITUTION"]
    restart: always
    container_name: tuleap_db
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - shared-network

  redis:
    image: redis:latest
    restart: always
    container_name: tuleap_redis
    environment:
      - REDIS_PASSWORD=${REDIS_PASSWORD}
    volumes:
      - redis-data:/data
    networks:
      - shared-network

volumes:
  tuleap-data:
  db-data:
  redis-data:

networks:
  shared-network:
    driver: bridge


save and exit


#Theory
#Tuleap
1. bridge:
--Bridge Network: A virtual network that connects multiple containers, allowing them to communicate with each other.
--driver: bridge: Creates a virtual network bridge, allowing containers to communicate with each other.
--In Docker Compose, driver refers to the network driver that manages the network.
--shared-network is a more general term that refers to any network that is shared among multiple containers.


2. driver

In Docker, a "driver" refers to a built-in component that manages a specific aspect of containerization, such as:

- Network drivers (e.g., bridge, overlay)
- Volume drivers (e.g., local, nfs)







#maps hostnames to IP addresses
$ sudo nano /etc/hosts
127.0.0.1	tuleap.isrd.cair.drdo


$ docker-compose up -d


$ docker-compose logs -f tuleap
$ docker volume ls
$ docker network ls
$ docker network inspect <tuleap-setup_default>


#Intial password for tuleap 
AdminPassword789

#Browser access
https://tuleap.isrd.cair.drdo    (certificates is trust not secure browser)




#note
1.  Don't docker-compose down; it will be in a running state only for all containers





















#https secure padlock setup for tuleap on ubuntu host machine

sudo mkdir -p /etc/pki/CA
sudo touch /etc/pki/CA/index.txt
echo '1000' | sudo tee /etc/pki/CA/serial


#cd /data/server
mkdir server
cd server

openssl genrsa -out ca.key.pem 4096  
#ca.key.pem

openssl req -key ca.key.pem -new -x509 -days 7300 -extensions v3_ca -out ca.crt.pem
#ca.crt.pem


#Add certificates into a ubuntu CA location
#note remove old keys


sudo cp ca.crt.pem /usr/local/share/ca-certificates/my_ca.crt
cd /usr/local/share/ca-certificates/	



#Creating an SSL/TLS key
openssl genrsa -out server.key.pem 2048
#server.key.pem

#Creating an SSL/TLS certificate signing request
sudo cp /etc/ssl/openssl.cnf .
cd /data/server

sudo nano openssl.cnf  		#dir = /etc/pki/CA 


#generate a certificate signing request
openssl req -config openssl.cnf -key server.key.pem -new -out server.csr.pem
#server.csr.pem


#Creating the SSL/TLS certificate

sudo mkdir -p /etc/pki/CA/newcerts
sudo chmod 700 /etc/pki/CA/newcerts
sudo chown root:root /etc/pki/CA/newcerts


#create a certificate for undercloud
sudo openssl ca -config openssl.cnf -extensions v3_req -days 3650 -in server.csr.pem -out server.crt.pem -cert ca.crt.pem -keyfile ca.key.pem


#output keys
< ca.crt.pem  ca.key.pem  openssl.cnf  server.crt.pem  server.csr.pem  server.key.pem > 


/srv/tuleap/tuleap-ssl-setup/
└── certs
└── ca-trust
└── nginx


#create a directorys on ubuntu host machine
/data/DevOps-tools/Raygain/project/tuleap-setup
    ├── ca-trust
    └── certs
    └── nginx

$ sudo mkdir nginx certs ca-trust

sudo mkdir -p /srv/tuleap/tuleap-ssl-setup/{certs,ca-trust,nginx}
ls -l /srv/tuleap/tuleap-ssl-setup
certs/
ca-trust/
nginx/
openssl.cnf
server.crt.pem
server.csr.pem
server.key.pem
tuleap-ca.crt.pem
tuleap-ca.key.pem

#copy the all keys to cets location (host)
sudo cp /data/server/ca.crt.pem           /data/DevOps-tools/Raygain/project/tuleap-setup/certs
sudo cp /data/server/server.crt.pem       /data/DevOps-tools/Raygain/project/tuleap-setup/certs
sudo cp /data/server/server.key.pem       /data/DevOps-tools/Raygain/project/tuleap-setup/certs


#copy the CA & server.crt.pem key to ca-trust location (host)
sudo cp server.crt.pem  ca.crt.pem /data/DevOps-tools/Raygain/project/tuleap-setup/ca-trust


#cd certs
sudo nano undercloud.conf
undercloud_service_certificate = /etc/pki/undercloud-certs/undercloud.pem




#permissions(host)
sudo chown -R $USER:$USER $PWD/certs
sudo chmod -R 755 $PWD/certs
sudo chown -R $USER:$USER $PWD/ca-trust
sudo chmod -R 755 $PWD/ca-trust



#modify the tuleap docker-compose file(host)
/data/DevOps-tools/Raygain/project/tuleap-setup
├── docker-compose.yml

sudo nano docker-compose.yml
volumes:
      -  tuleap-data:/data
      - ./certs:/etc/pki/undercloud-certs
      - ./nginx:/etc/nginx/conf.d/
      - ./ca-trust:/etc/pki/ca-trust/source/anchors


#copy the nginx dir from container to (host)


sudo docker cp tuleap:/etc/nginx/conf.d/tuleap.conf	 /data/DevOps-tools/Raygain/project/tuleap-setup/nginx/


#modify tuleap.conf file on host machine

/data/DevOps-tools/Raygain/project/tuleap-setup/nginx
cd /data/DevOps-tools/Raygain/project/tuleap-setup/nginx

nano tuleap.conf

server {
        listen       443 ssl http2;
        listen       [::]:443 ssl http2;
        server_name  tuleap.isrd.cair.drdo;

replce ths
   ssl_certificate /etc/pki/tls/certs/localhost.cert.pem;
        ssl_certificate_key /etc/pki/tls/private/localhost.key.pem;
   
   
        ssl_certificate /etc/pki/undercloud-certs/server.crt.pem;
        ssl_certificate_key /etc/pki/undercloud-certs/server.key.pem;
        ssl_client_certificate  /etc/pki/undercloud-certs/ca.crt.pem;



#host
docker-compose up -d   #tuleap moby image is corruptred
docker-compose logs -f tuleap


#login the tuleap container (manual)-option
docker exec -it tuleap bash
sudo cp server.crt.pem  /etc/pki/ca-trust/source/anchors/
sudo cp ca.crt.pem  	/etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract
sudo update-ca-trust


#Restart nginx
nginx -t
nginx -s reload


#host
docker restart tuleap


#verify the ssl/tls certificates both host machine and tuleap container

openssl s_client -connect tuleap.isrd.cair.drdo:443 -servername tuleap.isrd.cair.drdo

or 
openssl s_client --connect  tuleap.isrd.cair.drdo:443


#host

#Add ca.crt.pem to firefox browser 
settings---certificates Manager--Authorities--import the ca.crt.pem key 


#webbrowser
https://tuleap.isrd.cair.drdo  (secure web site)

#credentials
admin
cair@123

[user]
mahesh
cair@123

















#jenkins(host machine)

/data/DevOps-tools/Raygain/project/jenkins-setup
    └── compose.yaml
 
       
#jenkins-compose file
sudo nano docker-compose.yml

version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts-jdk17
    hostname: jenkins.isrd.cair.drdo
    container_name: jenkins
    user: root
    ports:
      - "8080:8080"          # Jenkins web interface <host:container>
      - "50000:50000"        # Jenkins agent communication port	<host:container>
    volumes:
      - jenkins_home:/var/jenkins_home              #mounting docker volume to the /var/jenkins_home direct inside the jenkins container
      - /var/run/docker.sock:/var/run/docker.sock   #bind mounting container full access to the docker daemon (it allows applications to send> API requests to the docker daemon to manage containers, images, network, and volumes
      - /usr/bin/docker:/usr/bin/docker             #bind mounting running docker commands directly by mount into the container 
    environment:
      - JENKINS_HOME=/var/jenkins_home
    restart: always
    networks:
      - tuleap-setup_shared-network

volumes:
  jenkins_home:
#  driver: #local  #docker default using local driver the local driver is standard storage docker volumes on host machine(_data directory)

networks:
  tuleap-setup_shared-network:
    external: true




#maps hostnames to IP addresses
$ sudo nano /etc/hosts
127.0.0.1	jenkins.isrd.cair.drdo


$ docker-compose up -d

http://localhost:8080 or    http://jenkins.isrd.cair.drdo:8080


#Unlock Jenkins:
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword



#Copy Plugins into the Running Jenkins Container:
docker cp /data/DevOps-tools/Raygain/jenkins/jenkins_plugins/.  jenkins:/var/jenkins_home/plugins/

docker restart jenkins

#login tuleap container
docker exec -it jenkins bash
cd /var/jenkins_home/plugins
exit

#Browser access
http://localhost:8080  			#(By default http:8080 is the port number of jenkins) 


#verify the volume and network
docker network ls
docker network inspect <>
docker volume ls





















#http to https for jenkins setup on ubuntu host machine 

/data/DevOps-tools/Raygain/project/jenkins-setup
     └── ca-certificates (directory)
      └── entrypoint.sh (script-file)
       └──  tuleap.crt (file)
       └──  certs (directory)


#create a directories and fies
sudo mkdir ca-certificates  certs
sudo touch tuleap.crt  entrypoint.sh


#Go to ubuntu CA location and copy CA file
cd /usr/local/share/ca-certificates/
sudo cp my_ca.crt  /data/DevOps-tools/Raygain/project/jenkins-setup/ca-certificates




#Convert PEM files to PKCS12 Format
cd /data/DevOps-tools/Raygain/project/jenkins-setup/certs

#ca.crt.pem  ca.key.pem   openssl.cnf  server.crt.pem  server.csr.pem  server.key.pem  undercloud.conf

sudo openssl pkcs12 -export -in /data/DevOps-tools/Raygain/project/jenkins-setup/certs/server.crt.pem -inkey /data/DevOps-tools/Raygain/project/jenkins-setup/certs/server.key.pem -out /data/DevOps-tools/Raygain/project/jenkins-setup/certs/jenkins.p12 -name jenkins -CAfile //data/DevOps-tools/Raygain/project/jenkins-setup/certs/ca.crt.pem -caname root -password pass:cair123


#Convert PKCS12 to JKS Format:

sudo keytool -importkeystore -deststorepass cair123 -destkeypass cair123 -destkeystore /data/DevOps-tools/Raygain/project/jenkins-setup/certs/jenkins.jks -srckeystore /data/DevOps-tools/Raygain/project/jenkins-setup/certs/jenkins.p12 -srcstoretype PKCS12 -srcstorepass cair123 -alias jenkins


#permissions
sudo chown -R $USER:$USER $PWD/certs
sudo chmod -R 755 $PWD/certs


#output
#jenkins.jks  jenkins.p12



#entrypoint(host)

$ sudo nano entrypoint.sh 

#!/bin/bash

# Update CA certificates
update-ca-certificates

# Import Tuleap certificate into Java truststore
keytool -import -noprompt -trustcacerts -alias tuleap -keystore /opt/java/openjdk/lib/security/cacerts -file /etc/ssl/certs/tuleap.crt -storepass changeit

# Start Jenkins
exec /usr/local/bin/jenkins.sh


save and exit


$ sudo chmod +x jenkins.sh




#Tuleap container to host ubuntu

#network both side
1. login tuleap container
2. Run command openssl s_client -connect tuleap.isrd.cair.drdo:443 -showcerts
3. Save the Tuleap server's certificate (-----BEGIN CERTIFICATE-----  to -----END CERTIFICATE-----)
4. copy the certificate into a host location  


#cd jenkins-setup
#sudo nano tuleap.crt
paste here conternt ssl
(-----BEGIN CERTIFICATE-----  to -----END CERTIFICATE-----)





#Add jenkins.conf reverse proxy at tuleap nginx directory location 

/data/DevOps-tools/Raygain/project/tuleap-setup/nginx
 └── nginx
 
sudo nano jenkins.conf

server {
    listen 8443 ssl;
    server_name jenkins.isrd.cair.drdo;

    ssl_certificate /etc/pki/undercloud-certs/server.crt.pem;
    ssl_certificate_key /etc/pki/undercloud-certs/server.key.pem;
    ssl_client_certificate /etc/pki/undercloud-certs/ca.crt.pem;
   

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_redirect http://localhost:8080 https://jenkins.isrd.cair.drdo;
    }

    location /websocket {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

server {
    listen 80;
    server_name jenkins.isrd.cair.drdo;

    location / {
        return 301 https://$server_name$request_uri;
    }
}

 
 

#modify the jenkins docker-compose file

version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts-jdk17
    hostname: jenkins.isrd.cair.drdo
    container_name: jenkins
    user: root
    ports:
      - "8081:8080"
      - "8443:8443"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
      - ./certs/jenkins.jks:/var/jenkins_home/ssl/jenkins.jks
      - ./ca-certificates:/usr/local/share/ca-certificates
      - ./tuleap.crt:/etc/ssl/certs/tuleap.crt
      - ./entrypoint.sh:/entrypoint.sh
    entrypoint: ["/entrypoint.sh"]
    environment:
      - JENKINS_HOME=/var/jenkins_home
      - JENKINS_OPTS=--httpPort=-1 --httpsPort=8443 --httpsKeyStore=/var/jenkins_home/ssl/jenkins.jks --httpsKeyStorePassword=cair123
    networks:
      - tuleap-setup_shared-network

volumes:
  jenkins_home:

networks:
  tuleap-setup_shared-network:
    external: true

 
   
$ docker-compose up -d (jenkins)
 
$ docker-compose up -d (tuleap)
 

#Browser access
https://tuleap.isrd.cair.drdo:443 	(secure browser)
https://jenkins.isrd.cair.drdo:8443  	(secure browser)



#Logs 
docker compose logs -f tuleap
docker logs jenkins
 
 
#verify 
docker exec -it jenkins keytool -list -keystore  opt/java/openjdk/lib/security/cacerts -storepass changeit | grep tuleap


#Host and container verify 
openssl s_client --connect jenkins.isrd.cair.drdo:8443
openssl s_client --connect tuleap.isrd.cair.drdo:443


 
 
 
 
 
 
 
 



#jenkins
3. jenkins

--root-user: root - runs the container with root privileges (admin access)
--- Grant administrative access
- Allow the container to perform actions that require root privileges
- Enable the container to modify system files and settings
eg: jenkin-user
--limited access and permissions




4. Volumes
1. --jenkins_home:/var/jenkins_home:Maps Jenkins data to a persistent storage location, so data is retained even if the container is restarted or deleted.

2. --/var/run/docker.sock:is a Unix socket file that allows communication between the container and the Docker daemon on the host.
- 1. Docker CLI (command-line interface)
- 2. Docker daemon (the background process that manages containers)
../var/run/docker.sock:/var/run/docker.sock:Allows Jenkins to communicate with the Docker daemon, enabling Jenkins to build, run, and manage Docker containers.(- Build: Create Docker images, Run: Start Docker containers, Manage: Control and configure Docker containers(e.g., stop, restart, delete).
..Gives Jenkins permission to control Docker.
..It will work only for Docker commands.
- docker ps
- docker run
- docker build
- docker stop



3. /usr/bin/docker:/usr/bin/docker:Maps the Docker binary, enabling the container to run Docker commands.
1. Socket: Allows talking to the Docker daemon.
2. Binary: Provides the Docker command-line tool.( while the binary provides a direct command-line interface.)



examples-

Socket Examples

1. docker ps (lists running containers)
2. docker run -it ubuntu bash (runs a new container)
3. docker stop my-container (stops a running container)

Binary Examples

1. docker --version (displays Docker version)
2. docker info (displays Docker system information)
3. docker login (logs in to a Docker registry)





4.  ./certs/jenkins.jks:/var/jenkins_home/ssl/jenkins.jks: allows Jenkins to use a custom SSL/TLS certificate for secure connections.
..This line maps a local file (./certs/jenkins.jks) to a file inside the container (/var/jenkins_home/ssl/jenkins.jks).
..A Java keystore (JKS) file is a secure file format used to hold certificate information for Java applications.

--Purpose:
..jenkins uses this certificate to establish secure connections (HTTPS) between the Jenkins server and clients (e.g., web browsers, API clients).
..Location: /var/jenkins_home/ssl/jenkins.jks
- /var/jenkins_home is the default home directory for the Jenkins user in the Docker image.
- ssl is a subdirectory within the Jenkins home directory, where SSL/TLS certificates and keys are stored.
- jenkins.jks is the default filename for the Java Keystore file that stores the SSL/TLS certificate and private key.
- jenkins.jks:
1. Server Certificate (server.crt.pem): Jenkins' SSL/TLS certificate.
2. Private Key (server.key.pem): Private key associated with the server certificate.
3. CA Certificate (ca.crt.pem): Certificate Authority (CA) certificate that signed the server certificate.

These three certificates are now bundled together in the jenkins.jks file, ready for use with Jenkins!


After mapping:
1. Jenkins container starts: The Jenkins Docker container starts, and the mapped volume is mounted.
2. Jenkins configures SSL/TLS: Jenkins detects the jenkins.jks file in the /var/jenkins_home/ssl directory and uses it to configure SSL/TLS encryption.
3. Custom certificate is used: Jenkins uses the custom SSL/TLS certificate stored in the jenkins.jks file to establish secure connections (HTTPS) with clients.
4. Jenkins is accessible via HTTPS: You can now access the Jenkins web interface using HTTPS (e.g., (jenkins.isrd.caird.drdo)).
5. Mapping ./certs/jenkins.jks to /var/jenkins_home/ssl/jenkins.jks allows Jenkins to use a custom SSL/TLS certificate for secure connections.




5.   ./ca-certificates:/usr/local/share/ca-certificates: This maps a local directory (./ca-certificates) to a directory inside the container (/usr/local/share/ca-certificates).
Purpose:
--Updates the container's trusted Certificate Authorities (CAs) with custom certificates.
--It adds custom Certificate Authorities (CAs) to the container's trust store, so that Jenkins can trust and connect to other services that use those CAs.
- jenkins.jks is for Jenkins' own SSL/TLS certificate.
- ca-certificates is for trusting other services' SSL/TLS certificates.
- note:
--./ca-certificates:/usr/local/share/ca-certificates adds the CA certificate to the container's trust store.
--CA certificate file is actually named my_ca.crt, not ca.crt.pem.
So, the correct CA certificate being added to the container's trust store is indeed my_ca.crt.

- Finally, I define:
1. Mapping ./ca-certificates:/usr/local/share/ca-certificates adds the CA certificate (my_ca.crt) to the container's trust store, allowing it to trust the certificate chain and establish secure connections.

2. jenkins.jks contains Jenkins' SSL/TLS certificate and private key.



6.  ./tuleap.crt:/etc/ssl/certs/tuleap.crt: Maps the local tuleap.crt file to the container's /etc/ssl/certs/tuleap.crt location.

- Purpose:
Adds the Tuleap certificate to the container's trusted certificates store.

- Effect:
The container will trust the Tuleap certificate and establish secure connections.



7.  ./entrypoint.sh:/entrypoint.sh : 
host:
1. Updates CA certificates using update-ca-certificates.
2. Imports the Tuleap certificate into the Java truststore using keytool.
3. Starts Jenkins using exec /usr/local/bin/jenkins.sh.

composefile:
1. ./entrypoint.sh:/entrypoint.sh: Maps the local entrypoint.sh script to the container's /entrypoint.sh location.
2. entrypoint: ["/entrypoint.sh"]: Specifies that the container's entrypoint should be the /entrypoint.sh script.

#when the container starts, it will execute the entrypoint.sh script, which contains the commands to update CA certificates, import the Tuleap certificate, and start Jenkins.


8. tuleap-setup_shared-network: network is defined in the Jenkins Compose file, and its purpose is to enable communication between containers in the Jenkins setup.
--By connecting to this shared network, services in the Jenkins setup can communicate with each other, facilitating tasks like:

- Jenkins master-slave communication
- Service discovery
- Data exchange between services


9. networks:
  tuleap-setup_shared-network:
    external: true

purpose:
1.Networks Configuration

- networks: specifies the networks for the service
- tuleap-setup_shared-network: the name of the network
- external: true: indicates that the network is created and managed outside of this Docker Compose file

2.What it Means

- The service connects to the pre-existing tuleap-setup_shared-network network
- Docker Compose won't create the network; it assumes it already exists

3.Purpose

- Enables communication between services in the Jenkins setup
- Simplifies setup and management of the Jenkins environment







7. #jenkins.conf
Server Block 1
- Listens on port 80
- Redirects HTTP to HTTPS

Server Block 2
- Listens on port 8443 (HTTPS)
- Configures SSL/TLS certificates

SSL/TLS Configuration
- Specifies certificate, key, and client certificate locations

Proxy Configuration
- Proxies requests from Nginx to Jenkins on localhost:8083

WebSocket Configuration
- Configures WebSocket proxying for Jenkins












#sample demo project


#Git Installation:	#(host machine)
$ sudo apt-get install git
git --version

#user:
sudo git config --global user.name "mahesh"
sudo git config --global user.email "mahesh@example.com"
sudo git config --list

 
#Demo-project
mkdir my_project
cd my_project
git init
echo "Hello, Tuleap!" > README.md
git add README.md
git commit -m "Initial commit"
git remote add origin
git remote add origin 
$ git push -u origin master (https)
 


#pull request in tuleap:

1. create a one project in local machine  and push it into a tuleap (by default is master)
#commands
git init
git add	 <>
git commit -m ""
sudo git config --global user.name "mahesh"
sudo git config --global user.email "mahesh@example.com"
sudo git config --list
git remote add origin <tuleap project url>
git push -u origin master 



#new branch
1. create a one more branch in local host (git branch cair) and make changes and push it into a tuleap
2. create a pull request in tuleap (source to destination)cair-master 
3. after pr done  get the build notification from jenkins (job is failure or sucess) to tuleap
4. merge the cair branch to master
#merge in git  combine changes from one branch to another (code update, commit history, jenkins CI)
5. In local machine run below comamnds for merge the contents
#commands in local git
git checkout master
git branch or git branch -a
git pull origin
git log or git log --all




#method2(same content)
2. Again make changes in master branch and push it into a tuleap host (by default is master)
 
1. same in another branch same content and push it into a tuleap host
2. create a pull request in tuleap (source to destination)cair-master 
3. merge
4. git pull origin

 
 
 
#method3(different content)
 
Non fast-forward merge

Pull request destination has diverged. Merge will not resolve in a fast-forward. You can proceed with the merge, or cancel and update your pull request
 
#commands
git fetch origin
git merge origin/master
git push origin -f master
git merge origin/<target_branch>

 
 
 
 
###webhook--CI IN TULEAP-----------1

##tuleap proxy setup 
docker exec -it tuleap bash
#vi /etc/environment
NO_PROXY=jenkins.isrd.cair.drdo

# note (docker-compose down and up  also connection will happening)


#cd /etc/tuleap/conf
#vi local.inc
// set no proxy to excute jenkins
putenv('no_proxy=jenkins.isrd.cair.drdo');

//disable proxy settings for tuleap
$http_proxy = '';
$https_proxy = '';
$sys_proxy = '';


#host
export no_proxy="jenkins.isrd.cair.drdo,localhost.127.0.0.1"
git config --global --unset http.proxy
git config --global --unset https.proxy
export http_proxy=""
export https_proxy=""


#docker restart tuleap











..................................................................................................................................................s







 




#concept-1
##Jenkins Pipeline(Item section)

#Everthing is automated(Trigger)---Main

#Anyone can do anything(poll scm & CI-trigger ) & (Role based authenticaton process(poll scm only tirgger)  & poll scm with time



#method-1
1. ##Anyone can do anything(poll scm & CI-trigger )

Pollscm---enable in jenkins project
or
CI-enable in tuleap 

once push in local git it will trigger into a jenkins automatically by use ci or poll scm

eg:-

Project1-----enable poll scm in jenkins trigger
or
Project2-----enable ci in tuleap and add project url after triggger









#method-2-----(Role based authenticaton process(poll scm only tirgger)

##Jenkins Pipeline(Item section)

2. ##Role based authenticaton process(poll scm only tirgger)---Restricted  to users

#note
CI-not work


#User creation in jenkins master----------------1

1. create a new user(cair) in jenkins(master)

2. Verify the new user created or not  login and check (full access user)

3. Now! login jenkins master





##Token creation--------------2

Create one token in jenkins after add that token into a tulep project location----settins--git--jenkins--url and token(single token use can use multiple projects in tuleap and enable in jenkins project configure location poll scm after automatically trigger)

#Steps:-

1. In Jenkins go to 👉️Dashboard👉️Manage Jenkins👉️Plugins👉️installed👉️ "Role-based Authorization Strategy" After installed plugin go to "Security" section inside
2. Generate Git plugin notifyCommit access token
(add that token into a tuleap project locaton)

3. Authorization
enable Role based Role-based Strategy
4. CSRF Protection
disable
5. Git Hooks
allow both

save and exit


6. Now u wil get new option in security section "Manage and Assign Roles"


#note: By default master jenkins full access (Administer) dont change anything 

7. --Now, go inside Manage & Assign roles → Manage roles → Add roles
--Role Name: Devolper and save

Dashboard----Manage Jenkins---Manage and Assign Roles----Assign Roles
--Add User: mahesh



#Assign the rules----------------3
#Note: after add assign role only get the permissions to see dashboard in userside

#Global roles

1. Role:  

1. admin (By default)
2. Devolper(new role)

#--Developer

2. Overall							
 
Administer✅️(full access)✖️ (no access)		 		
Read ✅️(main)


3. Credentials

ALL ✅️
 
 
4. Gerrit
optional✖️

5. Agent

optional✖️

6. 7,8,9,10

Job		Run	     View	  SCM	        Metrics

ALL ✅️	       ALL ✅️        ALL ✅️       ALL ✅️        ALL ✅️ 
 




#project creation-----4

create one project in jenkins and enbale poll scm after in tuleap project location add jenkins url and token  save come to  local git push the code into a remote server tuleap it will trigger automtically

pollscm-----blank








#method-3-(poll scm with time)------ANYONE CAN DO ANYTHING AND ROLE BASED Strategy BOTH OPTIONS WILL WORK
##Jenkins Pipeline(Item section)

It is only works whenever the changes happened in “GIT” 
In jenkins project settings give poll scm option enable and  1 or 5 minutes build means → */1 * * * *


#note 
--This poll scm is based on time not immediatly trigger

--This poll scm will work only without CI option enable  and without poll scm time

---This will work only without CI AND POLL SCM TIMELESS 
 
 
 
 
 
 





#concept-2 
#Organization folder(single project multiple repo's or multi branches)---jenkins

ANYONE CAN DO ANYTHING--process

1. In tuleap single project inside multiple repo or repo inside muiltple branches will work in jenkins oragasation folder---(by default trigger)

eg:-  Project(gtest-demoapp)---Repos(ros2-gtest-cicd)-----branches(master, feauture1, feauture2)
		1			1			multi

eg:-  Project(gtest-demoapp)---Repos(ros2-gtest-cicd)-----branches(master, feauture1, feauture2)
		1			1,2,3			multi




 
 
 
#concept-3 (best)
#Multibranch Pipeline---(single repo use muiltple branches)-----(by default trigger)
ANYONE CAN DO ANYTHING--process


eg:- Repo(ros2-gtest-cicd)-----branches(master, feauture1, feauture2)
		1			multi
 
 
 
 
#note
Role-based Authorization Strategy

same this also same process but admin give the restricted to users to do operations 
 
 
 
 
 
 👉️Git server 👉️add or modifiy the file👉️commit👉️push into a tuleap server👉️jenkins will take automatically trigger no need manual process jenkins will take build, test, deploy the software code into a docker container!
 
 

 
 
 











