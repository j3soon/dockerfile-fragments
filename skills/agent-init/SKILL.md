---
name: agent-init
description: Initialize a new repository's agent configuration from the agent-bootstrap repo. Use when asked to initialize, set up, or bootstrap AGENTS.md, skills, or agent guidance, optionally given the agent-bootstrap repo URL.
---

# Agent Init

Set up agent configuration in the target repository.

1. Fetch the agent-bootstrap repo at `https://github.com/j3soon/agent-bootstrap`
   or the URL provided by the user.
2. If the target root has no `AGENTS.md`, copy the bootstrap repo's root
   `AGENTS.md` as the target `AGENTS.md`. If one exists, add only missing
   sections and keep local rules.
3. Ensure the target `.gitignore` includes `/artifacts/`.
4. Copy reusable skills from `skills/` into the target `skills/` directory.
5. If the agent reads skills from `.agents/skills` or `.claude/skills`, create
   those directories with a `skills` symlink to `../skills`.
6. Update the copied `AGENTS.md` Project Structure section with the target's
   real structure, modules, and test commands. Ask the user when details are
   unclear.
