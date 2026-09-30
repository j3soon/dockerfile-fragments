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
    gnupg \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
RUN apt-get update && apt-get install -y \
    nodejs \
    && rm -rf /var/lib/apt/lists/*
# Install OpenCode CLI
# Ref: https://opencode.ai/
# This remote metadata changes when the npm latest tag advances, which
# invalidates the install layer during normal Docker builds.
ADD https://registry.npmjs.org/opencode-ai/latest /tmp/opencode-latest.json
RUN npm install -g opencode-ai@latest
RUN opencode_version="$(opencode --version)" \
    && test -n "$opencode_version" \
    && echo "Installed OpenCode CLI: $opencode_version"
RUN echo 'alias op="opencode --auto"' >> /root/.bashrc
