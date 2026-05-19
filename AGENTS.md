# AGENTS.md — Intel Skull NUC LLM Setup

This repo is a **static web-hosted deployment package** for automated Ollama GPU acceleration setup on Ubuntu 24.04 LTS with Intel iGPU. Not a code project — no build/test/lint system.

## Structure

| File | Purpose |
|------|---------|
| `AGENT_ORCHESTRATION.md` | **Primary** — agent instruction file (decision tree, actions, troubleshooting) |
| `AGENT_DEPLOYMENT.md` | Deployment guide and user-facing instructions |
| `collect-state.sh` | System state collection script (run by user, outputs JSON) |
| `INDEX.md` / `DEPLOYMENT_SUMMARY.txt` | Overview for humans |

## How an agent uses this repo

1. Host all files on an HTTPS web server (static files, no server-side logic).
2. Point Opencode to the `AGENT_ORCHESTRATION.md` URL as agent context.
3. Agent reads `AGENT_ORCHESTRATION.md` as its complete playbook — it contains decision tree, exact commands, verification steps, and troubleshooting.
4. Agent asks user to run `collect-state.sh` via `bash <(curl -s ...)` — the JSON output drives the decision tree.
5. Agent guides user through: group membership → Ollama install → Vulkan systemd override → GPU verification.

## Key commands (user-facing)

```bash
# Collect system state
bash <(curl -s https://your-domain.com/ollama-setup/collect-state.sh)

# Start agent with context
opencode --agent-mode --model zen-bigpickle \
  --context-url https://your-domain.com/ollama-setup/AGENT_ORCHESTRATION.md
```

## Reqs

- **Target:** Ubuntu 24.04 LTS, Intel iGPU, Ollama 0.24.0+
- **Agent model:** zen-bigpickle (or equivalent)
- **User needs:** sudo, `jq` installed, internet
- `collect-state.sh` requires `lspci`, `jq`, `curl` — standard on Ubuntu 24.04

## Gotchas

- `AGENT_ORCHESTRATION.md` is **the single source of truth** for agent behavior — not INDEX.md or AGENT_DEPLOYMENT.md.
- After adding user to `render`/`video` groups, user **must log out and back in** (not just `su` or `newgrp`).
- Port 11434 conflict triggers a **systemd restart loop** (not just Docker; also a manually-run `ollama serve`). Kill the conflicting process with `sudo kill <pid>`, not just `systemctl stop`. The `collect-state.sh` `port_conflict` field helps detect this before install.
- `intel_gpu_top` requires `intel-gpu-tools` package (not installed by default).
- The `collect-state.sh` writes state to `/tmp/ollama-setup-state-$$.json` — clean temp path.
