FROM ubuntu:22.04

# Common Pi Tools
RUN apt-get update && apt-get install -y \
    git \
    jq \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*
# Install Pi Coding Agent
# Ref: https://pi.dev/docs/latest
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
RUN apt-get update && apt-get install -y \
    nodejs \
    && rm -rf /var/lib/apt/lists/*
# This remote metadata changes when the npm latest tag advances, which
# invalidates the install layer during normal Docker builds.
ADD https://registry.npmjs.org/@earendil-works%2Fpi-coding-agent/latest /tmp/pi-coding-agent-latest.json
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent
RUN pi_version="$(pi --version)" \
    && test -n "$pi_version" \
    && echo "Installed Pi Coding Agent: $pi_version"
RUN mkdir -p /root/.pi/agent
