FROM ubuntu:22.04

# Install dependencies and Claude Code CLI
# Ref: https://code.claude.com/docs/en/setup
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://claude.ai/install.sh | bash

# Ensure the CLI is resolvable if installed under root's local bin
ENV PATH=/root/.local/bin:${PATH}
