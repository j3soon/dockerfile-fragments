FROM ubuntu:22.04

# Use supervisor to manage services
RUN apt-get update && apt-get install -y \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install XFCE
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    && rm -rf /var/lib/apt/lists/*
# Fix "Failed to execute default terminal emulator. Input/output error."
# Ref: https://askubuntu.com/a/1118319
# Ref: https://discourse.ubuntu.com/t/ctrl-alt-t-opens-xterm/60235/2
RUN apt-get update && apt-get install -y \
    xfce4-terminal \
    && rm -rf /var/lib/apt/lists/*
RUN update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper
# Fix "Failed to execute default Web Browser. Input/output error." by installing Firefox
# Ref: https://support.mozilla.org/en-US/kb/install-firefox-linux
RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*
RUN install -d -m 0755 /etc/apt/keyrings
RUN wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
RUN echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
RUN echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000' | tee /etc/apt/preferences.d/mozilla
RUN apt-get update && apt-get install -y \
    firefox \
    && rm -rf /var/lib/apt/lists/*

# Install TigerVNC
RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server \
    && rm -rf /var/lib/apt/lists/*

# Set the password for VNC
RUN touch ~/.Xauthority
ARG TIGERVNC_PASSWORD
RUN mkdir -p ~/.vnc && \
    echo "${TIGERVNC_PASSWORD}" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Configure supervisor to manage the TigerVNC server
RUN if [ -z "${TIGERVNC_PASSWORD}" ]; then FLAG="-SecurityTypes None --I-KNOW-THIS-IS-INSECURE"; else FLAG=""; fi && \
cat <<EOF > /etc/supervisor/conf.d/tigervnc.conf
[program:tigervnc]
command=/usr/bin/vncserver -fg :0 -geometry 1920x1080 -depth 24 -localhost no ${FLAG}
stderr_logfile=/var/log/tigervnc.err.log
stdout_logfile=/var/log/tigervnc.out.log
EOF

CMD ["/usr/bin/supervisord", "-n"]
