FROM ubuntu:22.04

# Use supervisor to manage services
RUN apt-get update && apt-get install -y \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y novnc && \
    rm -rf /var/lib/apt/lists/*

# Link vnc.html to index.html
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Configure supervisor to manage the noVNC server
RUN cat <<EOF > /etc/supervisor/conf.d/novnc.conf
[program:novnc]
command=/usr/share/novnc/utils/launch.sh --vnc localhost:5900
stderr_logfile=/var/log/novnc.err.log
stdout_logfile=/var/log/novnc.out.log
EOF

CMD ["/usr/bin/supervisord", "-n"]
