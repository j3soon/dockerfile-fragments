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

OpenCode can be configured to use local language models. Inside the container you can download and run the official setup script:

```sh
curl -fsSL https://raw.githubusercontent.com/j3soon/local-llm-notes/refs/heads/main/examples/basic-secure-api/scripts/setup_opencode.sh -o /tmp/setup_opencode.sh
chmod +x /tmp/setup_opencode.sh
/tmp/setup_opencode.sh
```

The script installs the necessary dependencies and sets the `OPENCODE_MODEL` environment variable to point to the local model. After running it, you can start OpenCode as usual and it will use the locally‑installed model.

References:

- [OpenCode](https://opencode.ai/)
- [OpenCode CLI docs](https://opencode.ai/docs/cli/)
- [OpenCode install docs](https://opencode.ai/install)
- [OpenCode source code on GitHub](https://github.com/anomalyco/opencode)
- [OpenCode config locations](https://opencode.ai/docs/config/#locations)
