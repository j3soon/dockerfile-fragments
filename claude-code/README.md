# Claude Code

Build and run the container:

```sh
docker build -t claude-code .
docker run --rm -it claude-code
# or persist login across containers
mkdir -p ~/docker/.claude
docker run --rm -it --network=host \
  -v ~/docker/.claude:/root/.claude \
  -v ~/docker/.claude.json:/root/.claude.json \
  claude-code
```

In the container, run:

```sh
claude --version
```

or with with skip permissions mode if you know what you're doing:

```sh
claude --dangerously-skip-permissions
```
