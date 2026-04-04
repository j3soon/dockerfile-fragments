FROM ubuntu:22.04

# Install common tools
RUN apt-get update && apt-get install -y \
    git \
    jq \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*
# Install dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*
# Install OpenCode CLI
# Ref: https://opencode.ai/
RUN curl -fsSL https://opencode.ai/install | bash
