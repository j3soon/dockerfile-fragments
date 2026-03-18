# Dockerfile Fragments

This repository contains a collection of small, focused Docker images for common development, remote access, GUI, and AI-agent workflows.

Each subdirectory provides a standalone `Dockerfile` together with a local `README.md`. The images are intentionally simple and composable in concept: some are useful on their own, while [`all-in-one`](all-in-one) bundles several fragments into a single environment.

> This README is AI generated, while the individual dockerfiles are not.

## Included Images

| Directory | Purpose | Notes |
|-----------|---------|-------|
| [`common`](common) | Common CLI tools | Includes utilities such as `git`, `tmux`, `vim`, `wget`, and `tree`. |
| [`x11`](x11) | Minimal X11 client container | Useful for testing GUI forwarding from a container. |
| [`opengl`](opengl) | OpenGL runtime utilities | NVIDIA-oriented GUI/OpenGL container. |
| [`vulkan`](vulkan) | Vulkan runtime utilities | Includes Vulkan tools and NVIDIA runtime configuration. |
| [`openssh-server`](openssh-server) | SSH server container | Exposes an SSH daemon for remote shell access. |
| [`tigervnc`](tigervnc) | TigerVNC desktop container | XFCE desktop with Firefox and VNC server. |
| [`novnc`](novnc) | Browser-based VNC client | Connects to a VNC server through noVNC. |
| [`code-server`](code-server) | Browser-based VS Code | Runs `code-server` behind a configurable password. |
| [`jupyter-lab`](jupyter-lab) | JupyterLab server | Token-based notebook server. |
| [`codex`](codex) | OpenAI Codex CLI container | Ubuntu-based Codex CLI environment with a few extra tools. |
| [`claude-code`](claude-code) | Claude Code CLI container | Minimal container for Anthropic Claude Code. |
| [`opencode`](opencode) | OpenCode CLI container | Minimal container for OpenCode. |
| [`all-in-one`](all-in-one) | Combined remote dev environment | Merges common tools, GUI, VNC, SSH, code-server, and JupyterLab. |

## Quick Start

Choose a directory, build the image there, and run it according to its local README.

For example:

```sh
cd codex
docker build -t codex .
docker run --rm -it codex
```

For a browser-based development service:

```sh
cd code-server
docker build -t code-server --build-arg CODE_SERVER_PASSWORD=changeme .
docker run --rm -it -p 8080:8080 code-server
```

For the combined environment:

```sh
cd all-in-one
docker build -t all-in-one .
docker run --rm -it --gpus all \
  -p 2222:22 \
  -p 5900:5900 \
  -p 6080:6080 \
  -p 8080:8080 \
  -p 8888:8888 \
  all-in-one
```

## Choosing An Image

- Use [`common`](common) when you just want a minimal Ubuntu container with familiar terminal tools.
- Use [`codex`](codex), [`claude-code`](claude-code), or [`opencode`](opencode) for containerized AI coding assistants.
- Use [`code-server`](code-server) or [`jupyter-lab`](jupyter-lab) for browser-accessible development environments.
- Use [`openssh-server`](openssh-server), [`tigervnc`](tigervnc), and [`novnc`](novnc) for remote access workflows.
- Use [`x11`](x11), [`opengl`](opengl), and [`vulkan`](vulkan) for GUI and graphics-related container experiments.
- Use [`all-in-one`](all-in-one) if you want one container that exposes several of the above services together.

## Requirements

The exact requirements depend on the image you choose, but in practice you will typically need:

- [Docker](https://docs.docker.com/get-started/get-docker/)
- NVIDIA Container Toolkit for [`opengl`](opengl), [`vulkan`](vulkan), and typical [`all-in-one`](all-in-one) GPU usage
- X11 access on the host for [`x11`](x11), [`opengl`](opengl), and some local GUI workflows

Some example commands in the per-image READMEs use `pwgen` to generate passwords. That tool is only needed if you want to follow those examples exactly.

## Platform Support

- All images in this repository are tested on `amd64`.
- [`codex`](codex) is additionally verified on `arm64`.

## Repository Layout

This repo is flat by design:

- each fragment lives in its own directory
- each fragment has its own `Dockerfile`
- most fragments also include a small usage-oriented `README.md`
- `all-in-one` is the only image here that intentionally combines multiple fragments into one container

The individual Dockerfiles do not currently share a formal build system or templating layer. If you want to reuse pieces across images, the existing directories are best treated as reference implementations.

## Notes

- Most images use `ubuntu:22.04` as the base image.
- Several service-oriented images use `supervisord` to keep long-running processes alive.
- Some images accept credentials through Docker build arguments. Review the relevant subdirectory README before building.
- The AI CLI images are intentionally minimal and leave authentication persistence to bind mounts on the host.

## References

- [Docker Documentation](https://docs.docker.com/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/)
- [code-server](https://github.com/coder/code-server)
- [JupyterLab](https://jupyter.org/)
- [OpenAI Codex CLI](https://developers.openai.com/codex/cli/)
- [Claude Code](https://code.claude.com/docs/en/setup)
- [OpenCode](https://opencode.ai/)
