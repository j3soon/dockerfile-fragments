#!/bin/bash
# validate.sh - Build and validate dockerfile-fragments images
#
# Usage:
#   ./validate.sh [FRAGMENT] [VERSION]
#   FRAGMENT : fragment name, or "all" (default: all)
#   VERSION  : 22, 24, or compare (default: 24)
#
# Examples:
#   ./validate.sh all compare
#   ./validate.sh jupyter-lab 24
#   ./validate.sh tigervnc compare
#
# Note: opengl and vulkan checks require NVIDIA GPU + container runtime.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAGMENTS_DIR="$(dirname "$SCRIPT_DIR")"
FRAGMENT=${1:-all}
VERSION=${2:-24}

PASS=0
FAIL=0
CONTAINER=""

cleanup() {
    if [ -n "$CONTAINER" ]; then
        docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
        CONTAINER=""
    fi
}
trap cleanup EXIT INT TERM

ok()   { echo "  [PASS] $*"; PASS=$((PASS + 1)); }
fail() { echo "  [FAIL] $*"; FAIL=$((FAIL + 1)); }

run_check() {
    local label=$1; shift
    local out rc
    out=$("$@" 2>&1) && rc=0 || rc=$?
    if [ "$rc" -eq 0 ]; then
        ok "$label: $(echo "$out" | head -1)"
    else
        fail "$label: $(echo "$out" | head -1)"
    fi
}

start_container() {
    # Usage: start_container <tag> [docker-run-args...]
    # Sets CONTAINER; fails loudly if docker run fails (e.g. port already bound).
    local tag=$1; shift
    CONTAINER=$(docker run -d "$@" "$tag" 2>/tmp/docker_run_err) || {
        fail "docker run failed: $(cat /tmp/docker_run_err | head -1)"
        CONTAINER=""
        return 1
    }
    [ -n "$CONTAINER" ] || { fail "docker run produced no container ID"; return 1; }
}

wait_tcp() {
    local host=$1 port=$2
    echo "  Waiting for ${host}:${port}..."
    for i in $(seq 1 30); do
        timeout 1 bash -c "echo >/dev/tcp/${host}/${port}" 2>/dev/null && return 0
        sleep 1
    done
    fail "timeout waiting for ${host}:${port}"; return 1
}

get_frag_dir() {
    case $1 in
        codex-user)   echo "codex" ;;
        opencode-user) echo "opencode" ;;
        *)            echo "$1" ;;
    esac
}

get_dockerfile() {
    local name=$1 ver=$2
    case "${name}:${ver}" in
        codex-user:22|opencode-user:22) echo "Dockerfile.user" ;;
        codex-user:24|opencode-user:24) echo "Dockerfile_ubuntu_24.user" ;;
        *:22)                           echo "Dockerfile" ;;
        *:24)                           echo "Dockerfile_ubuntu_24" ;;
    esac
}

build_image() {
    local name=$1 ver=$2
    local tag="j3soon/fragment-${name}:ubuntu${ver}"
    local dir dockerfile
    dir=$(get_frag_dir "$name")
    dockerfile=$(get_dockerfile "$name" "$ver")
    echo "Building ${tag}..."
    (cd "${FRAGMENTS_DIR}/${dir}" && docker build -q -t "$tag" -f "$dockerfile" .) \
        && echo "Built ${tag}" \
        || { fail "build failed: ${tag}"; return 1; }
}

validate_fragment() {
    local name=$1 ver=$2
    local tag="j3soon/fragment-${name}:ubuntu${ver}"
    echo ""
    echo "=== ${tag} ==="

    case $name in
    common)
        run_check "git"   docker run --rm "$tag" git --version
        run_check "curl"  docker run --rm "$tag" bash -c "curl --version | head -1"
        run_check "tmux"  docker run --rm "$tag" tmux -V
        run_check "vim"   docker run --rm "$tag" bash -c "vim --version | head -1"
        run_check "ssh"   docker run --rm "$tag" bash -c "ssh -V 2>&1"
        run_check "wget"  docker run --rm "$tag" bash -c "wget --version 2>&1 | head -1"
        ;;

    x11)
        # Install Xvfb inside container for the test (not part of the fragment itself)
        run_check "xdpyinfo via Xvfb" docker run --rm "$tag" bash -c "
            apt-get update -qq >/dev/null 2>&1 &&
            apt-get install -y -qq xvfb >/dev/null 2>&1 &&
            (Xvfb :99 -screen 0 800x600x24 >/dev/null 2>&1 &) &&
            sleep 1 &&
            DISPLAY=:99 xdpyinfo 2>&1 | grep -m1 'name of display'"
        ;;

    opengl)
        # Requires NVIDIA GPU + container runtime
        # Check ENV from image config (runtime overrides NVIDIA_VISIBLE_DEVICES to 'void' without --gpus)
        run_check "NVIDIA_VISIBLE_DEVICES"    bash -c "docker inspect $tag --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -q '^NVIDIA_VISIBLE_DEVICES=all$' && echo all"
        run_check "NVIDIA_DRIVER_CAPABILITIES" bash -c "docker inspect $tag --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -q '^NVIDIA_DRIVER_CAPABILITIES=all$' && echo all"
        run_check "glxinfo (GPU)"  docker run --rm --gpus all "$tag" bash -c "
            apt-get update -qq >/dev/null 2>&1 &&
            apt-get install -y -qq xvfb >/dev/null 2>&1 &&
            (Xvfb :99 -screen 0 800x600x24 >/dev/null 2>&1 &) &&
            sleep 1 &&
            DISPLAY=:99 glxinfo -B 2>&1 | grep -m1 'OpenGL'"
        ;;

    vulkan)
        # Requires NVIDIA GPU + container runtime
        run_check "NVIDIA_DRIVER_CAPABILITIES" bash -c "docker inspect $tag --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -q '^NVIDIA_DRIVER_CAPABILITIES=all$' && echo all"
        run_check "vulkaninfo (GPU)" docker run --rm --gpus all "$tag" bash -c "vulkaninfo --summary 2>&1 | grep -m1 -E 'GPU|Vulkan'"
        ;;

    openssh-server)
        start_container "$tag" -p 12222:22 || return
        wait_tcp localhost 12222
        run_check "SSH banner" "$SCRIPT_DIR/check_ssh_banner.sh" localhost 12222
        cleanup
        ;;

    tigervnc)
        start_container "$tag" -p 15900:5900 || return
        wait_tcp localhost 15900
        sleep 2  # allow XFCE to initialize
        run_check "VNC banner"     "$SCRIPT_DIR/check_vnc_banner.sh"     localhost 15900
        run_check "VNC screenshot" "$SCRIPT_DIR/check_vnc_screenshot.sh" localhost 15900 \
            "/tmp/vnc_${name}_${ver}.png"
        cleanup
        ;;

    novnc)
        start_container "$tag" -p 16080:6080 || return
        wait_tcp localhost 16080
        run_check "noVNC HTTP" "$SCRIPT_DIR/check_http.sh" localhost 16080 / "noVNC"
        cleanup
        ;;

    jupyter-lab)
        start_container "$tag" -p 18888:8888 || return
        wait_tcp localhost 18888
        run_check "Jupyter HTTP"  "$SCRIPT_DIR/check_http.sh" localhost 18888 /api/ "version"
        SHELL_VAR=$(docker exec "$CONTAINER" env 2>/dev/null | grep "^SHELL=")
        if echo "$SHELL_VAR" | grep -q bash; then
            ok "default shell: ${SHELL_VAR}"
        else
            fail "default shell not bash: ${SHELL_VAR}"
        fi
        cleanup
        ;;

    code-server)
        start_container "$tag" -p 18080:8080 || return
        wait_tcp localhost 18080
        run_check "code-server HTTP" "$SCRIPT_DIR/check_http.sh" localhost 18080 / "code-server"
        cleanup
        ;;

    all-in-one)
        start_container "$tag" \
            -p 12222:22 -p 15900:5900 -p 16080:6080 -p 18888:8888 -p 18080:8080 || return
        wait_tcp localhost 12222
        wait_tcp localhost 15900
        wait_tcp localhost 18888
        run_check "SSH banner"       "$SCRIPT_DIR/check_ssh_banner.sh" localhost 12222
        run_check "noVNC HTTP"       "$SCRIPT_DIR/check_http.sh"       localhost 16080 / "noVNC"
        run_check "Jupyter HTTP"     "$SCRIPT_DIR/check_http.sh"       localhost 18888 /api/ "version"
        run_check "code-server HTTP" "$SCRIPT_DIR/check_http.sh"       localhost 18080 / "code-server"
        SHELL_VAR=$(docker exec "$CONTAINER" env 2>/dev/null | grep "^SHELL=")
        if echo "$SHELL_VAR" | grep -q bash; then
            ok "Jupyter default shell: ${SHELL_VAR}"
        else
            fail "Jupyter default shell not bash: ${SHELL_VAR}"
        fi
        # VNC screenshot last — gives XFCE the most time to load
        sleep 2
        run_check "VNC banner"       "$SCRIPT_DIR/check_vnc_banner.sh"     localhost 15900
        run_check "VNC screenshot"   "$SCRIPT_DIR/check_vnc_screenshot.sh" localhost 15900 \
            "/tmp/vnc_all_in_one_${ver}.png"
        cleanup
        ;;

    claude-code)
        run_check "claude" docker run --rm "$tag" claude --version
        ;;

    codex|codex-user)
        run_check "codex" docker run --rm "$tag" codex --version
        ;;

    opencode|opencode-user)
        run_check "opencode" docker run --rm "$tag" opencode --version
        ;;

    *)
        fail "unknown fragment: ${name}"
        ;;
    esac
}

ALL_FRAGMENTS="common x11 opengl vulkan openssh-server tigervnc novnc jupyter-lab code-server all-in-one claude-code codex codex-user opencode opencode-user"

run_version() {
    local ver=$1
    local frags
    [ "$FRAGMENT" = "all" ] && frags="$ALL_FRAGMENTS" || frags="$FRAGMENT"
    for f in $frags; do
        build_image "$f" "$ver" || continue
        validate_fragment "$f" "$ver"
    done
}

if [ "$VERSION" = "compare" ]; then
    echo "==============================="
    echo "Ubuntu 22"
    echo "==============================="
    run_version 22
    echo ""
    echo "==============================="
    echo "Ubuntu 24"
    echo "==============================="
    run_version 24
else
    run_version "$VERSION"
fi

echo ""
echo "================================"
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ]
