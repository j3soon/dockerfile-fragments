# Repository Guidelines

## Project Structure
- `<fragment>/`: one directory per Docker image fragment such as `pi`,
  `codex`, `opencode`, and `all-in-one`. Each holds a `Dockerfile` and a
  `README.md`. Build one with `docker build -t <name> .` inside the
  directory.
- `scripts/`: maintenance and validation scripts. The `rebuild-*-docker.sh`
  scripts keep Docker images current and run as systemd user timers.
  `validate.sh` builds a fragment image and runs service checks.
  Run it with `scripts/validate.sh [FRAGMENT] [VERSION]`.
- `skills/`: reusable agent skills, including the `agent-init` bootstrap skill.
- `artifacts/`: disposable output such as screenshots and generated reports.

## Using This Repository
- In a new repository, give an agent this repo's URL and ask it to run the
  `agent-init` skill to initialize `AGENTS.md` and skills.
- The root `AGENTS.md` doubles as the base file copied into new repositories.
  Update it when durable guidance changes so new repos inherit the change.

## Shared Workflow
- Keep edits scoped to the requested module and preserve existing patterns.
- Preserve each file's staged or unstaged state. Do not stage, unstage, or
  commit changes unless explicitly asked.
- Avoid trailing spaces and end files with a newline.
- Store generated output and other disposable review output under the
  repository-root `artifacts/` directory. This directory is ignored by Git.
- Use Conventional Commits for commit messages.
- Never use a coding agent identity as the Git author, committer, or
  co-author. Use the repository's configured human identity. If none is
  available, ask the user instead of inventing one.
- For commits created by a coding agent, include a descriptive body that
  ends with a separate `by <Harness> (<Model>)` line, using the actual
  harness and model names. For example, `by Codex (gpt-5.6-sol)` or `by
  Claude Code (Opus 5)`.
- Build multi-paragraph commit messages with separate `git commit -m`
  arguments. Do not embed escaped `\n` sequences because Git stores them
  literally instead of converting them to newlines.

## Comment and Documentation Style
- Keep comments and documentation minimal, concise, yet informative.
- Do not use em-dash or semicolon to connect sentences.
