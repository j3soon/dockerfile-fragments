FROM ubuntu:22.04

# Setup the required capabilities for the container runtime
# Ref: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html#driver-capabilities
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

RUN apt-get update && apt-get install -y \
    libgl1 mesa-utils \
    && rm -rf /var/lib/apt/lists/*
