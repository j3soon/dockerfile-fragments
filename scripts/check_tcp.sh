#!/bin/bash
# Usage: check_tcp.sh <host> <port>
# Exits 0 if the TCP port is reachable.
HOST=$1
PORT=$2
if timeout 5 bash -c "echo >/dev/tcp/${HOST}/${PORT}" 2>/dev/null; then
    echo "open: ${HOST}:${PORT}"
else
    echo "unreachable: ${HOST}:${PORT}" >&2
    exit 1
fi
