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
# This remote metadata changes when the OpenCode latest release advances, which
# invalidates the install layer during normal Docker builds.
ADD https://api.github.com/repos/anomalyco/opencode/releases/latest /tmp/opencode-latest-release.json
ENV PATH="/root/.opencode/bin:${PATH}"
RUN curl -fsSL https://opencode.ai/install | bash
RUN opencode_version="$(opencode --version)" \
    && test -n "$opencode_version" \
    && echo "Installed OpenCode CLI: $opencode_version"
