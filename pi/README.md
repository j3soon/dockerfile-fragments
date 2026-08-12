# Pi Coding Agent

Build and run the container:

```sh
docker build -t pi .
docker run --rm -it pi
```

Or persist credentials, settings, sessions, and installed Pi packages across containers:

```sh
mkdir -p ~/docker/pi/agent
docker run --rm -it -w /workspace \
  -v ~/docker/pi/agent:/root/.pi/agent \
  -v "$(pwd)":/workspace \
  pi
```

The workspace mount is optional. Pi runs with file and shell tools in its current directory, so mounting a project at `/workspace` lets it work on that project. Pi stores its global state under `~/.pi/agent`, including `auth.json`, `settings.json`, `models.json`, sessions, extensions, skills, prompts, and themes.

## Non-root Variant

If you want the container to start as a non-root user, use `Dockerfile.user` instead. It creates a `pi` user with UID `USER_UID` (default: `1000`) and grants passwordless sudo.

Build it with your host UID:

```sh
docker build -f Dockerfile.user \
  --build-arg USER_UID="$(id -u)" \
  -t pi-user .
```

Run it with a mounted workspace:

```sh
mkdir -p ~/docker/pi/agent
docker run --rm -it -w /workspace \
  -v ~/docker/pi/agent:/home/pi/.pi/agent \
  -v "$(pwd)":/workspace \
  pi-user
```

This variant ensures files created in the mounted workspace match your host user ID. If the state directory was previously written by another user, fix its ownership on the host first:

```sh
chown -R "$(id -u):$(id -g)" ~/docker/pi/agent
```

## Usage

Check the installed version:

```sh
pi --version
```

Start the interactive TUI:

```sh
pi
```

Use `/login` in the TUI for supported subscription providers and API-key providers. For a one-shot, non-interactive request:

```sh
pi -p "Summarize this repository"
```

Pi can read, write, edit, and run shell commands in the mounted workspace. Review what directory you mount and use source control or another checkpointing workflow when appropriate.

## OpenAI-compatible Endpoints

Add a custom provider in `~/docker/pi/agent/models.json`. Keep the credential in an environment variable instead of writing it into the file:

```json
{
  "providers": {
    "custom-openai": {
      "baseUrl": "https://api.example.com/v1",
      "api": "openai-completions",
      "apiKey": "$CUSTOM_OPENAI_API_KEY",
      "models": [
        {
          "id": "your-model-id",
          "name": "Your Model"
        }
      ]
    }
  }
}
```

Pass the key at runtime and select the provider and model:

```sh
docker run --rm -it -w /workspace \
  -e CUSTOM_OPENAI_API_KEY \
  -v ~/docker/pi/agent:/root/.pi/agent \
  -v "$(pwd)":/workspace \
  pi --provider custom-openai --model your-model-id
```

For endpoints with partial OpenAI compatibility, Pi supports provider- or model-level `compat` settings such as `supportsDeveloperRole`, `supportsReasoningEffort`, `supportsUsageInStreaming`, and `maxTokensField`. See the custom-model documentation before enabling overrides.

If a gateway filters SDK user agents, add an explicit header after `apiKey`:

```json
      "headers": {
        "User-Agent": "pi-coding-agent"
      },
```

References:

- [Pi](https://pi.dev/)
- [Pi documentation](https://pi.dev/docs/latest)
- [Quickstart](https://pi.dev/docs/latest/quickstart)
- [Providers and authentication](https://pi.dev/docs/latest/providers)
- [Custom models and OpenAI-compatible endpoints](https://pi.dev/docs/latest/models)
- [Containerization and security](https://pi.dev/docs/latest/containerization)
- [Pi source code on GitHub](https://github.com/earendil-works/pi)
