# Codex

Build and run the container:

```sh
docker build -t codex .
docker run --rm -it codex
# or persist login across containers
mkdir -p ~/docker/.codex
docker run --rm -it --network=host \
  -v ~/docker/.codex/:/root/.codex \
  -v $(pwd):/workspace \
  codex
```

> Note: the `--network=host` flag can be removed if you are using device code login. The `-v $(pwd):/workspace` flag is optional but allows you to access your current directory from within the container, which can be useful for working with local files.

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
