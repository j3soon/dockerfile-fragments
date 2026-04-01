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

load_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

  if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
    # shellcheck disable=SC1090
    . "${NVM_DIR}/nvm.sh"

    if command -v nvm >/dev/null 2>&1; then
      nvm use default >/dev/null 2>&1 || true
    fi
  fi
}

upgrade_nvm_codex_versions() {
  local latest_version
  local node_dir
  local npm_bin
  local codex_bin
  local local_version
  local found=0

  latest_version="$(npm show @openai/codex version)"

  for node_dir in "${NVM_DIR}/versions/node"/*; do
    [[ -d "${node_dir}" ]] || continue

    npm_bin="${node_dir}/bin/npm"
    codex_bin="${node_dir}/bin/codex"

    [[ -x "${npm_bin}" ]] || continue
    [[ -x "${codex_bin}" ]] || continue

    found=1
    local_version="$("${codex_bin}" --version | cut -d' ' -f2)"

    if [[ -z "${local_version}" || "${local_version}" != "${latest_version}" ]]; then
      echo "host codex version mismatch in ${node_dir##*/}: local=${local_version:-missing} latest=${latest_version}"
      "${npm_bin}" install -g @openai/codex
    else
      echo "host codex is current in ${node_dir##*/}: ${local_version}"
    fi
  done

  return "${found}"
}

check_host_codex() {
  load_nvm

  if ! command -v npm >/dev/null 2>&1; then
    echo "host npm is not installed or not in PATH" >&2
    exit 1
  fi

  if upgrade_nvm_codex_versions; then
    return
  fi

  echo "host codex is not installed in any nvm Node version; skipping"
}

rebuild() {
  local image_name="$1"

  cd "${REPO_ROOT}/codex"
  echo "rebuilding ${image_name} with --no-cache"

  if [[ "${image_name}" == "codex-user" ]]; then
    docker build -f Dockerfile.user --build-arg USER_UID="$(id -u)" -t codex-user --no-cache .
  else
    docker build -t codex --no-cache .
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
    docker run --rm -i "${image_name}" sh -lc "codex --version | cut -d' ' -f2"
  )"
  latest_version="$(
    docker run --rm -i "${image_name}" sh -lc "npm show @openai/codex version"
  )"

  if [[ -z "${local_version}" || "${local_version}" != "${latest_version}" ]]; then
    echo "${image_name} version mismatch: local=${local_version:-missing} latest=${latest_version}"
    rebuild "${image_name}"
  else
    echo "${image_name} image is current: ${local_version}"
  fi
}

check_image codex
check_image codex-user
check_host_codex
