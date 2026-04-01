# Scripts

## Check `codex` and optionally rebuild every 15 minutes

This script checks local Docker images `codex` and `codex-user`, and also checks host `codex` if it is installed. If versions do not match the latest published `@openai/codex` package, it rebuilds the images and upgrades host `codex`.

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
