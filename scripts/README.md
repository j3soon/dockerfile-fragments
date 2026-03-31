# Scripts

## Check `codex` and optionally rebuild every 15 minutes

This script checks both local Docker images, `codex` and `codex-user`, against the latest published `@openai/codex` package.

Run it manually:

```sh
scripts/rebuild-codex-docker.sh
```

Install the user timer:

```sh
scripts/install-systemd-timer.sh
```

View timer status:

```sh
systemctl --user status rebuild-codex-docker.timer
```

View service logs:

```sh
journalctl --user -u rebuild-codex-docker.service
```

Follow service logs:

```sh
journalctl --user -fu rebuild-codex-docker.service
```
