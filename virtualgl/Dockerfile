FROM ubuntu:22.04

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

RUN apt-get update && apt-get install -y \
    libgl1 mesa-utils \
    && rm -rf /var/lib/apt/lists/*

# Ref: https://virtualgl.org/Downloads/YUM
RUN apt-get update && apt-get install -y \
    ca-certificates \
    gnupg \
    wget \
    && rm -rf /var/lib/apt/lists/*
RUN wget -q -O /tmp/VirtualGL.gpgkey https://packagecloud.io/dcommander/virtualgl/gpgkey && \
    gpg --dearmor -o /etc/apt/trusted.gpg.d/VirtualGL.gpg /tmp/VirtualGL.gpgkey && \
    rm -f /tmp/VirtualGL.gpgkey
RUN wget -q -O /etc/apt/sources.list.d/VirtualGL.list https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.list
RUN apt-get update && apt-get install -y \
    virtualgl \
    && rm -rf /var/lib/apt/lists/*
