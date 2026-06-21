#!/bin/bash
# Usage: check_vnc_screenshot.sh <host> <port> [output_file]
# Takes a VNC screenshot using vncdotool inside a container.
# Exits 0 and saves the screenshot on success.
HOST=$1
PORT=${2:-5900}
OUTPUT=${3:-/tmp/vnc_screenshot.png}
OUT_DIR=$(cd "$(dirname "$OUTPUT")" && pwd)
OUT_FILE=$(basename "$OUTPUT")

PYFILE=$(mktemp /tmp/vnc_XXXXXX.py)
# vncdotool server string: host::port uses explicit port (double-colon convention)
cat > "$PYFILE" <<PYEOF
import os, sys, vncdotool.api
c = vncdotool.api.connect('${HOST}::${PORT}', password='')
c.captureScreen('/out/${OUT_FILE}')
print('screenshot: ${OUTPUT}', flush=True)
os._exit(0)  # bypass twisted reactor teardown which hangs on some TigerVNC versions
PYEOF

docker run --rm --network host \
    -v "${OUT_DIR}:/out" \
    -v "${PYFILE}:/check.py:ro" \
    python:3-slim bash -c "pip install -q --root-user-action=ignore vncdotool && timeout 30 python3 /check.py"
RC=$?
rm -f "$PYFILE"
exit $RC
