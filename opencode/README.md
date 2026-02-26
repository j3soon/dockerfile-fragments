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

> Note: the `--network=host` flag can be removed if you do not need host networking. The `-v $(pwd):/workspace` flag is optional but allows you to access your current directory from within the container, which can be useful for working with local files. The `-w /workspace` flag is also optional and starts you in that mounted directory.

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

References:

- [OpenCode](https://opencode.ai/)
- [OpenCode CLI docs](https://opencode.ai/docs/cli/)
- [OpenCode install docs](https://opencode.ai/install)
- [OpenCode source code on GitHub](https://github.com/anomalyco/opencode)
- [OpenCode config locations](https://opencode.ai/docs/config/#locations)

Known issues:

- Model selection doesn't seem to persist across runs after container restart. Potentially related: https://github.com/anomalyco/opencode/issues/10407.
