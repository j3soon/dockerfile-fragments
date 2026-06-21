#!/bin/bash
# Usage: check_ssh_banner.sh <host> <port>
# Reads the SSH protocol banner. Retries for up to ~10s to handle slow startup.
HOST=$1
PORT=${2:-22}
for i in $(seq 1 10); do
    BANNER=$(timeout 3 bash -c \
        "exec 3<>/dev/tcp/${HOST}/${PORT}; head -c 40 <&3" 2>/dev/null \
        | tr -d '\r\n')
    if echo "$BANNER" | grep -q "^SSH-"; then
        echo "banner: ${BANNER}"
        exit 0
    fi
    sleep 1
done
echo "no SSH banner after retries" >&2
exit 1
