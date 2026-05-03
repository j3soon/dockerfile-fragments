#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
RUN_SCRIPT="${SCRIPT_DIR}/rebuild-opencode-docker.sh"
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
SERVICE_NAME="rebuild-opencode-docker.service"
TIMER_NAME="rebuild-opencode-docker.timer"
SERVICE_PATH="${UNIT_DIR}/${SERVICE_NAME}"
TIMER_PATH="${UNIT_DIR}/${TIMER_NAME}"

mkdir -p "${UNIT_DIR}"
chmod +x "${RUN_SCRIPT}"

cat > "${SERVICE_PATH}" <<EOF
[Unit]
Description=Rebuild OpenCode Docker images if versions drift
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=${RUN_SCRIPT}
EOF

cat > "${TIMER_PATH}" <<EOF
[Unit]
Description=Run rebuild-opencode-docker.sh every 15 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=15min
Persistent=true
Unit=${SERVICE_NAME}

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now "${TIMER_NAME}"

echo "Installed ${SERVICE_NAME} and ${TIMER_NAME}"
