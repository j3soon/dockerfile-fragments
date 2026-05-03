#!/usr/bin/env bash

set -euo pipefail

# Get the directory of this script.
# Reference: https://stackoverflow.com/q/59895
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed or not in PATH" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is not installed or not in PATH" >&2
  exit 1
fi

latest_opencode_version() {
  local latest_version

  latest_version="$(
    curl -fsSL https://api.github.com/repos/anomalyco/opencode/releases/latest \
      | sed -n 's/.*"tag_name":[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p' \
      | head -n 1
  )"

  if [[ -z "${latest_version}" ]]; then
    echo "failed to determine latest OpenCode version" >&2
    exit 1
  fi

  printf '%s\n' "${latest_version}"
}

rebuild() {
  local image_name="$1"

  cd "${REPO_ROOT}/opencode"
  echo "rebuilding ${image_name} with --no-cache"

  if [[ "${image_name}" == "opencode-user" ]]; then
    docker build -f Dockerfile.user --build-arg USER_UID="$(id -u)" -t opencode-user --no-cache .
  else
    docker build -t opencode --no-cache .
  fi
}

check_image() {
  local image_name="$1"

  if ! docker image inspect "${image_name}" >/dev/null 2>&1; then
    echo "image ${image_name} does not exist locally"
    rebuild "${image_name}"
    return
  fi

  local local_version
  local latest_version

  local_version="$(
    docker run --rm -i "${image_name}" sh -lc "opencode --version" 2>/dev/null || true
  )"
  latest_version="$(latest_opencode_version)"

  if [[ -z "${local_version}" || "${local_version}" != "${latest_version}" ]]; then
    echo "${image_name} version mismatch: local=${local_version:-missing} latest=${latest_version}"
    rebuild "${image_name}"
  else
    echo "${image_name} image is current: ${local_version}"
  fi
}

check_image opencode
check_image opencode-user
