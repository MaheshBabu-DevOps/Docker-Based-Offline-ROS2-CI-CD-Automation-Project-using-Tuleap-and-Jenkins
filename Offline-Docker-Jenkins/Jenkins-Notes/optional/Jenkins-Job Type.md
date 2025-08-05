				             #Jenkins Job Types Explained with Real-Time Examples
				             




Freestyle Project
1. Freestyle Project
#What it is: The simplest Jenkins job type with a basic GUI configuration.

#Real-time example: Imagine you need to:

Build a simple Java application

Run unit tests

Archive the JAR file

#When to use:

Simple, one-off tasks

Tasks that don't need complex workflows

Quick prototyping

#Example workflow:

Pull code from GitHub

Run mvn clean install

Archive the target/*.jar file

Send email notification if build fails


2. Pipeline
#What it is: A more powerful job type defined by code (Jenkinsfile) that can model complex workflows.

#Real-time example: You're developing a microservice that needs to:

Build the application

Run unit tests

Build a Docker image

Push to Artifactory

Deploy to staging

Run integration tests

Promote to production if all tests pass

#When to use:

Complex workflows with multiple stages

When you need to maintain pipeline as code

CI/CD processes that require conditional logic


pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
            }
        }
    }
}




3. Multibranch Pipeline
#What it is: Automatically creates a pipeline for each branch in your repository.

#Real-time example: Your team uses Git flow with:

main branch (production)

develop branch (staging)

Feature branches (feature/*)

Hotfix branches (hotfix/*)

#When to use:

When working with feature branch workflows

When you want automatic branch discovery

When different branches need different build/test strategies

#How it works:

Scans your repository for branches

Automatically creates a pipeline for each branch

Can automatically delete pipelines for deleted branches

#Example use case:

Run light tests on feature branches

Run full test suite on develop branch

Only deploy from main branch

4. Organization Folder
#What it is: Scans entire GitHub/GitLab organizations or Bitbucket projects to automatically create pipelines for repositories.

#Real-time example: Your company has:

50+ microservices in a GitHub organization

Standardized build process across all

New services added frequently

#When to use:

Large organizations with many repositories

When you want to standardize CI/CD across projects

When new repositories are created frequently

#Example workflow:

Scan GitHub organization every hour

For each repository with a Jenkinsfile, create a pipeline

Apply security policies uniformly

Provide standardized visibility across all projects
Folder

5. Maven Project
#What it is: A specialized job type for building Java/Maven projects.

#Real-time example: Building a Spring Boot application where you need to:

Resolve dependencies from Nexus

Run specific Maven goals

Generate Javadoc

Publish artifacts

#When to use:

Java/Maven projects specifically

When you need Maven-specific features

When working with Maven POM files

#Key features:

Automatic artifact archiving

Maven version selection

POM file parsing

Dependency graph visualization


==============================================================================================================================================
#🔧 1. Freestyle Project
A Freestyle Project is the most basic and flexible type of Jenkins job. It allows you to create simple automation by defining build steps manually.

✅ Features:
GUI-based configuration

Shell/Batch commands

Simple SCM polling

Supports build triggers and post-build actions

❌ Limitations:
Not code-defined (no Jenkinsfile)

Poor scalability for complex pipelines

No branch detection or automation

🧑‍🔧 Use Case:
Perfect for quick tests or small jobs like:

Running a shell script to compile a C++ program or trigger an rsync backup.



#🛠️ 2. Pipeline
A Pipeline job is defined by a Jenkinsfile (written in Groovy). It allows you to define all stages of a CI/CD process in code.

✅ Features:
Code-based (stored in SCM as Jenkinsfile)

Supports stages, parallel builds, conditionals, loops

Full CI/CD automation

❌ Limitations:
No automatic scanning of new branches (that’s for Multibranch)

🧑‍🔧 Use Case:
Best for teams needing full CI/CD workflows with build, test, deploy stages.





#🌿 3. Multibranch Pipeline
A Multibranch Pipeline creates a pipeline for each branch in a repository. Jenkins auto-detects branches with a Jenkinsfile.

✅ Features:
Auto branch discovery

Jenkinsfile per branch

Webhooks or polling triggers per branch

❌ Limitations:
More complex to manage than single pipeline jobs

🧑‍🔧 Use Case:
Perfect for Git workflows, e.g., feature branches, PRs:

Automatically builds main, dev, feature/* branches with their own Jenkinsfile.




#🏢 4. Organization Folder
An Organization Folder is like a Multibranch Pipeline for multiple repositories under an SCM organization (e.g., GitHub org, GitLab group, Tuleap project group).

✅ Features:
Auto-detects repos and branches

Jenkinsfile-based

Suitable for large-scale Jenkins setups

🧑‍🔧 Use Case:
Best for managing 10+ repositories, especially in a structured project like Tuleap with multiple subprojects.


#📁 5. Folder
A Folder is just a container for organizing jobs. It helps you group pipelines or freestyle projects under a named directory.

✅ Features:
Logical grouping

Access control (permissions per folder)

❌ Limitations:
No build capabilities itself

No code or automation logic

🧑‍🔧 Use Case:
Useful for tidying Jenkins UI, e.g.:

Group all DevOps jobs in DevOps/, or QA jobs in QA/.




#☕ 6. Maven Project
A Maven Project is specialized for Java builds using Apache Maven.

✅ Features:
Auto detects pom.xml

Can generate reports (JUnit, Jacoco, etc.)

Integrates with Maven goals

❌ Limitations:
GUI configuration, not code-based

Only works well for Maven projects

🧑‍🔧 Use Case:
Great for Java developers with Maven dependencies and standard project structure.





| Job Type                 | Code-Based | Auto Branch Scan | Best For                                  |
| ------------------------ | ---------- | ---------------- | --------------------------------------    |
| **Freestyle Project**    | ❌          | ❌                | Quick tasks, basic shell jobs          |
| **Pipeline**             | ✅          | ❌                | Full-featured CI/CD with `Jenkinsfile` |
| **Multibranch Pipeline** | ✅          | ✅                | Managing multiple Git branches         |
| **Organization Folder**  | ✅          | ✅ (multi-repo)   | Managing large orgs or Tuleap groups   |
| **Folder**               | ❌          | ❌                | Visual grouping of jobs                |
| **Maven Project**        | ❌          | ❌                | Java projects with Maven builds        |



| Situation                            | Job Type             |
| ------------------------------------ | -------------------- |
| Quick shell automation               | Freestyle Project    |
| Standard CI/CD with stages           | Pipeline             |
| CI/CD for multiple Git branches      | Multibranch Pipeline |
| CI for 10+ repos in Tuleap or GitHub | Organization Folder  |
| Grouping jobs logically              | Folder               |
| Java app using Maven                 | Maven Project        |





===============================================================================================================================================

#🧪 Real Scenario: CI/CD for a ROS2 or Python AI/ML Project in Tuleap + Jenkins

🔧 Setup:
You have a Tuleap server at 192.168.3.1 (with Git, trackers, planning, etc.)

You have a Jenkins server at 192.168.3.2

Both are connected via LAN and use HTTPS (with internal CA)

Developers push code to Tuleap Git repos


#🧭 Goal:
Automate CI/CD: When a developer pushes code to Tuleap Git repo, Jenkins should:

Detect the change

Pull the branch code

Run tests, build, lint, etc.

Deploy artifact (optional)


✅ Which Jenkins Job Type to Use?
Let’s compare job types using a real Tuleap Git repo called:
https://192.168.3.1/git/my-project.git



🔴 1. Freestyle Project (NOT Recommended)
✔️ Example:
Manually configure job in GUI

Add Git URL and script: colcon build or pytest

❌ Why it's not good:
No auto branch detection

No Jenkinsfile

Not scalable for feature branches or multiple repos

Not reusable



#🟡 2. Pipeline Job (Good for basic CI/CD with one branch)
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://192.168.3.1/git/my-project.git'
            }
        }
        stage('Build') {
            steps {
                sh 'colcon build'
            }
        }
        stage('Test') {
            steps {
                sh 'pytest tests/'
            }
        }
    }
}


✅ Good for:
Small projects

One branch (e.g., main)

Manual setup

❌ Not ideal when:
You want per-branch pipelines (dev, feature/*)



#🟢 3. Multibranch Pipeline ✅ (Highly Recommended)
Jenkins auto-detects branches in Tuleap repo if each has a Jenkinsfile.

✔️ How it works:
Configure Tuleap Git repo in Jenkins

Jenkins scans repo, finds branches: main, dev, feature-xyz

Jenkins runs CI for each branch

My-Project/
 ├── main
 ├── dev
 └── feature-login-ui

Each of these runs its own Jenkinsfile.

✅ Why it's BEST for Tuleap:
Auto detects branches

CI for PRs or feature branches

Jenkinsfile is version-controlled

Matches Git workflow



#🔵 4. Organization Folder ✅✅ (Best for 10+ Tuleap Repos)
If you manage many projects like:

ros2-slam

ros2-navigation

ml-model-a

ml-model-b

Instead of configuring each repo manually, use Organization Folder.

#✔️ How it works:
You point Jenkins to your Tuleap project group (like an org in GitHub)

Jenkins auto discovers all repos under that group

Creates Multibranch Pipelines for each

✅ Why it’s best for large teams:
Zero config per repo

Centralized setup

Great for microservices or modular projects


🟢 Bonus: Folder (for visual organization only)
Use this to group Jenkins jobs, e.g.:


AI-Projects/
 ├── ml-pipeline
 └── data-cleaning
ROS2-Projects/
 ├── ros2-slam
 └── ros2-mapping




| Scenario                       | Job Type             | Reason                    |
| ------------------------------ | -------------------- | ------------------------- |
| One project, one branch        | Pipeline             | Simple and clean          |
| One project, many branches     | Multibranch Pipeline | Auto branch detection     |
| Multiple Tuleap Git repos      | Organization Folder  | Auto-detect + scale       |
| You just want to group jobs    | Folder               | UI only                   |
| Basic test job (manual config) | Freestyle Project    | Not scalable              |
| Java + Maven Project           | Maven Project        | Use only for Maven builds |




📌 Real Jenkins Setup for Your Case (Multibranch Example)
Go to Jenkins > New Item > Multibranch Pipeline

Name: ros2-ci

In Branch Source, choose Git

Add:

Repo URL: https://192.168.3.1/git/ros2-ci.git

Credentials: Add username/password or token

Jenkins auto-scans the repo and creates jobs for each branch with Jenkinsfile

Done ✅

🧪 Real Jenkinsfile for ROS2 Project (Simplified)
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://192.168.3.1/git/ros2-ci.git'
            }
        }
        stage('Build') {
            steps {
                sh 'colcon build'
            }
        }
        stage('Test') {
            steps {
                sh 'colcon test'
            }
        }
    }
}







| Job Type             | Code-Based | Auto Branch Scan | Best For                        |
| -------------------- | ---------- | ---------------- | ----------------------------    |
| Freestyle Project    | ❌          | ❌                | Simple shell builds          |
| Pipeline             | ✅          | ❌                | Complex CI/CD in Jenkinsfile |
| Multibranch Pipeline | ✅          | ✅                | Per-branch pipelines         |
| Organization Folder  | ✅          | ✅ (multi-repo)   | Managing 10+ repos in Tuleap |
| Folder               | ❌          | ❌                | Job grouping only            |
| Maven Project        | ❌          | ❌                | Java projects using Maven    |








=============================================================================================================================================

				#✅  What Happens When Jenkins Triggers the Pipeline (Offline ROS-2 CI/CD)

#✅Dockerfile Purpose
The Dockerfile creates a custom ROS 2 Humble container image that includes your cpp_pubsub package and the required build/test scripts.
It sets up an isolated, reproducible offline environment for building, testing, and debugging your ROS 2 C++ code.

or

The Dockerfile creates a custom ROS 2 Humble container image that includes your cpp_pubsub package along with the necessary build and test scripts. It provides an isolated, reproducible, and offline-capable environment for building, testing, and debugging your ROS 2 C++ code.


#Workflow

1. Jenkins Triggers the Pipeline
Manually or automatically (e.g. after a Git push).


2. Dockerfile is Used to Build the Image
Jenkins runs a docker build command using your Dockerfile.

This builds a custom Docker image with:

--ROS 2 Humble(using the official ros:humble base image)

--Your cpp_pubsub source code

--build.sh and test.sh scripts

#✅ Now you have an offline-ready, isolated container image.


3. Jenkins Runs the Docker Container
Jenkins runs a container from the custom image just built.


4. Inside the Running Container:
build.sh runs → compiles your ROS 2 C++ code.

test.sh runs → executes your tests.

#✅ This is like "deploying" your code into a mini offline ROS 2 test lab.

5. Jenkins Cleans Up
The container is stopped and removed.

Any intermediate Docker resources are cleaned.


6. Notifications Sent
Jenkins sends a success/failure notification (email, mailhog,Tuleap, etc.).




#✅ Jenkins Pipeline Purpose
The Jenkins pipeline automates the offline build and test process for a ROS 2 C++ package using Docker.

When Jenkins triggers the pipeline:

--It builds a custom Docker image using the provided Dockerfile, which includes ROS 2 Humble and the package source code.

--It runs a container from that image in an isolated environment.

--Inside the container, it executes the build script (colcon build) and the test script (colcon test).

--After the process completes, Jenkins sends a notification (e.g., via email) with the build/test result.

#✅ This is like deploying your code into a mini offline ROS 2 test lab, providing a clean, consistent, and reproducible environment for every CI run — even without internet access.



✅ Cleans the workspace.

🛠️ Builds the Docker image from the Dockerfile.

🚀 Runs the container.

📦 Inside the container:

--Executes build.sh to compile your ROS 2 package.

--Executes test.sh to run your package tests.

🧹 Cleans up Docker containers/images.

📣 Sends notifications (e.g., build success or failure).


#🔁 Offline CI/CD Workflow In One Line

--Jenkins → builds Docker image → runs container → executes build/test → cleans up → sends result

--Dockerfile runs first (via docker build), then the pipeline uses the image to run and test your ROS 2 code inside the container. ✅




#Advantages of Jenkins + Dockerfile Offline CI/CD
--Consistent and Reproducible Builds: Every build runs in the exact same environment, eliminating “works on my machine” problems.

--Offline Capability: Builds and tests can run without internet access once the Docker image is prepared.

--Clean and Isolated Environment: Each build happens in a fresh container, preventing leftover files or environment conflicts.

--Automation: Automates building, testing, cleanup, and notifications — reducing manual errors and saving time.

--Reduces Manual Work: No need for developers to manually build and test on local machines, avoiding mistakes and saving effort.

--Easy Environment Updates: Updating dependencies or ROS versions is as simple as editing the Dockerfile and rebuilding the image.

--Portability: The Docker image can run anywhere Docker is supported (different servers, laptops).

--Efficient Resource Use: Containers use fewer resources and start faster than full virtual machines.




#Uses of Jenkins + Dockerfile Offline CI/CD
--Continuous Integration for ROS 2 Packages: Automatically build and test ROS 2 C++ code with every commit or trigger.

--Offline Development and Testing: Ideal for environments with restricted or no internet access.

--Consistent Testing Across Teams: Ensures all developers and CI servers use the same environment.

--Automated Notifications: Sends build/test results via email or other channels to keep the team informed.

--Easy Deployment of ROS 2 Projects: Validates that code is buildable and testable before deployment.

--Reproducible Debugging Environment: Quickly spin up an isolated container to debug build or test failures.




#ROS2

The image (osrf/ros:humble-desktop) is a full ROS 2 Humble desktop image that includes support for both C++ and Python ROS 2 packages.

--It has all the necessary ROS 2 core libraries and tools.

--You can build and run both C++ and Python ROS 2 nodes inside this image.


#What does this mean?
--You can build and run your ROS 2 nodes (whether in C++ or Python) inside this isolated Docker container without installing ROS 2 directly on your host machine.

--The container acts like a mini virtual ROS 2 environment, fully equipped for development, testing, and debugging.




#Advantages of running ROS 2 inside Docker compared to native Ubuntu:
1. Consistent Environment:
The ROS 2 environment inside Docker is always the same, no matter which host machine you run it on. No issues with conflicting dependencies or missing libraries.

2. Easy Setup & Cleanup:
You don’t need to install or uninstall ROS 2 on your Ubuntu host. Just pull the Docker image, run containers, and remove them anytime without affecting the host OS.

3. Offline and Reproducible:
The custom Docker image you build includes your ROS 2 package and build/test scripts, allowing offline builds and tests reproducibly.

4. Isolation:
Your ROS 2 workspace inside the container won’t interfere with other software on your host.

5. Portability:
You can share the Docker image with your team so everyone works with the exact same setup.



#Final Recap

Using the osrf/ros:humble-desktop Docker image provides a ready-to-use, clean, and isolated ROS 2 environment that supports both C++ and Python development — making your workflow more reliable, portable, and easier to manage compared to installing ROS 2 directly on your Ubuntu host system.








				✅Q&A pairs for CICD setup using Tuleap and Jenkins on two Docker servers✅


#Q1: What is the role of Tuleap in your CI/CD setup?
A1: Tuleap manages project planning, code repositories, and tracks issues while integrating with Jenkins for automation.


#Q2: How does Jenkins fit into the CI/CD pipeline?
A2: Jenkins automates building, testing, and deploying code triggered by Tuleap commits or manual runs.


#Q3: Why use two separate servers for Tuleap and Jenkins?
A3: Separation improves security, resource management, and allows independent scaling and maintenance.


#Q4: Why run Tuleap and Jenkins inside Docker containers?
A4: Docker provides isolated, consistent, and portable environments for easy deployment and upgrades.


#Q5: What does the Dockerfile for ROS 2 do in this setup?
A5: It creates a custom Docker image with ROS 2 Humble and your code plus build/test scripts for isolated offline builds.


#Q6: What is the purpose of the Jenkinsfile in your pipeline?
A6: It defines automated stages to build the Docker image, run tests inside the container, cleanup, and send notifications


#Q7: How do you handle notifications in your CI/CD?
A7: Jenkins sends email and Tuleap notifications about build/test success or failure.


#Q8: Can you run both C++ and Python ROS 2 packages in this Docker setup?
A8: Yes, the osrf/ros:humble-desktop image supports both C++ and Python ROS 2 packages.


#Q9: What advantages does Docker provide for offline builds?
A9: Docker allows reproducible builds and tests in an isolated environment without needing internet or changing the host system.



#Q10: How do you clean up Docker resources after a Jenkins build?
A10: The pipeline removes containers and images to save disk space and avoid conflicts.


#Q11: How does Jenkins trigger the Docker build?
A11: Jenkins runs docker build command using your Dockerfile to create a custom ROS 2 image.


#Q12: What scripts are executed inside the Docker container during the pipeline?
A12: The pipeline runs build.sh to build and test.sh to test the ROS 2 package inside the container.


#Q13: Why is workspace cleanup important before building?
A13: Cleaning (git clean -fdx) removes untracked files ensuring a fresh, consistent build environment.
The cleanup happens inside the Jenkins workspace folder, 

#Q14: How does Tuleap integrate with Jenkins?
A14: Tuleap triggers Jenkins jobs and receives build status updates for traceability.


#Q15: What is the benefit of using a custom Docker image for ROS 2?
A15: It includes your code and dependencies, ensuring consistent builds across environments.


#Q16: What happens if a build fails in Jenkins?
A16: Jenkins cleans up Docker resources, sends failure notifications via email and Tuleap.


#Q17: How are test results managed in this pipeline?
A17: Test results are generated inside the container and can be archived or reported by Jenkins.

#Q18: Can you run this pipeline offline?
A18: Yes, once the Docker images and dependencies are downloaded, builds and tests run offline.


#Q19: How do you update the ROS 2 code in the Docker image?
A19: Modify source files and rebuild the Docker image with Jenkins pipeline.


#Q20: What is the main advantage of using Docker for ROS 2 development?
A20: It provides an isolated, reproducible environment that matches production setups.


#Q21: How do you manage different ROS 2 package versions?
A21: Use different Docker tags for each version and specify them in Jenkins pipeline.


#Q22: What is the purpose of the CMD tail -f /dev/null in Dockerfile?
A22: Keeps the container running so Jenkins can exec build and test scripts interactively.


#Q23: How does Jenkins ensure notifications reach the right people?
A23: It uses configured email recipients and Tuleap credentials for commit status updates.


#Q24: Why is it better to run builds/tests inside Docker than directly on Jenkins host?
A24: Avoids polluting Jenkins host environment and keeps builds isolated and consistent.


#Q25: How do you handle Docker container cleanup on Jenkins failure?
A25: The Jenkins post block runs commands to force remove containers and images safely.









=================================================================================================================================================

#Dockerfile
| Line                                  | What it does                                                              |
| ------------------------------------- | ------------------------------------------------------------------------- |
| `FROM osrf/ros:humble-desktop`        | Uses the official ROS2 Humble desktop image                               |
| `ENV PACKAGE cpp_pubsub`              | Sets a variable called `PACKAGE=cpp_pubsub`                               |
| `WORKDIR /ros2_gtest/`                | Sets the current working directory inside the container                   |
| `RUN mkdir -p /ros2_gtest/${PACKAGE}` | Creates the folder `/ros2_gtest/cpp_pubsub`                               |
| `WORKDIR /ros2_gtest/${PACKAGE}`      | Changes into that folder                                                  |
| `COPY res/build.sh ...`               | Copies your build script into the container                               |
| `COPY res/test.sh ...`                | Copies your test script into the container                                |
| `RUN chmod +x ...`                    | Makes both scripts executable                                             |
| `COPY src ...`                        | Copies your ROS2 C++ package code into `src/` folder inside the container |
| `RUN mkdir /ros2_gtest/test_results`  | Prepares a folder to store test results                                   |
| `CMD tail -f /dev/null`               | Keeps the container running, doing nothing                                |


#✅ Purpose of this Dockerfile
This Dockerfile creates a custom ROS 2 Humble container for the cpp_pubsub package, a typical ROS 2 publisher-subscriber example. It provides an isolated environment for offline development, building, testing, and debugging of your ROS 2 C++ package.


#Dockerfile Use
Creates a ROS 2 Humble container with your cpp_pubsub package source and build/test scripts, providing an isolated environment to build and test your ROS2 C++ code offline and consistently.


#dockerfile(cpp)

FROM osrf/ros:humble-desktop

ENV PACKAGE cpp_pubsub

WORKDIR /ros2_gtest/

RUN mkdir -p /ros2_gtest/${PACKAGE}

WORKDIR /ros2_gtest/${PACKAGE}

COPY res/build.sh /ros2_gtest/${PACKAGE}/build.sh
COPY res/test.sh /ros2_gtest/${PACKAGE}/test.sh

RUN chmod +x /ros2_gtest/${PACKAGE}/build.sh
RUN chmod +x /ros2_gtest/${PACKAGE}/test.sh

COPY src /ros2_gtest/${PACKAGE}/src

RUN mkdir /ros2_gtest/test_results

CMD tail -f /dev/null


1. FROM osrf/ros:humble-desktop
Uses the official ROS 2 Humble Desktop image.

Comes pre-installed with ROS 2 tools, C++ compilers, colcon, and GUI support.

2. 
Defines a variable PACKAGE=cpp_pubsub to reuse in file paths.

3. 
All following commands will run in /ros2_gtest/


4. 
Creates a directory /ros2_gtest/cpp_pubsub


5. 
Now working inside /ros2_gtest/cpp_pubsub

6. 
Copies build.sh and test.sh scripts from the host into the container.


7. 
Ensures the shell scripts can be run inside the container.

8. 
Copies your ROS 2 source code into the container.

9. 
Prepares a folder where colcon test output can be stored.


10. 
Keeps the container alive and idle.

Lets you manually enter and run ./build.sh or ./test.sh inside it.

#🔧 What you can do inside the container

docker exec -it <container_name> bash
cd /ros2_gtest/cpp_pubsub
./build.sh     # Build your ROS 2 package
./test.sh      # Run tests and view results


============================================================================================================================================

#🧪 New Example: A Dockerfile to build & test ROS2 C++ node automatically
FROM osrf/ros:humble

ENV PACKAGE cpp_pubsub
ENV WORKSPACE=/ros2_ws

# Create workspace structure
RUN mkdir -p $WORKSPACE/src
WORKDIR $WORKSPACE/src

# Copy your ROS2 package
COPY src/ $WORKSPACE/src/${PACKAGE}/

# Go to workspace root
WORKDIR $WORKSPACE

# Copy build and test scripts
COPY res/build.sh ./build.sh
COPY res/test.sh ./test.sh
RUN chmod +x build.sh test.sh

# Prepare folder for test results
RUN mkdir -p $WORKSPACE/test_results

# Run build and test script when container starts
CMD ["./build.sh"]


#(build.sh, test.sh) inside Docker container
📜 Example build.sh
#!/bin/bash
set -e
source /opt/ros/humble/setup.bash
colcon build --packages-select cpp_pubsub

📜 Example test.sh
#!/bin/bash
set -e
source /ros2_ws/install/setup.bash
colcon test --packages-select cpp_pubsub --event-handlers console_direct+
colcon test-result --all



#dockerfile(python)
FROM osrf/ros:humble-desktop

ENV PACKAGE python_pubsub

WORKDIR /ros2_gtest/

RUN mkdir -p /ros2_gtest/${PACKAGE}

WORKDIR /ros2_gtest/${PACKAGE}

COPY res/build.sh /ros2_gtest/${PACKAGE}/build.sh
COPY res/test.sh /ros2_gtest/${PACKAGE}/test.sh

RUN chmod +x /ros2_gtest/${PACKAGE}/build.sh
RUN chmod +x /ros2_gtest/${PACKAGE}/test.sh

COPY src /ros2_gtest/${PACKAGE}/src

# Optional: install Python dependencies if any
RUN apt-get update && apt-get install -y python3-pip
RUN pip3 install -r /ros2_gtest/${PACKAGE}/src/requirements.txt || true

RUN mkdir /ros2_gtest/test_results

CMD tail -f /dev/null

=================================================================================================================================================

#jenkinsfile


#Main Use of this Jenkins Pipeline Script
This pipeline automates the build and test process for your ROS2 package inside a Docker container based on the ROS2 Humble image, and then sends notifications about the build status.

--Automates the build and test process inside Docker by:

--Cleaning the workspace,

--Building the Docker image from your Dockerfile,

--Running the container to execute your build and test scripts,

--Cleaning up Docker resources,

--Sending notifications on success or failure.




#script

#basic pipeline
pipeline {
    agent any  // Run the pipeline on any available agent

    stages {
        stage('Build') {
            steps {
                echo 'Building the project...'
                // Example build command
                sh 'echo Build step executed'
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests...'
                // Example test command
                sh 'echo Test step executed'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                // Example deploy command
                sh 'echo Deploy step executed'
            }
        }
    }
}


#main

# Running build.sh and test.sh inside the Docker container is kind of like “deploying” your code inside the container environment for build and test purposes.


#Recap
--Clean workspace.

--Build Docker image.

--Run build inside Docker container.

--Run tests inside Docker container.

--Cleanup Docker container and image.

--Notify Tuleap and email recipients based on success or failure.



#pipeline

/* This script is for ROS2 GTest Build and Test and deploy the Pipeline by using ROS2 Humble Docker Image */
pipeline {
    agent any 
    environment {
        image = "ros2_build"
        DATE = new Date().format('yy.M.d')
        TAG = "${DATE}.${BUILD_NUMBER}"
    }
    stages {
        stage("clean") {
            steps {
                //To remove all untracked files and directories in the current directory (including ignored ones)
                sh "git clean -fdx"
            }
        }
        stage("build") {
            steps {
                //Execute a shell script (build.sh) in a docker container
                sh '''
                docker build -t $image:$TAG .
                docker run -d --name $image.$TAG $image:$TAG
		docker exec -t $image.$TAG ./build.sh
                '''
            }
        }
        stage("test") {
            steps {
                // This command is used to execute a shell script (`test.sh`) in a Docker container
                sh '''
                docker exec -t $image.$TAG ./test.sh
                '''
            }
        }
    }
    post {
        always {
            //clean the docker containers and images after the build
            sh '''
            docker rm -f $image.$TAG || true
            docker rmi -f $image:$TAG || true
            '''
        }
        failure {
            //Tuleap notification this sends to 'TULEAP' build has failed or success
            tuleapNotifyCommitStatus status: 'failure', repositoryId: '34', credentialId: 'tuleap-access-key'
            //Email notification this sends to 'MAILHOG' job has failed or success
            emailext(
                body: 'The build has failed check the logs data.',
                subject: 'BUILD FAILED: ${JOB_NAME} [${BUILD_NUMBER}]',
                to: 'mahesh@example.com',
                attachLog: true
            )
        }
        success {
            tuleapNotifyCommitStatus status: 'success', repositoryId: '34', credentialId: 'tuleap-access-key'
            emailext(
                body: 'The build has sucess check the logs data.',
                subject: 'BUILD SUCCESS: ${JOB_NAME} [${BUILD_NUMBER}]',
                to: 'mahesh@example.com',
                attachLog: true
            )
        }
    }
}


#Overview--pipeline
This pipeline builds a Docker image, runs build and test scripts inside a Docker container, and sends notifications based on the results.


1. pipeline { ... }
Defines the entire Jenkins pipeline.


2. agent any
Runs the pipeline on any available Jenkins agent (node).

| What you asked                  | Simple answer                          |
| ------------------------------- | -------------------------------------- |
| What does `agent any` mean?     | Run pipeline on any available machine. |
| If only Jenkins server machine  | Run pipeline on this single machine.   |
| Does it change ports 50000/8443 | No, ports stay the same.               |

"Run pipeline on any available machine" = Run the job on any free Jenkins machine right now.


3. environment { ... }
Sets some variables used throughout the pipeline:

image = "ros2_build" — the Docker image name to build and run.

DATE = new Date().format('yy.M.d') — current date in YY.M.D format.

TAG = "${DATE}.${BUILD_NUMBER}" — tag for Docker image that combines the date and Jenkins build number.
#This creates a TAG variable combining the date and the Jenkins build number (a unique number Jenkins increments for every build).
Example: 25.6.2.15 means build number 15 on June 2, 2025.


4. stages { ... }
Defines the main steps of the pipeline, divided into stages:


Stage: clean
Runs: git clean -fdx

Purpose: Removes all untracked files and directories (including ignored files) from the current workspace to start fresh.

| Setup                                       | Where `git clean -fdx` runs      |
| ------------------------------------------- | -------------------------------- |
| Jenkins job running on host                 | On the host machine workspace    |
| Jenkins job running inside Docker container | Inside the container's workspace |



5. Stage: build
Runs multiple shell commands inside a multiline sh block:

docker build -t $image:$TAG . — builds a Docker image from the current directory, tagging it with the name and tag.

docker run -d --name $image.$TAG $image:$TAG — runs a Docker container in detached mode with the built image, naming the container with the image name and tag.

docker exec -t $image.$TAG ./build.sh — executes the build.sh script inside the running container to compile your ROS2 project.



6. Stage: test
Runs inside a shell block:

docker exec -t $image.$TAG ./test.sh — runs the test.sh script inside the same container to execute tests (GTest in ROS2).


7. post { ... }
Actions that run after all stages, depending on the build result.
always
Runs after every build (success or failure).

Cleans up Docker resources:

docker rm -f $image.$TAG || true — forcibly removes the container, ignoring errors.

docker rmi -f $image:$TAG || true — forcibly removes the Docker image, ignoring errors.


8. failure
If the build fails:

Sends a failure status notification to Tuleap (tuleapNotifyCommitStatus).

Sends an email via Mailhog to mahesh@example.com with the failure message and attached logs.


9. success
If the build succeeds:

Sends a success status notification to Tuleap.

Sends an email to mahesh@example.com with success message and attached logs.






Download of images into './tuleap/docker' complete.
Use something like the following to load the result into a Docker daemon:
  tar -cC './tuleap/docker' . | docker load




































































































