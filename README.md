# Ollama Intel iGPU GPU Acceleration — Opencode Agent Setup

Get Ollama running with full GPU acceleration on Ubuntu 24.04 LTS using Intel integrated graphics (Iris Pro, UHD, etc.) — guided by an [Opencode](https://opencode.ai) agent.

## Quick start

**1. Install Opencode**

Follow the [Opencode installation guide](https://opencode.ai/install). One-time setup.

**2. Open Opencode and paste this:**

```
Fetch https://raw.githubusercontent.com/growlf/intel_nuc_skullcanyon_ollama_with_gpu/main/AGENT_ORCHESTRATION.md and follow it to set up Ollama GPU acceleration on this system.
```

That's it. The agent reads the playbook, asks you to run the state collector, then guides you through everything.

## What this is

This repo is the behind-the-scenes playbook for the agent. It is **not** a standalone script or universal fix. It was built for the Intel NUC6i7KYB (Iris Pro 580) but may help anyone using older Intel iGPU systems with Ollama — the troubleshooting, systemd override, and group permissions are the same whether automated or done by hand.

## Files

| File | Role |
|------|------|
| `AGENT_ORCHESTRATION.md` | Agent playbook — decision tree, commands, troubleshooting |
| `collect-state.sh` | System state collector (run once, outputs JSON) |
| `AGENTS.md` | Quick-reference for agent sessions |
| `opencode.json` | Project config — loads `AGENT_ORCHESTRATION.md` as agent instructions |
