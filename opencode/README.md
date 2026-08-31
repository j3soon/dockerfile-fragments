# OpenCode

Build and run the container:

```sh
docker build -t opencode .
docker run --rm -it opencode
```

Or persist login/config across containers:

```sh
mkdir -p ~/docker/opencode/.config/opencode
mkdir -p ~/docker/opencode/.local/share/opencode

docker run --rm -it --network=host -w /workspace \
  -v ~/docker/opencode/.config/opencode:/root/.config/opencode \
  -v ~/docker/opencode/.local/share/opencode:/root/.local/share/opencode \
  -v $(pwd):/workspace \
  opencode
```

> Note: the `--network=host` flag can be removed if you are using device code login. The `-v $(pwd):/workspace` flag is optional but allows you to access your current directory from within the container, which can be useful for local files. The `-w /workspace` flag is also optional and starts you in that mounted directory.

## Non-root Variant

If you want the container to start as a non-root user, use `Dockerfile.user` instead. It creates an `opencode` user with UID `USER_UID` (default: `1000`) and grants password‑less sudo.

Build it with your host UID:

```sh
docker build -f Dockerfile.user \
  --build-arg USER_UID="$(id -u)" \
  -t opencode-user .
```

Run it with a mounted workspace:

```sh
mkdir -p ~/docker/opencode/.config/opencode
mkdir -p ~/docker/opencode/.local/share/opencode

docker run --rm -it --network=host -w /workspace \
  -v ~/docker/opencode/.config/opencode:/home/opencode/.config/opencode \
  -v ~/docker/opencode/.local/share/opencode:/home/opencode/.local/share/opencode \
  -v $(pwd):/workspace \
  opencode-user
```

> This variant ensures files created in the mounted workspace match your host user ID.
> If you hit permission errors on the mounted config directories, fix its ownership on the host first:
>
> ```sh
> chown -R "$(id -u):$(id -g)" ~/docker/opencode/.config/opencode
> chown -R "$(id -u):$(id -g)" ~/docker/opencode/.local/share/opencode
> ```

In the container, run:

```sh
opencode --version
```

Start the TUI:

```sh
opencode
```

Or run non-interactive mode:

```sh
opencode run "Explain how closures work in JavaScript"
```

## Configuring Local Models

OpenCode can be configured to use a local, self-hosted language model. Setup scripts for both supported topologies live in [j3soon/local-llm-notes/examples/basic-secure-api/scripts](https://github.com/j3soon/local-llm-notes/tree/main/examples/basic-secure-api/scripts).

### Remote self-hosted server

To point OpenCode at a self-hosted llama.cpp server (for example, one deployed with the [basic-secure-api example](https://github.com/j3soon/local-llm-notes/blob/main/examples/basic-secure-api/README.md)), run the interactive setup script inside the container:

```sh
curl -fsSL https://raw.githubusercontent.com/j3soon/local-llm-notes/refs/heads/main/examples/basic-secure-api/scripts/setup_opencode.sh -o /tmp/setup_opencode.sh
chmod +x /tmp/setup_opencode.sh
/tmp/setup_opencode.sh
```

The script prompts for a provider ID (default `llm-remote`), the server URL, and an API key, then writes an OpenAI-compatible provider to `~/.config/opencode/opencode.json` and sets the chosen model as the default. Start OpenCode as usual afterwards and it will use the configured model.

### Offline container on the local Docker network

You can also self-host the model separately and launch OpenCode in an offline container on the same internal Docker network. After following the local-only deployment in the [basic-secure-api example](https://github.com/j3soon/local-llm-notes/blob/main/examples/basic-secure-api/README.md), run the local setup script inside the container. It configures the `llm-local` provider to reach the model at `http://llama-cpp:37000/v1` without an API key:

```sh
curl -fsSL https://raw.githubusercontent.com/j3soon/local-llm-notes/refs/heads/main/examples/basic-secure-api/scripts/setup_opencode_local.sh -o /tmp/setup_opencode_local.sh
chmod +x /tmp/setup_opencode_local.sh
/tmp/setup_opencode_local.sh
```

Then start OpenCode on the same internal Docker network:

```sh
docker run --rm -it --network=local-llm-internal -w /workspace \
  -v ~/docker/opencode/.config/opencode:/root/.config/opencode \
  -v ~/docker/opencode/.local/share/opencode:/root/.local/share/opencode \
  -v $(pwd):/workspace \
  opencode
```

As a sanity check, ask the agent to access the web, such as:

```sh
opencode run "Use the web to find the latest stable Node.js release version."
```

This should fail because `local-llm-internal` is an internal Docker network without outbound internet access.

References:

- [OpenCode](https://opencode.ai/)
- [OpenCode CLI docs](https://opencode.ai/docs/cli/)
- [OpenCode install docs](https://opencode.ai/install)
- [OpenCode source code on GitHub](https://github.com/anomalyco/opencode)
- [OpenCode config locations](https://opencode.ai/docs/config/#locations)
- [Local LLM notes: basic secure API](https://github.com/j3soon/local-llm-notes/blob/main/examples/basic-secure-api/README.md)
