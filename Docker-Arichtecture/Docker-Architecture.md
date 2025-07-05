					  🧱 Real-World Docker Architecture on Linux (Ubuntu)
					
							

#LINUX
Linux is a free and open-source Unix-like operating system kernel created by Linus Torvalds in 1991. It is a core component of a wider operating system, which is typically packaged as a Linux distribution (distro). These distros include the kernel, supporting system software, and libraries. 

#🔹 Linux = Kernel + Tools
--Linux is not just an operating system. It’s made of:

--Linux Kernel: The core brain that talks to the hardware (CPU, RAM, Disk).

--Userland tools: Bash, system utilities, drivers — things we use on top of the kernel.



#What is a “distribution?”
Linux distribution is an operating system that is made up of a collection of software based on Linux kernel or you can say distribution contains the Linux kernel and supporting libraries and software

#Example:-
------------------------------------------------------------------------------------------------------------
| Family     | Description                          | Examples                                             |
|------------|--------------------------------------|------------------------------------------------------|
| Debian     | Stable, community-driven             | Debian, Ubuntu, Linux Mint, Kali Linux               |
| RHEL       | Enterprise-focused (paid support)    | RHEL, CentOS, Fedora, AlmaLinux, Rocky Linux         |
| Arch       | Rolling release, minimal base        | Arch Linux, Manjaro, EndeavourOS                     |
| SUSE       | European enterprise distros          | openSUSE (Tumbleweed/Leap), SUSE Linux Enterprise    |
| Slackware  | One of the oldest, highly customizable| Slackware, Salix OS                                 |
-----------------------------------------------------------------------------------------------------------
							
#🧠 Architecture of Linux

+-------------------------+
|   User Applications     |   <- (bash, Python, Docker, Tuleap etc.)
+-------------------------+
|     System Libraries    |   <- (glibc, libc, openssl, etc.)
+-------------------------+
|       Linux Kernel      |   <- (memory, CPU, devices, drivers)
|  - Process Management   |
|  - Filesystems (ext4)   |
|  - Networking (TCP/IP)  |
|  - Virtualization       |
|  - Security (SELinux)   |
+-------------------------+
|       Hardware          |   <- (CPU, RAM, Disk, Network)
+-------------------------+
							
							
#Linux Architecture Recap:							
Hardware → Linux Kernel (manages CPU, memory, filesystem, network, security) → System Libraries (glibc, openssl) → User Applications (bash, Python, Docker, Tuleap).							
							
		
		
================================================================================================================================================											
							         *DOCKER*
	
#What is Docker
Docker is a containerization platform that allows developers to (build, ship, and run) applications within lightweight, portable containers. It's used to package applications and their dependencies into these containers, which ensure the application can run consistently across different environments. 

#Eg:-
Docker lets you run apps in isolated boxes (containers) — like running Python + MySQL together without installing them on your system.
--🧪 Example: Run a Python app with docker run python.

Build:
You create a Docker image of your app (like packing your app + everything it needs).
Example: docker build -t myapp .

Ship:
You share or upload this image to a registry (like Docker Hub).
Example: docker push myapp

Run:
Anyone can download and run your app container anywhere.
Example: docker run myapp

#🛠Simple real-world analogy:

--Build = Packing your lunchbox with food (your app + ingredients)

--Ship = Sending the lunchbox to a friend

--Run = Your friend opens the lunchbox and eats the food anytime, anywhere

#eg:-
1. Create a file: app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from Docker!"


2. Create a file: Dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY app.py .
RUN pip install flask

CMD ["python", "app.py"]


3.  Build and Run
docker build -t flask-app .
docker run -p 5000:5000 flask-app

4. Access
👉 http://localhost:5000


#indetail
✅ 1. Build
You create a Docker image — like packaging your app and its environment.

docker build -t my-flask-app .


This command reads your Dockerfile

Packages your app + Python + dependencies

Creates an image called my-flask-app


✅ 2. Ship (Share)

You send that image to others or to servers using Docker Hub or a private registry.


📦 Analogy:
You ship your lunchbox to a friend, or production kitchen, exactly as you made it.

docker push username/my-flask-app

Uploads image to Docker Hub

Others can now pull it


✅ 3. Run
You start a container from the image. It becomes a running instance.

🍱 Analogy:
They open and eat the lunchbox. No need to cook — it's ready to use.

docker run -p 5000:5000 my-flask-app

Runs the app in a container

Accessible on port 5000

#🔁 Summary Flow
Dockerfile  ➜  docker build  ➜  docker push  ➜  docker run
Source code    Create image     Share image     Run container
-----------------------------------------------------------------------------
| Step  | Command                             | Result                       |
| ----- | ----------------------------------- | ---------------------------- |
| Build | `docker build -t flask-app .`       | Creates image with app       |
| Share | `docker push yourrepo/flask-app`    | Uploads to Docker Hub        |
| Run   | `docker run -p 5000:5000 flask-app` | App live at `localhost:5000` |
-----------------------------------------------------------------------------



#How many ways to build a Docker image?
| Method                 | Description                              |
| ---------------------- | ---------------------------------------- |
| `Dockerfile`           | Declarative build instructions           |
| `docker commit`        | Snapshot of modified running container   |
| `BuildKit`             | Faster builds with cache and parallelism |
| `docker-compose build` | Builds multi-container app using YAML    |


#What is docker-compose-tool
Docker Compose is a tool for defining and managing multi-container Docker applications. It allows users to define their application's services, networks, and volumes in a single YAML file (typically named docker-compose.yml). With a single command, users can then create and start all the services defined in the docker-compose.yml file.. 

#Example:-
Docker Compose runs multiple containers together using one file — like launching a full project with a web app, database, and cache in one go.
--🧪 Example: Start Python + MySQL + Redis with docker-compose up from a YAML file.


									
							🧱Docker Architecture	
							
							
															
+---------------------------+
|       Docker CLI / API    |  <-- You run commands (e.g. docker run)
+---------------------------+
            |
            v
+---------------------------+
|       Docker Daemon       |  <-- dockerd: manages containers, images, networks, volumes
+---------------------------+
            |
            v
+---------------------------+
|      Container Runtime    |  <-- containerd + runc (runs containers)
+---------------------------+
            |
            v
+--------------------------------------------------------------+
|                   Linux Operating System (Ubuntu)            |
|                                                              |
|  +--------------------------------------------------------+  |
|  |                    Linux Kernel                         | |
|  |  (Namespaces, cgroups, UnionFS, storage drivers,        | |
|  |   networking, device management, security modules)      | |
|  +--------------------------------------------------------+  |
|                                                              |
|  +------------+   +------------+   +---------------+         |
|  | Containers |   |   Images   |   |    Volumes    |         |
|  +------------+   +------------+   +---------------+         |
+--------------------------------------------------------------+
            |
            v
+---------------------------+
|         Hardware          |
+---------------------------+
			
			
			
			
+----------------------------+
|        Hardware            |   ⬅️  Example: Physical Machine / Cloud VM
|                            |       (e.g. Intel Core i7, 16 GB RAM)
+----------------------------+
              |
+----------------------------+
|   Ubuntu (Base OS Layer)   |   ⬅️  Example: Ubuntu 20.04 LTS (Host OS)
|                            |       Docker runs *on top* of this
+----------------------------+
              |
+----------------------------+
|       Docker Engine        |   ⬅️  Example: Docker v20.10.6 (dockerd)
|                            |       Manages images, containers, volumes, networks
+----------------------------+
              |
+-------------------------------------------------------------+
|                  Docker Containers (Share Kernel)           |
|                                                             |
|  +----------------------+   +--------------------------+    |
|  |  App Container 1     |   |  App Container 2         |    |
|  |  🐳 ROS2              |   |  🛠️ Jenkins CI/CD         |    |
|  |  - Runs in isolated  |   |  - Runs web interface     |    |
|  |    namespace         |   |  - Polls Git / builds     |    |
|  +----------------------+   +--------------------------+    |
|                                                             |
|  +--------------------------+                               |
|  |  App Container 3         |                               |
|  |  🗃️ MySQL Server         |                               |
|  |  - Stores project data   |                               |
|  +--------------------------+                               |
+-------------------------------------------------------------+
			
			
			
			
			
			
			
+---------------------------+
|       Docker CLI / API    |  <-- docker build, docker run, etc.
+---------------------------+
            |
            v
+---------------------------+
|       Docker Daemon       |  <-- dockerd
+---------------------------+
            |
            v
+---------------------------+
|      Container Runtime    |  <-- containerd + runc
+---------------------------+
            |
            v
+---------------------------------------------------------------+
|                   Linux Operating System (Ubuntu)             |
|                                                               |
|  +---------------------------------------------------------+  |
|  |                    Linux Kernel                          | |
|  |  (Namespaces, cgroups, UnionFS, overlayfs, net, seccomp) | |
|  +---------------------------------------------------------+  |
|                                                               |
|  ========== Docker Image Layers ==========                   |
|  |  Layer 5: CMD / ENTRYPOINT / EXPOSE                       |
|  |  Layer 4: App Code (COPY . /app)                          |
|  |  Layer 3: App Dependencies (pip/npm/maven install)        |
|  |  Layer 2: System packages (apt install curl, etc.)        |
|  |  Layer 1: Base OS (Ubuntu, Alpine, Debian, etc.)          |
|  ===========================================                |
|                                                               |
|  +----------------+   +---------------+   +--------------+    |
|  | Running        |   | Image Cache   |   | Volumes      |    |
|  | Container FS   |   |               |   |              |    |
|  +----------------+   +---------------+   +--------------+    |
+---------------------------------------------------------------+
            |
            v
+---------------------------+
|         Hardware          |
+---------------------------+
			
			
#Recap			
						
+---------------------------+
|     Docker CLI / API     |  <- You run commands (docker run ...)
+---------------------------+
|     Docker Daemon        |  <- docker engine (dockerd)
|     (Manages all tasks)  |
+---------------------------+
|     containerd / runc    |  <- Actual container runtime
+---------------------------+
|     Linux Kernel         |  <- Uses namespaces, cgroups, etc.
+---------------------------+
|     Linux OS (Ubuntu)    |
+---------------------------+
|         Hardware         |
+---------------------------+

				
								
			
# 📦 Real-World View with Volumes & Networks

+---------------------+
|     Docker CLI      |  <-- The tool you (the user) use in the terminal to interact with Docker
+---------------------+
          |
          v
+---------------------+
|   Docker Daemon     |  <-- Manages containers, volumes, networks, images
+---------------------+
    |         |          |
    v         v          v
 [Images]  [Volumes]  [Networks]  <-- All stored on host filesystem (Ubuntu)
    |
    v
[Containers running using Linux Kernel features:]
    - namespaces (isolation)
    - cgroups (resource limits)
    |
    v
+----------------+
|  Linux Kernel  |
+----------------+
    |
    v
+--------------------------+
|   Ubuntu OS and Hardware  |
+--------------------------+

	

#Explanation:

Docker CLI: Your interface to give Docker commands.

Docker Daemon: The engine that manages lifecycle of containers, volumes (persistent data), networks (container communication), and images.

Images, Volumes, Networks: All stored on your Ubuntu host filesystem.

Containers: Run isolated via Linux Kernel features like namespaces and cgroups.

Linux Kernel: Provides core OS mechanisms enabling containerization.

Ubuntu OS & Hardware: The base operating system and physical hardware beneath everything.

			
#Components

| Component             | Role                                                                                           |
| --------------------- | ---------------------------------------------------------------------------------------------- |
| **Docker Client**     | CLI/API that sends commands to Docker Daemon (`dockerd`).                                      |
| **Docker Daemon**     | Manages containers, images, networks, volumes; executes user commands.                         |
| **Container Runtime** | Runs containers using `containerd` and `runc`.                                                 |
| **Linux Kernel**      | Provides core features: namespaces (isolation), cgroups (resource control), union filesystems. |
| **Containers**        | Running instances of Docker images (isolated apps).                                            |
| **Images**            | Read-only templates or blueprints used to create containers.                                   |
| **Volumes**           | Persistent storage areas for containers to save data beyond container lifecycle.               |
| **Docker Registry**   | Stores and distributes Docker images (e.g., Docker Hub).                                       |
| **Docker Network**    | Manages container communication and connectivity.                                              |
				
				
				

#🔍 Core Difference
| Feature            | **Docker (Containers)**                          | **VMware (VMs)**                           |
| ------------------ | ------------------------------------------------ | ------------------------------------------ |
| **Architecture**   | Shares host OS kernel                            | Has full guest OS with its own kernel      |
| **Isolation**      | Process-level (lighter)                          | Hardware-level (stronger)                  |
| **Boot Time**      | Seconds                                          | Minutes                                    |
| **Size**           | Small (MBs)                                      | Large (GBs)                                |
| **Performance**    | Near-native (less overhead)                      | More overhead due to full OS               |
| **Resource Usage** | Low (no separate OS)                             | High (needs OS, RAM, CPU, disk)            |
| **Use Case**       | Microservices, CI/CD, fast deployment            | Full OS testing, legacy app support        |
| **Security**       | Weaker isolation (depends on host kernel)        | Stronger isolation (separate OS)           |
| **Portability**    | Very high (same image runs anywhere with Docker) | Lower (relies on hypervisor compatibility) |


🧱 Analogy
Docker = Apartment in a building (share walls/resources)
VMware = Independent house (everything separate)


#🧱 How Docker Uses Linux Internals
							
Docker runs on top of Linux and relies on powerful Linux kernel features to create and manage containers. These containers are lightweight, fast, and isolated — all thanks to the Linux kernel.



#💡 Key Linux Kernel Features Docker Uses:

| Linux Feature               | Description                                      | Analogy                                   |
| --------------------------- | ------------------------------------------------ | ----------------------------------------- |
| **Namespaces**              | Isolates processes, filesystems, users, networks | Each container lives in its own apartment |
| **cgroups**                 | Limits CPU, memory, IO usage per container       | Budgeting resources per tenant            |
| **UnionFS (AUFS/overlay2)** | Layered file systems for images/containers       | Like transparent layers on a whiteboard   |
| **chroot**                  | Restricts root directory                         | Locking user in their home                |
| **seccomp**                 | Filters allowed system calls                     | Syscall firewall                          |
| **AppArmor/SELinux**        | Mandatory access control                         | Security guards for each process          |
| **network namespaces**      | Virtual NICs per container                       | Own WiFi routers per apartment            |
| **device mapper/overlay2**  | Efficient image storage                          | Smart storage lockers                     |



#🧠 Simplified Flow of How Docker Uses Linux Internals

Docker CLI
   |
   v
Docker Daemon (dockerd)
   |
   v
containerd → runc
   |
   v
Linux Kernel Features
   |
   v
Containers (isolated, lightweight virtual OS environments)



#🔍 Behind the scenes
--You run docker run hello-world

--Docker CLI talks to Docker Daemon.(Docker CLI sends command to Docker Daemon.)

--Daemon uses containerd and runc to create and run the container.

--Linux Kernel:
Applies namespaces → isolation

Applies cgroups → resource limits

Uses UnionFS → image layering

--A new container runs a bash shell inside its own isolated Linux environment!


=================================================================================================================================================



					✅ Step-by-Step Flow: Running Tuleap & Jenkins in Docker on Ubuntu
					
							   #Architecture Overview
				
+---------------------------------------------------------------------+
|                        Ubuntu Host (Docker Engine)                  |
|                                                                     |
|  +---------------------+       +---------------------+              |
|  |    Tuleap Container |       |   Jenkins Container |              |
|  |    (Server1)        |       |    (Server2)        |              |
|  |                     |       |                     |              |
|  |  - Nginx            |======>|  - Nginx (Proxy)    |              |
|  |  - PHP-FPM          |<======|  - Jenkins (Java)   |              |
|  |  - Redis            |       |  - ROS 2 Humble     |              |
|  |  - MySQL            |       |    (osrf/ros:humble)|              |
|  |  - Git              |       |                     |              |
|  +---------------------+       +---------------------+              |
|                                                                     |
+---------------------------------------------------------------------+



1. Ubuntu Host Setup (Base Layer)
✅ You install Ubuntu on a physical machine or virtual machine (VM).
➡️This is your Host Operating System — the foundation where everything runs.


2. Docker Installation
✅ You install Docker Engine on the Ubuntu system using:
$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

--docker-ce: Docker Community Edition (engine)

--docker-ce-cli: The command-line interface

--containerd.io: Runtime service that manages containers

--docker-buildx-plugin: Enables advanced image building (multi-arch, caching, etc.)

--docker-compose-plugin: Adds support for docker compose (the modern replacement for the old docker-compose tool)



3. Run Containers Using Docker CLI
✅ Start services using Docker CLI commands in Ubuntu terminal.
➡️ You're using the Docker CLI to request that a container (e.g., jenkins) be started.

# Example with individual run
$ docker run -d --name jenkins -p 8080:8080 jenkins/jenkins:lts

# Example using Compose (if you have a docker-compose.yml)
$ docker compose up -d

➡️ This command is run in your Ubuntu terminal using the Docker CL
➡️ This tells Docker to launch Jenkins or Tuleap as a container.



4. Docker CLI Sends Command to Docker Daemon

✅ The Docker CLI is just a client tool — like a remote control.
--It does not create or manage containers itself.
✅ The CLI sends a REST API request to the Docker Daemon (dockerd) asking it to do something (like run a container)


🧠 Think of it like:

Docker CLI = Remote control
dockerd (Daemon) = Engine that actually runs containers


#📌 Example:
docker run jenkins → CLI sends → “Hey dockerd, please run the Jenkins image as a container.”




5. Docker Daemon Uses containerd + runc to Launch Container

| Component      | Role                                       |
| -------------- | ------------------------------------------ |
| **dockerd**    | Receives your command and delegates work   |
| **containerd** | Pulls image, prepares filesystem & config  |
| **runc**       | Creates isolated container using Linux     |
	
		
#Detailed Flow:

1️⃣ You run a command
#docker run ubuntu
➡️ This is received by the Docker Daemon (dockerd).


2️⃣ Docker Daemon sends this to containerd
containerd is responsible for managing the container's lifecycle.

It does the following:

📥 Pulls the image (e.g., ubuntu) from Docker Hub if not already available.

📦 Unpacks the image into a root filesystem (e.g., /var/lib/containerd/...).

📝 Prepares a runtime spec (config.json) that defines how the container should run (entrypoint, env vars, mounts, etc.).


3️⃣ containerd calls runc
runc is a low-level tool that actually starts the container.
Receives config.json + root filesystem path
It receives the config.json and root filesystem path from containerd.

	
4️⃣ runc uses Linux kernel features to create an isolated environment:

🔒Namespaces → Process, network, and filesystem isolation

📊 cgroups → limits CPU, memory, I/O.

📂pivot_root/chroot → Switch to container's root filesystem

🔐seccomp/AppArmor → Apply security profiles



5️⃣ runc starts the container process
#Example: runs /bin/bash or any other entrypoint defined in the image.
Example: runs jenkins.war or /bin/bash

The process is isolated from the host and runs inside a container.


6️⃣ ✅ Container is now running
The Docker Daemon monitors the container.

You can see it using 
# $ docker ps.


6. Containers Run on Linux Kernel Features
All containers rely on core Linux features:

--Namespaces – Isolate each container's processes, networks, and mounts.

--cgroups – Control resource usage (CPU, memory).

--UnionFS – Efficient layered filesystem used by container images (AUFS, OverlayFS).



7. Tuleap and Jenkins now run as isolated containers:

✅ Tuleap container:
--Manages Agile/DevOps, tasks, Git repos, trackers, and more.

✅ Jenkins container:
--Automates builds, tests, and deploys code automatically via pipelines(CI/CD).

➡️ Each runs in its own isolated Linux environment, but they share the same host OS kernel.
➡️ Both run in isolated Linux environments, using shared host kernel
➡️ Secure, lightweight, and reproducible


8. Docker Networks + Volumes
➡️Containers communicate using Docker networks:

#network
$ docker network create my-network
$ docker run --network=my-network ...

#volume
➡️Persistent data is stored in volumes:
docker volume create my-data
docker run -v my-data:/var/lib/mysql ...

--📡 Tuleap and Jenkins can talk securely if on the same Docker network.

--🗂️ Volumes ensure data is not lost when containers stop or update.

#➡️ Why it matters:

🔗 Network → lets containers talk securely

💾 Volume → keeps data safe between restarts or image upgrades



9. Ubuntu host stays clean and isolated
✅ You don't install Jenkins, Tuleap, MySQL on the host system.
➡️ Everything runs inside containers, keeping your Ubuntu OS lightweight, clean, and secure.

✅ "Lightweight" means your Ubuntu host stays clean and fast because all heavy tools run inside isolated Docker containers, not directly on the system.
Easy to backup, update, or remove.


#Benefits:
🧹 Host OS stays lightweight and clean

🔄 Easy to backup, update, or migrate

🔐 Better security through isolation


[You on Ubuntu Terminal]
        |
        v
[docker-compose up]
        |
        v
[Docker CLI sends command]
        |
        v
[Docker Daemon receives it]
        |
        v
[containerd + runc prepare containers]
        |
        v
[Linux Kernel sets up namespaces + cgroups]
        |
        v
[Containers start → isolated Linux environments]
        |
        v
[Your apps (Tuleap + Jenkins) run in containers]



#From each server accessing itself (e.g., S1→Tuleap, S2→Jenkins) you see HTTPS secure padlock ✅
Is LAN (network) connectivity required between Tuleap and Jenkins for integration?
Yes, mandatory:

Integration means Tuleap server calls Jenkins API URLs, or Jenkins calls Tuleap URLs.

This requires network connectivity and hostname resolution.

Without network connection (no LAN or routed connection), integration won’t work.




✅ TLS/SSL SETUP — Internal CA
You created a Root Certificate Authority (CA):

internal-ca.key.pem → Private Key

internal-ca.crt.pem → Public Root Certificate

You installed the CA on Ubuntu Host (via update-ca-certificates) for system-wide trust.









				

	
