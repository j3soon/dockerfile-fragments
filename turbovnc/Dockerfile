FROM ubuntu:22.04

# Use supervisor to manage services
RUN apt-get update && apt-get install -y \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install XFCE
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    dbus-x11 \
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

# Install TurboVNC
# Ref: https://turbovnc.org/Downloads/YUM
RUN apt-get update && apt-get install -y \
    ca-certificates \
    gnupg \
    wget \
    && rm -rf /var/lib/apt/lists/*
RUN wget -q -O /tmp/TurboVNC.gpgkey https://packagecloud.io/dcommander/turbovnc/gpgkey && \
    gpg --dearmor -o /etc/apt/trusted.gpg.d/TurboVNC.gpg /tmp/TurboVNC.gpgkey && \
    rm -f /tmp/TurboVNC.gpgkey
RUN wget -q -O /etc/apt/sources.list.d/TurboVNC.list https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list
RUN apt-get update && apt-get install -y \
    turbovnc \
    && rm -rf /var/lib/apt/lists/*

# Set the password for VNC
RUN touch ~/.Xauthority
ARG TURBOVNC_PASSWORD
RUN mkdir -p ~/.vnc && \
    if [ -n "${TURBOVNC_PASSWORD}" ]; then \
        echo "${TURBOVNC_PASSWORD}" | /opt/TurboVNC/bin/vncpasswd -f > ~/.vnc/passwd && \
        chmod 600 ~/.vnc/passwd; \
    fi
RUN cat <<'EOF' > ~/.vnc/xstartup
#!/bin/sh
exec dbus-launch --exit-with-session startxfce4
EOF
RUN chmod +x ~/.vnc/xstartup

# Configure supervisor to manage the TurboVNC server
# Ref: https://turbovnc.org/Documentation/Compatibility30
RUN if [ -z "${TURBOVNC_PASSWORD}" ]; then FLAG="-securitytypes None"; else FLAG="-securitytypes VNC -rfbauth /root/.vnc/passwd"; fi && \
cat <<EOF > /etc/supervisor/conf.d/turbovnc.conf
[program:turbovnc]
command=/opt/TurboVNC/bin/vncserver -fg :0 -geometry 1920x1080 -depth 24 -xstartup /root/.vnc/xstartup ${FLAG}
stderr_logfile=/var/log/turbovnc.err.log
stdout_logfile=/var/log/turbovnc.out.log
EOF

CMD ["/usr/bin/supervisord", "-n"]
