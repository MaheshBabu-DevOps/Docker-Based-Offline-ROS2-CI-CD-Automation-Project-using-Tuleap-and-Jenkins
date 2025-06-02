#!/bin/bash

# Jenkins Offline Installer: Downloads LTS WAR & categorized plugins with dependencies 
                      

# Update system and install tools
# Uncomment if you want to update the system as well
# sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl openjdk-17-jdk


# Set download directory dynamically for the current user
USER_NAME=$(whoami)
DOWNLOAD_DIR="/home/${USER_NAME}/Downloads/"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR" || exit 1   #directory $DOWNLOAD_DIR does not exist or is not accessible


# Download the Jenkins Plugin Manager CLI
curl -L -o jenkins-plugin-manager.jar https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.2/jenkins-plugin-manager-2.13.2.jar


# Create plugins.txt file with desired plugins
cat <<EOL > plugins.txt
# Tuleap Integration Plugins - Enable Jenkins to integrate with Tuleap for project and code management
tuleap-api:latest                       # Provides Tuleap REST API integration for Jenkins
tuleap-git-branch-source:latest        # Allows Jenkins to use Tuleap Git repositories as multibranch sources
tuleap-oauth:latest                     # Adds OAuth authentication for Jenkins using Tuleap

# Git Plugins - Enable Jenkins to work with Git and GitHub repositories
git:latest                              # Core Git plugin for cloning and interacting with Git repositories
git-client:latest                       # Provides low-level Git command execution
github-api:latest                       # GitHub API library used by other GitHub plugins
github:latest                           # Adds GitHub project linking and SCM polling
github-branch-source:latest             # Enables multibranch pipeline support for GitHub repos
git-server:latest                       # Turns Jenkins into a basic Git server
git-parameter:latest                    # Adds Git revision parameter in build triggers
github-pullrequest:latest               # Detects and builds GitHub pull requests
git-changelog:latest                    # Generates changelogs from Git commit history
github-autostatus:latest                # Reports pipeline stages back to GitHub with status
git-tag-message:latest                  # Extracts tag messages for use in build steps
last-changes:latest                     # Displays last changes in a build (commit info, diffs)

# Blue Ocean Plugins - Modern UI and visualization tools for pipelines
blueocean:latest                        # Meta package installing all Blue Ocean plugins
blueocean-commons:latest                # Common Blue Ocean utilities and APIs
blueocean-rest:latest                   # Blue Ocean's REST API
blueocean-web:latest                    # Core Blue Ocean frontend module
blueocean-pipeline-scm-api:latest       # SCM data handling for Blue Ocean UI
blueocean-git-pipeline:latest           # Git-specific support for Blue Ocean
blueocean-dashboard:latest              # Pipeline dashboard view in Blue Ocean
blueocean-pipeline-editor:latest        # Web-based pipeline editor in Blue Ocean

# Docker-related Plugins - Integrate Docker for building and deploying containers
docker-plugin:latest                    # Connects Jenkins agents running in Docker containers
docker-commons:latest                   # Shared Docker logic for other plugins
docker-workflow:latest                  # Enables Docker use in Jenkins pipelines
docker-java-api:latest                  # Java client for Docker used by other plugins
docker-compose-build-step:latest        # Run Docker Compose as a build step

# SSH-related Plugins - For managing remote agents and secure connections
ssh-credentials:latest                  # Adds support for SSH private keys as credentials
ssh-slaves:latest                       # Launch and manage agents over SSH
sshd:latest                             # Embedded SSHD to control Jenkins over SSH
ssh-steps:latest                        # Run SSH commands as pipeline steps

# Test Plugins - Add support for testing frameworks and result reporting
junit:latest                            # Processes JUnit test reports and shows results
plot:latest                             # Plot data from builds (useful for performance or metrics)
testInProgress:latest                   # Shows tests that are currently executing
performance:latest                      # Measures and reports performance metrics
maven-plugin:latest                     # Enables building and analyzing Maven projects
autograding:latest                      # Auto-grades tests and results for educational use
testng-plugin:latest                    # Parses TestNG results
test-results-aggregator:latest          # Combines test results from multiple projects
test-stability:latest                   # Detects flaky tests based on history
robot:latest                            # Processes Robot Framework test results
junit-realtime-test-reporter:latest     # Streams test results to UI in real-time

# Email Plugins - Notification plugins for builds and test results
email-ext:latest                        # Sends rich and customizable email notifications
emailext-template:latest                # Provides templates for email-ext plugin
mail-watcher-plugin:latest              # Monitors mailboxes to trigger Jenkins jobs
mailer:latest                           # Basic mail notification support (legacy)
poll-mailbox-trigger-plugin:latest      # Triggers jobs based on received emails
view-job-filters:latest                 # Adds filters to Jenkins views based on job names/status

# Pipelines Plugins - Core functionality for writing and visualizing Jenkins pipelines
pipeline-rest-api:latest                # Exposes pipelines over Jenkins REST API
pipeline-stage-step:latest              # Defines individual stages in a pipeline
pipeline-input-step:latest              # Adds input (approval) steps to pipelines
pipeline-model-api:latest               # Provides APIs for declarative pipeline model
pipeline-build-step:latest              # Enables running build jobs from pipelines
pipeline-graph-analysis:latest          # Analyzes stage graphs for pipeline UI
pipeline-stage-view:latest              # UI for visualizing pipeline stage progression
pipeline-utility-steps:latest           # Useful common steps like reading files, archiving
pipeline-graph-view:latest              # Visual graph of pipeline stages
pipeline-timeline:latest                # Shows timeline of pipeline execution

# Webhooks and Triggers - Automatically trigger jobs from external events
webhook-step:latest                     # Adds webhook trigger step for pipelines
multibranch-scan-webhook-trigger:latest # Triggers multibranch scans via webhook
parameterized-trigger:latest            # Triggers jobs with parameters from other builds
gerrit-trigger:latest                   # Integrates Gerrit code review system for triggering
generic-webhook-trigger:latest          # Trigger jobs using generic JSON webhooks
authentication-tokens:latest            # Secure tokens for webhook/job triggers
ws-cleanup:latest                       # Cleans up workspace before/after builds

# Backup and Disk Usage Plugins - Protect and monitor Jenkins storage
sonar:latest                            # Integrates SonarQube static code analysis
prometheus:latest                       # Exposes Jenkins metrics to Prometheus
thinBackup:latest                       # Lightweight backup plugin for job configs, builds
periodicbackup:latest                   # Schedule-based Jenkins backup
backup:latest                           # Backup and restore full Jenkins setup
disk-usage:latest                       # Monitors job and build disk usage
diskcheck:latest                        # Alerts when disk space is low
role-strategy:latest                    # Define and enforce fine-grained user roles and permissions
cloudbees-disk-usage-simple:latest      # Lightweight CloudBees plugin for disk usage tracking
EOL

# # Fetch the latest Jenkins LTS version number from the official update center
version=$(curl -sL https://updates.jenkins.io/stable/latestCore.txt)

echo "✅ Latest Jenkins LTS version: $version"

# Download the Jenkins WAR file using the latest version
wget "https://get.jenkins.io/war-stable/${version}/jenkins.war"

# Download plugins and their dependencies
java -jar jenkins-plugin-manager.jar --war jenkins.war --plugin-file plugins.txt --plugin-download-directory jenkins_plugins

# Set permissions for the entire DOWNLOAD_DIR directory and its contents
chmod -R 755 "$DOWNLOAD_DIR"  # Sets read, write, and execute permissions
chown -R "$USER_NAME:$USER_NAME" "$DOWNLOAD_DIR"  # Set ownership for current user

# Clean up unwanted files if needed
rm -f jenkins.war jenkins-plugin-manager.jar plugins.txt







# Note: This typically happens when running the script if Jenkins' update servers or mirrors are temporarily overloaded or under maintenance. Please try running the script again after 5–10 minutes.

# You can import updated plugins into the same Jenkins plugins/ directory without deleting old ones.
# ✅ Jenkins will overwrite old .jpi files with newer versions.
# ✅ No need to manually delete existing plugins.
# ✅ Jenkins detects updated plugins and loads them after restart.
# This ensures a smooth plugin update workflow for offline setups.












