#!/bin/bash
# Usage: check_http.sh <host> <port> [path] [grep_string]
# Exits 0 on 2xx response, optionally verifying grep_string is present.
# Retries for up to ~10s to handle slow service startup.
HOST=$1
PORT=$2
PATH_=${3:-/}
GREP=${4:-}
URL="http://${HOST}:${PORT}${PATH_}"
for i in $(seq 1 10); do
    BODY=$(curl -sfL --max-time 5 "$URL" 2>/dev/null) && {
        if [ -n "$GREP" ] && ! echo "$BODY" | grep -qi "$GREP"; then
            echo "missing '${GREP}' in response from $URL" >&2
            exit 1
        fi
        echo "ok: ${URL}${GREP:+ (found '${GREP}')}"
        exit 0
    }
    sleep 1
done
echo "unreachable after retries: $URL" >&2
exit 1
