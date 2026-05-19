# Ollama Intel iGPU GPU Acceleration — Opencode Agent Setup

Get Ollama running with full GPU acceleration on Ubuntu 24.04 LTS using Intel integrated graphics (Iris Pro, UHD, etc.) — guided by an [Opencode](https://opencode.ai) agent.

## Quick start

**1. Install Opencode**

Follow the [Opencode installation guide](https://opencode.ai/install). One-time setup.

**2. Paste this in your terminal:**

```bash
git clone https://github.com/growlf/intel_nuc_skullcanyon_ollama_with_gpu.git && cd $_ && opencode
```

The repo auto-loads `AGENT_ORCHESTRATION.md` (the full setup playbook) into the agent's context. Just tell it you want GPU acceleration working.

**3. When the agent asks, run:**

```bash
bash <(curl -s https://raw.githubusercontent.com/growlf/intel_nuc_skullcanyon_ollama_with_gpu/main/collect-state.sh)
```

Paste the JSON output back. The agent handles everything from there — groups, install, Vulkan config, verification.

## What this is

This repo is the behind-the-scenes playbook for the agent. It is **not** a standalone script or universal fix. It was built for the Intel NUC6i7KYB (Iris Pro 580) but may help anyone using older Intel iGPU systems with Ollama — the troubleshooting, systemd override, and group permissions are the same whether automated or done by hand.

## Files

| File | Role |
|------|------|
| `AGENT_ORCHESTRATION.md` | Agent playbook — decision tree, commands, troubleshooting |
| `collect-state.sh` | System state collector (run once, outputs JSON) |
| `AGENTS.md` | Quick-reference for agent sessions |
| `opencode.json` | Project config — loads `AGENT_ORCHESTRATION.md` as agent instructions |
