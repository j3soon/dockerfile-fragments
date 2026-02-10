FROM ubuntu:22.04

# Install Codex CLI
# Ref: https://developers.openai.com/codex/cli/
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
RUN apt-get update && apt-get install -y \
    nodejs \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @openai/codex
