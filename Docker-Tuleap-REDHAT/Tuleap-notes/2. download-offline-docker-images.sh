#!/bin/bash  

# Script to download frozen Docker images for offline use

# ========================================
# ✅ Mandatory Docker Images
# ========================================

./download-frozen-image-v2.sh ./tuleap/docker tuleap/tuleap-community-edition:latest   # Project management and DevOps platform
./download-frozen-image-v2.sh ./jenkins/docker jenkins/jenkins:lts-jdk17              # CI/CD automation server
./download-frozen-image-v2.sh ./redis/docker library/redis:latest                     # In-memory cache used by Tuleap or others
./download-frozen-image-v2.sh ./mysql/docker mysql:8.0                                # Database server (used by Tuleap)
./download-frozen-image-v2.sh ./ros/docker osrf/ros:humble-desktop                   # Robot Operating System for robotics development
./download-frozen-image-v2.sh ./nginx/docker nginx:latest                             # Reverse proxy to handle TLS/SSL for services




# tar -cC './tuleap/docker' . | docker load


# ========================================
# 🟡 Optional Docker Images
# ========================================
# Uncomment if needed

# ./download-frozen-image-v2.sh ./mailhog/docker mailhog/mailhog:latest       # Mail testing
# ./download-frozen-image-v2.sh ./prometheus/docker prom/prometheus:latest   # Monitoring
# ./download-frozen-image-v2.sh ./grafana/docker grafana/grafana:latest      # Dashboards
# ./download-frozen-image-v2.sh ./sonarqube/docker sonarqube:latest          # Code quality analysis




#✅ Make Your Script Executable
#chmod +x download-offline-docker-images.sh


#✅ Run the Script
#./download-offline-docker-images.sh













