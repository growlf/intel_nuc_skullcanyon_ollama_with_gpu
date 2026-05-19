# AGENTS.md — Intel Skull NUC LLM Setup

This repo is a **static web-hosted deployment package** for automated Ollama GPU acceleration setup on Ubuntu 24.04 LTS with Intel iGPU. Not a code project — no build/test/lint system.

Agent context is provided by `AGENT_ORCHESTRATION.md` (loaded via `opencode.json` `instructions`). This file is a quick-reference supplement.

## Structure

| File | Purpose |
|------|---------|
| `AGENT_ORCHESTRATION.md` | **Primary** — agent instruction file (decision tree, actions, troubleshooting) |
| `AGENT_DEPLOYMENT.md` | Deployment guide and user-facing instructions |
| `collect-state.sh` | System state collection script (run by user, outputs JSON) |
| `INDEX.md` / `DEPLOYMENT_SUMMARY.txt` | Overview for humans |
| `opencode.json` | Loads `AGENT_ORCHESTRATION.md` into agent context |

## How an agent uses this repo

1. User clones the repo and runs `opencode` in it — `AGENTS.md` is auto-discovered, and `AGENT_ORCHESTRATION.md` is loaded via `opencode.json`.
2. Agent reads `AGENT_ORCHESTRATION.md` as its complete playbook — it contains decision tree, exact commands, verification steps, and troubleshooting.
3. Agent asks user to run `collect-state.sh` via `bash <(curl -s ...)` — the JSON output drives the decision tree.
4. Agent guides user through: group membership → Ollama install → Vulkan systemd override → GPU verification.

## Key commands

```bash
# Start Opencode in this repo (AGENTS.md + AGENT_ORCHESTRATION.md auto-loaded)
cd intel_nuc_skullcanyon_ollama_with_gpu
opencode

# Collect system state (run when agent asks)
bash <(curl -s https://raw.githubusercontent.com/growlf/intel_nuc_skullcanyon_ollama_with_gpu/main/collect-state.sh)
```

## Reqs

- **Target:** Ubuntu 24.04 LTS, Intel iGPU, Ollama 0.24.0+
- **User needs:** sudo, `jq` installed, internet
- `collect-state.sh` requires `lspci`, `jq`, `curl` — standard on Ubuntu 24.04

## Gotchas

- `AGENT_ORCHESTRATION.md` is **the single source of truth** for agent behavior — not INDEX.md or AGENT_DEPLOYMENT.md.
- After adding user to `render`/`video` groups, user **must log out and back in** (not just `su` or `newgrp`).
- Port 11434 conflict triggers a **systemd restart loop** (not just Docker; also a manually-run `ollama serve`). Kill the conflicting process with `sudo kill <pid>`, not just `systemctl stop`. The `collect-state.sh` `port_conflict` field helps detect this before install.
- `intel_gpu_top` requires `intel-gpu-tools` package (not installed by default).
- The `collect-state.sh` writes state to `/tmp/ollama-setup-state-$$.json` — clean temp path.
