# Claude Code

Build and run the container:

```sh
docker build -t claude-code .
docker run --rm -it claude-code
```

Or persist login across containers:

```sh
touch ~/docker/.claude.json
mkdir -p ~/docker/.claude
docker run --rm -it --network=host -w /workspace \
  -v ~/docker/.claude/:/root/.claude \
  -v ~/docker/.claude.json:/root/.claude.json \
  -v $(pwd):/workspace \
  claude-code
```

> Note: the `--network=host` flag can be removed if you are using device code login. The `-v $(pwd):/workspace` flag is optional but allows you to access your current directory from within the container, which can be useful for working with local files. The `-w /workspace` flag is also optional and starts you in that mounted directory.

In the container, run:

```sh
claude --version
```

or with with skip permissions mode if you know what you're doing:

```sh
claude --dangerously-skip-permissions
```

References:

- [Set up Claude Code](https://code.claude.com/docs/en/setup)
- [Claude Code settings](https://code.claude.com/docs/en/settings)
