FROM ubuntu:22.04

# Use supervisor to manage services
RUN apt-get update && apt-get install -y \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install code-server
# Ref: https://coder.com/docs/code-server/install#debian-ubuntu
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*
RUN CODE_SERVER_VERSION=4.100.3 \
    && curl -fOL https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb \
    && dpkg -i code-server_${CODE_SERVER_VERSION}_amd64.deb \
    && rm code-server_${CODE_SERVER_VERSION}_amd64.deb

# Configure supervisor to manage the code-server
RUN cat <<EOF > /etc/supervisor/conf.d/code-server.conf
[program:code-server]
command=code-server --host 0.0.0.0 --port 8080
stderr_logfile=/var/log/code-server.err.log
stdout_logfile=/var/log/code-server.out.log
EOF

# Set the password for code-server
ARG CODE_SERVER_PASSWORD
RUN if [ -z "${CODE_SERVER_PASSWORD}" ]; then AUTH="none"; else AUTH="password"; fi && \
mkdir -p ~/.config/code-server/ && \
cat <<EOF > ~/.config/code-server/config.yaml
bind-addr: 127.0.0.1:8080
auth: ${AUTH}
password: ${CODE_SERVER_PASSWORD}
cert: false
EOF

CMD ["/usr/bin/supervisord", "-n"]
