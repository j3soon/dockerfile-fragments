FROM ubuntu:22.04

# Use supervisor to manage services
RUN apt-get update && apt-get install -y \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install OpenSSH Server
RUN apt-get update && apt-get install -y \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/run/sshd
RUN sed -i \
    -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' \
    /etc/ssh/sshd_config
# Set environment variables
# Ref: https://stackoverflow.com/a/34631891
RUN env | egrep -v "^(HOME=|USER=|MAIL=|LC_ALL=|LS_COLORS=|LANG=|HOSTNAME=|PWD=|TERM=|SHLVL=|LANGUAGE=|_=)" >> /etc/environment
# Configure supervisor to manage the SSH server
RUN cat <<EOF > /etc/supervisor/conf.d/sshd.conf
[program:sshd]
command=/usr/sbin/sshd -D
stderr_logfile=/var/log/sshd.err.log
stdout_logfile=/var/log/sshd.out.log
EOF

# Set the password for the root user
ARG SSH_PASSWORD
RUN if [ -z "${SSH_PASSWORD}" ]; then \
    # Allow empty password login
    passwd -d root && \
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config; \
else \
    # Set password for root user
    echo "root:${SSH_PASSWORD}" | chpasswd; \
fi

CMD ["/usr/bin/supervisord", "-n"]
