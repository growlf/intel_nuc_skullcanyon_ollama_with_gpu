# Ollama Intel iGPU Setup — Agent-Driven Deployment

This repo contains the files behind an **Opencode agent-driven setup system** for getting Ollama GPU acceleration working on Ubuntu 24.04 LTS with Intel integrated graphics (tested on NUC6i7KYB / Iris Pro 580).

## What this is

This is **not** a standalone script or a universal fix. It's a deployment package designed to be served as static files on an HTTPS web server, where an [Opencode](https://opencode.ai) agent fetches `AGENT_ORCHESTRATION.md` as its playbook and guides a user through setup interactively.

It may still be useful to anyone struggling to get older Intel iGPU systems working with Ollama's Vulkan backend — the troubleshooting steps, systemd override, and group membership requirements are the same whether an agent runs them or you do them by hand.

## Structure

| File | Purpose |
|------|---------|
| `AGENT_ORCHESTRATION.md` | Agent playbook — decision tree, commands, troubleshooting |
| `AGENT_DEPLOYMENT.md` | Deployment and user guide |
| `collect-state.sh` | System state collection script (run once, outputs JSON) |
| `AGENTS.md` | Quick-reference for agent sessions |
| `INDEX.md` / `DEPLOYMENT_SUMMARY.txt` | Overview |

## Quick test

To check if your Intel iGPU can work with Ollama:

```bash
bash <(curl -s https://your-server.com/path/collect-state.sh)
```

If the JSON shows `i915_loaded: 1` and a render node like `/dev/dri/renderD128`, your hardware is supported.


