# Ollama Intel iGPU GPU Acceleration — Opencode Agent Setup

If you're here, you've probably spent hours trying to get Ollama to use your Intel integrated GPU. You've edited config files, chased forum threads, and watched `ollama ps` stubbornly show 0% GPU. This is a different approach: an AI agent that reads a verified playbook and walks you through the exact steps, one at a time.

**Target hardware:** Intel NUC6i7KYB (Iris Pro 580), plus similar Skylake/Kaby Lake/Coffee Lake iGPU systems on Ubuntu 24.04 LTS.

## How it works (so you know what you're agreeing to)

The agent follows a step-by-step playbook that lives in this repo. Nothing runs automatically — the agent explains each step, asks for your approval, and only then executes the command. Here's the full flow:

1. **Read the playbook** — The agent fetches `AGENT_ORCHESTRATION.md` from this repo. You can read it yourself anytime (it's just text).
2. **Diagnose** — The agent asks you to run one command: `collect-state.sh`. This script reads your hardware info and outputs JSON. **It makes no changes to your system.**
3. **Identify blockers** — Based on the output, the agent lists what needs fixing (e.g., "you're not in the render group").
4. **Fix one thing at a time** — For each issue, the agent explains what it will do, shows the exact command, and waits for you to approve it before running anything.
5. **Verify** — After each fix, the agent confirms the change worked before moving on.

Every `sudo` command is shown to you first. You type your password, not the agent.

## Quick start

**1. Install Opencode**

```bash
curl -fsSL https://opencode.ai/install | bash
```

Opencode is an open-source AI coding agent ([GitHub](https://github.com/anomalyco/opencode)). It runs entirely on your machine.

**2. Open Opencode and paste this message:**

```
Fetch https://raw.githubusercontent.com/growlf/intel_nuc_skullcanyon_ollama_with_gpu/main/AGENT_ORCHESTRATION.md and follow it to set up Ollama GPU acceleration on this system.
```

**3. When the agent asks, run this and paste the output back:**

```bash
bash <(curl -s https://raw.githubusercontent.com/growlf/intel_nuc_skullcanyon_ollama_with_gpu/main/collect-state.sh)
```

That's it. The agent handles the rest.

## What exactly will happen to my system?

If your system is a standard Intel iGPU Ubuntu 24.04 setup, the agent may:

- **Add you to groups** — `sudo usermod -aG render,video,ollama $USER` (then you log out and back in)
- **Install Ollama** — The official installer from ollama.com
- **Create a systemd override** — A config file at `/etc/systemd/system/ollama.service.d/override.conf` with `OLLAMA_VULKAN=1`
- **Fix model permissions** — `sudo chown -R ollama:ollama /usr/share/ollama/.ollama/`

If something is already configured, the agent skips it. It won't break a working setup.

## I don't trust AI running commands on my machine

Valid. Here's what you should know:

- **The playbook is human-readable.** Open `AGENT_ORCHESTRATION.md` right now and read it. Every command the agent might run is written there in plain text.
- **`collect-state.sh` is read-only.** It detects hardware, checks groups, and prints JSON. It does not modify anything.
- **Nothing runs without your approval.** The agent shows you the exact command and asks "Continue?" before every `sudo` or system change.
- **You can say no at any point.** If a step feels wrong, decline it.

## Files

| File | What it is |
|------|------------|
| `AGENT_ORCHESTRATION.md` | The playbook — every command and decision the agent follows |
| `collect-state.sh` | System diagnostic script (safe to run, no changes) |
| `AGENTS.md` | Quick reference for the agent session |
