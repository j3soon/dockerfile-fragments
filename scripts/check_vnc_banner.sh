#!/bin/bash
# Usage: check_vnc_banner.sh <host> <port>
# Reads the VNC RFB protocol banner. Retries for up to ~10s to handle slow startup.
HOST=$1
PORT=${2:-5900}
for i in $(seq 1 10); do
    BANNER=$(timeout 3 bash -c \
        "exec 3<>/dev/tcp/${HOST}/${PORT}; head -c 12 <&3" 2>/dev/null \
        | tr -dc '[:print:]')
    if echo "$BANNER" | grep -q "^RFB"; then
        echo "banner: ${BANNER}"
        exit 0
    fi
    sleep 1
done
echo "no RFB banner after retries" >&2
exit 1
