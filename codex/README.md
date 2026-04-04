# Codex

Build and run the container:

```sh
docker build -t codex .
docker run --rm -it codex
```

Or persist login/config across containers:

```sh
mkdir -p ~/docker/.codex
docker run --rm -it --network=host -w /workspace \
  -v ~/docker/.codex/:/root/.codex \
  -v $(pwd):/workspace \
  codex
```

> Note: the `--network=host` flag can be removed if you are using device code login. The `-v $(pwd):/workspace` flag is optional but allows you to access your current directory from within the container, which can be useful for local files. The `-w /workspace` flag is also optional and starts you in that mounted directory.

## Non-root Variant

If you want the container to start as a non-root user, use `Dockerfile.user` instead. It creates a `codex` user with UID `USER_UID` (default: `1000`) and grants password‑less sudo.

Build it with your host UID:

```sh
docker build -f Dockerfile.user \
  --build-arg USER_UID="$(id -u)" \
  -t codex-user .
```

Run it with a mounted workspace:

```sh
mkdir -p ~/docker/.codex
docker run --rm -it --network=host -w /workspace \
  -v ~/docker/.codex/:/home/codex/.codex \
  -v $(pwd):/workspace \
  codex-user
```

> This variant ensures files created in the mounted workspace match your host user ID.
> If you hit permission errors on the mounted config directories, fix its ownership on the host first:
>
> ```sh
> chown -R "$(id -u):$(id -g)" ~/docker/.codex
> ```

In the container, run:

```sh
codex --version
```

or with with yolo mode if you know what you're doing:

```sh
codex --yolo
```

References:

- [Codex CLI](https://developers.openai.com/codex/cli)
- [Authentication](https://developers.openai.com/codex/auth)
- [Codex overview](https://openai.com/codex)
- [Config basics](https://developers.openai.com/codex/config-basic/)
- [Security](https://developers.openai.com/codex/security/)
- [Codex Source Code on GitHub](https://github.com/openai/codex)
