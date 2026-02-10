# Codex

Build and run the container:

```sh
docker build -t codex .
docker run --rm -it codex
# or persist login across containers
mkdir -p ~/docker/.codex
docker run --rm -it --network=host \
  -v ~/docker/.codex:/root/.codex \
  codex
```

In the container, run:

```sh
codex --version
```

or with with yolo mode if you know what you're doing:

```sh
codex --yolo
```
