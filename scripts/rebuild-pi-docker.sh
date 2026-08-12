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

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is not installed or not in PATH" >&2
  exit 1
fi

latest_pi_version() {
  npm show @earendil-works/pi-coding-agent version
}

rebuild() {
  local image_name="$1"

  cd "${REPO_ROOT}/pi"
  echo "rebuilding ${image_name} with --no-cache"

  if [[ "${image_name}" == "pi-user" ]]; then
    docker build -f Dockerfile.user --build-arg USER_UID="$(id -u)" -t pi-user --no-cache .
  else
    docker build -t pi --no-cache .
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
    docker run --rm -i "${image_name}" sh -lc "pi --version" 2>/dev/null || true
  )"
  latest_version="$(latest_pi_version)"

  if [[ -z "${local_version}" || "${local_version}" != "${latest_version}" ]]; then
    echo "${image_name} version mismatch: local=${local_version:-missing} latest=${latest_version}"
    rebuild "${image_name}"
  else
    echo "${image_name} image is current: ${local_version}"
  fi
}

check_image pi
check_image pi-user
