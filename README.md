# Ollama Intel iGPU GPU Acceleration — Opencode Agent Setup

Get Ollama running with full GPU acceleration on Ubuntu 24.04 LTS using Intel integrated graphics (Iris Pro, UHD, etc.) — guided by an [Opencode](https://opencode.ai) agent.

## Quick start

**1. Install Opencode**

Follow the [Opencode installation guide](https://opencode.ai/install) for your platform.

**2. Clone the repo and start Opencode**

```bash
git clone https://github.com/growlf/intel_nuc_skullcanyon_ollama_with_gpu.git
cd intel_nuc_skullcanyon_ollama_with_gpu
opencode
```

The `AGENTS.md` file in the project root (along with `AGENT_ORCHESTRATION.md` via `opencode.json`) provides full context to the agent automatically.

**3. Collect your system state when asked**

The agent will ask you to run:

```bash
bash <(curl -s https://raw.githubusercontent.com/growlf/intel_nuc_skullcanyon_ollama_with_gpu/main/collect-state.sh)
```

Paste the JSON output, and the agent handles the rest — group membership, Ollama install, Vulkan config, and GPU verification.

## What this is

This repo is the behind-the-scenes playbook for the agent. It is **not** a standalone script or universal fix. It was built for the Intel NUC6i7KYB (Iris Pro 580) but may help anyone using older Intel iGPU systems with Ollama — the troubleshooting, systemd override, and group permissions are the same whether automated or done by hand.

## Files

| File | Role |
|------|------|
| `AGENT_ORCHESTRATION.md` | Agent playbook — decision tree, commands, troubleshooting |
| `collect-state.sh` | System state collector (run once, outputs JSON) |
| `AGENTS.md` | Quick-reference for agent sessions |
| `AGENT_DEPLOYMENT.md` | Deployment and user guide |
| `opencode.json` | Project config — loads `AGENT_ORCHESTRATION.md` as agent instructions |
