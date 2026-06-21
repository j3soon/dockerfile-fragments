# Scripts

## Check `codex` and optionally rebuild every 15 minutes

This script checks local Docker images `codex` and `codex-user`, and also checks host `codex` if it is installed. If versions do not match the latest published `@openai/codex` package, it rebuilds the images and upgrades host `codex`.

Run it manually:

```sh
scripts/rebuild-codex-docker.sh
```

Install the user timer:

```sh
scripts/install-codex-systemd-timer.sh
```

View timer status:

```sh
systemctl --user status rebuild-codex-docker.timer
```

View service logs:

```sh
journalctl --user -u rebuild-codex-docker.service
```

Follow service logs:

```sh
journalctl --user -fu rebuild-codex-docker.service
```

## Check `opencode` and optionally rebuild every 15 minutes

This script checks local Docker images `opencode` and `opencode-user`. If versions do not match the latest published OpenCode release, it rebuilds the images.

Run it manually:

```sh
scripts/rebuild-opencode-docker.sh
```

Install the user timer:

```sh
scripts/install-opencode-systemd-timer.sh
```

View timer status:

```sh
systemctl --user status rebuild-opencode-docker.timer
```

View service logs:

```sh
journalctl --user -u rebuild-opencode-docker.service
```

Follow service logs:

```sh
journalctl --user -fu rebuild-opencode-docker.service
```

## Build and validate fragment images

`validate.sh` builds a fragment image and runs service checks against it.

```sh
./validate.sh [FRAGMENT] [VERSION]
```

- `FRAGMENT` — fragment name or `all` (default: `all`)
- `VERSION` — `22`, `24`, or `compare` (default: `24`)

Examples:

```sh
scripts/validate.sh all compare          # build and validate all fragments on both Ubuntu versions
scripts/validate.sh jupyter-lab compare  # compare one fragment side by side
scripts/validate.sh tigervnc 24          # single fragment, Ubuntu 24 only
```

Built image tags: `j3soon/fragment-<name>:ubuntu22` / `j3soon/fragment-<name>:ubuntu24`

Host ports used during testing (prefixed with `1` to avoid conflicts with common host services):

| Service     | Container | Host  |
|-------------|-----------|-------|
| SSH         | 22        | 12222 |
| VNC         | 5900      | 15900 |
| noVNC       | 6080      | 16080 |
| Jupyter Lab | 8888      | 18888 |
| code-server | 8080      | 18080 |

> `opengl` and `vulkan` checks require an NVIDIA GPU and the NVIDIA container runtime.

### Standalone check utilities

Each `check_*.sh` script accepts `<host> <port>` and can be used against any endpoint — local container, remote host, or K8s service. All retry for up to ~10 s to handle slow service startup.

```sh
scripts/check_tcp.sh <host> <port>
scripts/check_ssh_banner.sh <host> <port>
scripts/check_vnc_banner.sh <host> <port>
scripts/check_http.sh <host> <port> [path] [grep_string]
scripts/check_vnc_screenshot.sh <host> <port> [output.png]
```

`check_vnc_screenshot.sh` uses `vncdotool` inside a `python:3-slim` container — no VNC client needed on the host.
