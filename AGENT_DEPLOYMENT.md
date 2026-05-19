# Ollama Intel GPU Setup - Opencode Agent Deployment

**Version:** 2.0-agent-driven  
**Format:** Web-optimized for remote Opencode agent execution  
**Updated:** May 2026

---

## Quick Start for Users

You're about to set up Ollama with Intel GPU acceleration using an autonomous Opencode agent.

### Prerequisites

1. **System:** Ubuntu 24.04 LTS with Intel iGPU (or compatible)
2. **Opencode Terminal:** Installed and configured
3. **Internet:** Connection to download Ollama and models
4. **Sudo Access:** Required to configure systemd and groups

### Steps

#### Step 1: Set Up Opencode to Read This Guide

In your Opencode terminal:

```bash
opencode --agent-mode --model zen-bigpickle \
  --context-url https://your-website.com/ollama-setup/AGENT_ORCHESTRATION.md
```

Or if your system has an interactive setup:

```
Opencode → Settings → Agent Mode
→ Enable Agent Mode
→ Set Model: Zen Bigpickle (or preferred LLM)
→ Load Context: https://your-website.com/ollama-setup/AGENT_ORCHESTRATION.md
→ Start Agent
```

#### Step 2: Collect Your System State

The agent will ask you to run:

```bash
bash <(curl -s https://your-website.com/ollama-setup/collect-state.sh)
```

This script:
- ✅ Detects GPU hardware
- ✅ Checks i915 driver status
- ✅ Verifies user group memberships
- ✅ Checks for existing Ollama installation
- ✅ Outputs JSON summary
- ✅ Takes ~5 seconds, makes no changes

#### Step 3: Follow Agent Guidance

The agent will:

1. **Analyze** your system state (from Step 2)
2. **Identify** blockers and prerequisites
3. **Prioritize** next steps (critical first)
4. **Guide** you through each step with explanations
5. **Execute** commands (asking for confirmation)
6. **Verify** each step worked
7. **Troubleshoot** if issues arise

Just follow the agent's instructions. It has complete knowledge of your system and will adapt guidance accordingly.

#### Step 4: Verify Success

After the agent finishes setup, test it:

```bash
# Service running?
sudo systemctl status ollama

# Pull a test model
ollama pull qwen2.5:1.5b

# Run test inference
ollama run qwen2.5:1.5b "Hello!"

# Verify GPU is being used
ollama ps
# PROCESSOR column should show % GPU
```

---

## For System Administrators (Deploying Opencode)

### Deployment Steps

1. **Install Opencode on user's system**
   ```bash
   # Install from official source
   # (Platform-specific: check Opencode documentation)
   ```

2. **Configure Agent Mode**
   ```bash
   # Set default model
   opencode config set default-model zen-bigpickle
   
   # Set agent context URL
   opencode config set agent-context https://your-domain.com/ollama-setup/AGENT_ORCHESTRATION.md
   ```

3. **Create a startup script for users**
   ```bash
   #!/bin/bash
   # Start Opencode with agent mode enabled
   opencode --agent-mode --model zen-bigpickle \
     --context-url "https://your-domain.com/ollama-setup/AGENT_ORCHESTRATION.md"
   ```

4. **Provide users with simple instructions**
   ```
   1. Run: opencode-ollama-setup.sh
   2. Follow the agent's guidance
   3. Run: bash <(curl -s https://your-domain.com/ollama-setup/collect-state.sh)
   4. Paste the JSON output when agent requests it
   5. Agent handles the rest!
   ```

### Files to Host

On your website (`https://your-domain.com/ollama-setup/`), place:

| File | Purpose |
|------|---------|
| `AGENT_ORCHESTRATION.md` | **Primary** - Agent's complete guide |
| `collect-state.sh` | System state collection script |
| `README.md` (this file) | User instructions |

### Hosting Tips

- **Static files only** - No server-side processing needed
- **Raw content delivery** - Curl-friendly URLs
- **Markdown compatible** - Human-readable, agent-parseable

Example structure:
```
your-website.com/
└── ollama-setup/
    ├── AGENT_ORCHESTRATION.md  (11 KB)
    ├── collect-state.sh         (4 KB)
    └── README.md                (this file)
```

---

## How the Agent Works

### Agent Flow

```
User: "Set up Ollama GPU acceleration"
      ↓
Agent: [Reads AGENT_ORCHESTRATION.md from your website]
      ↓
Agent: "I need to analyze your system first. Please run this command:"
       $ bash <(curl -s https://.../collect-state.sh)
      ↓
User: [Runs command, copies JSON output]
      ↓
Agent: [Analyzes JSON against decision tree]
      ↓
Agent: "Your system has Intel GPU, but you're not in the 'render' group.
        This is the first blocker. I'll add you to it now."
      ↓
Agent: [Executes: sudo usermod -aG render,video,ollama $USER]
      ↓
User: [Provides sudo password]
      ↓
Agent: "Done! Now you need to log out and back in. Please do that now."
      ↓
User: [Logs out, logs back in]
      ↓
Agent: [Re-runs state collection]
      ↓
Agent: [Identifies next blocker]
      ↓
[Repeat until all blockers resolved]
      ↓
Agent: "Setup complete! Let me verify GPU is working..."
      ↓
Agent: [Runs ollama ps, checks Vulkan in logs]
      ↓
Agent: "✅ GPU acceleration confirmed! Your system is ready."
```

### Agent Capabilities

The agent can:

✅ **Analyze** system state (GPU, drivers, groups, permissions)  
✅ **Prioritize** actions (critical blockers first)  
✅ **Execute** commands (with user approval)  
✅ **Verify** success (check logs, test models)  
✅ **Explain** decisions (tell user why each step is needed)  
✅ **Troubleshoot** failures (adapt to issues)  
✅ **Teach** the user (full context, not just commands)  

---

## Agent Orchestration Document

The `AGENT_ORCHESTRATION.md` file is your "playbook" for the agent. It contains:

### 1. Decision Tree
Logic for analyzing system state and determining next steps:
```
Is this Intel iGPU?
├─ YES → Check i915 driver
└─ NO → Stop (unsupported)

Is i915 loaded?
├─ YES → Check render node
└─ NO → BLOCKER
```

### 2. Setup Actions
Exactly what to do for each step:
```
Action: Add User to GPU Groups
Purpose: Allow access to /dev/dri/renderD128
Command: sudo usermod -aG render,video,ollama $USER
Post-action: User must log out and back in
```

### 3. Verification Steps
How to confirm each step worked:
```
Check: sudo systemctl status ollama
Expected: active (running)
```

### 4. Troubleshooting
How to handle common issues:
```
Issue: Permission denied on /dev/dri/renderD128
Cause: User not in render group
Solution: Add to group (see Action above)
```

The agent reads this document and applies its logic autonomously.

---

## For the Opencode Agent (Implementation Notes)

### Agent Behavior Pattern

```python
# Pseudo-code for agent implementation

agent = OpenCodeAgent(
    model="zen-bigpickle",
    context_url="https://site.com/ollama-setup/AGENT_ORCHESTRATION.md"
)

# Phase 1: Collect State
print("I need to analyze your system first.")
state_json = user.run_command(
    "bash <(curl -s " + get_script_url("collect-state.sh") + ")"
)
system_state = parse_json(state_json)

# Phase 2: Analyze
analysis = agent.analyze_state(system_state)
# analysis.blockers = [{"name": "render_group", "severity": "critical"}, ...]
# analysis.next_action = "add_user_to_groups"

# Phase 3: Guide and Execute
while analysis.next_action:
    action = get_action(analysis.next_action)
    
    # Explain
    print(f"Found issue: {action['issue']}")
    print(f"Why: {action['explanation']}")
    print(f"Command: {action['command']}")
    
    # Get approval
    if user.approve():
        # Execute
        result = user.run_command(action['command'])
        
        # Verify
        verification = action['verify_command']
        if user.run_command(verification):
            print("✓ Success!")
        else:
            print("⚠ Issue detected, troubleshooting...")
            # Follow troubleshooting path
    
    # Re-analyze
    state_json = user.run_command(collect_state_script)
    system_state = parse_json(state_json)
    analysis = agent.analyze_state(system_state)

print("Setup complete!")
```

### Key Implementation Points

1. **Fetch Context Document** - Load AGENT_ORCHESTRATION.md at startup
2. **Use Decision Tree** - Follow the documented logic flow
3. **Collect State First** - Never assume; always verify with state collection
4. **Explain Before Acting** - Tell user what, why, and how
5. **Confirm Before Executing** - Get user approval for privileged commands
6. **Verify After Each Step** - Check if the action worked
7. **Handle Errors Gracefully** - Explain failures and suggest fixes
8. **Re-analyze Continuously** - Collect state after each action
9. **Stop on Critical Failures** - Don't proceed if GPU is unsupported

---

## Typical Timeline

| Phase | Time | What Happens |
|-------|------|--------------|
| **Setup** | 1 min | User installs Opencode, starts agent |
| **Analysis** | 2 min | Agent analyzes system state |
| **Blocker 1** | 3 min | User adds to groups, logs out/back in |
| **Blocker 2** | 2 min | Agent installs Ollama (downloads & installs) |
| **Blocker 3** | 1 min | Agent configures Vulkan override |
| **Verification** | 2 min | Agent verifies GPU works |
| **Total** | **10-15 min** | Complete setup ready |

---

## Hosting the Files

### Option 1: GitHub Pages (Free)

```bash
# Create repo
git init ollama-setup
cd ollama-setup

# Add files
cp AGENT_ORCHESTRATION.md .
cp collect-state.sh .
cp README.md .
git add .
git commit -m "Add Ollama GPU setup"

# Push to GitHub
git remote add origin https://github.com/your-org/ollama-setup
git push -u origin main

# Enable GitHub Pages in repo settings
# Files accessible at:
# https://your-org.github.io/ollama-setup/AGENT_ORCHESTRATION.md
```

### Option 2: Self-Hosted

```bash
# Copy to web server
scp AGENT_ORCHESTRATION.md user@your-server:/var/www/ollama-setup/
scp collect-state.sh user@your-server:/var/www/ollama-setup/
scp README.md user@your-server:/var/www/ollama-setup/

# Or if using Docker
docker run -d -p 8080:80 -v $(pwd):/usr/share/nginx/html:ro nginx
# Files accessible at: http://localhost:8080/
```

### Option 3: Use an Existing Platform

- **GitLab** (gitlab.com)
- **Gitea** (self-hosted)
- **Cloudflare Pages** (workers.dev)
- **Any HTTP server** (Apache, Nginx, etc.)

---

## Security Considerations

### File Integrity

- ✅ Served over HTTPS (use https://, not http://)
- ✅ Pin version in agent configuration
- ✅ Sign files if using private hosting

### Command Execution

- ✅ Agent asks for user approval before sudo commands
- ✅ User sees exact command before execution
- ✅ Only documented commands are available

### State Collection

- ✅ No sensitive data collected (no SSH keys, passwords, etc.)
- ✅ Only hardware/software state (GPU, drivers, groups)
- ✅ JSON output can be inspected by user

---

## Troubleshooting for Admins

### Agent Can't Access Documentation

**Symptom:** "Failed to fetch context document"

**Fix:**
- Verify URL is correct and accessible
- Check CORS headers if served from different domain
- Ensure file exists: `curl https://your-domain.com/ollama-setup/AGENT_ORCHESTRATION.md`
- Check firewall/proxy isn't blocking access

### State Collection Script Fails

**Symptom:** User runs script, gets error

**Fix:**
- Verify jq is installed: `jq --version` (should be on Ubuntu 24.04)
- Verify lspci available: `lspci --version`
- Some systems may lack certain tools; see collect-state.sh output

### Agent Takes Wrong Action

**Symptom:** Agent suggests installing NVIDIA drivers (wrong GPU)

**Fix:**
- GPU detection failing in state collection
- Check `lspci -nn | grep -i vga` output
- Verify AGENT_ORCHESTRATION.md is loaded correctly
- Add more specific GPU detection if needed

---

## Support & Updates

### Document Updates

This guide (`AGENT_ORCHESTRATION.md`) is versioned. When updating:

1. Update version number (top of document)
2. Document changes in changelog
3. Test with real agent before deploying
4. Consider backward compatibility

### Community Resources

- **Ollama GitHub:** https://github.com/ollama/ollama
- **Intel iGPU Linux:** https://www.intel.com/content/www/us/en/support/
- **Mesa ANV:** https://docs.mesa3d.org/drivers/iris.html
- **Ubuntu Graphics:** https://ubuntu.com/

---

## Summary

This agent-driven approach allows:

✅ **Remote setup** - Users run agent, agent handles everything  
✅ **Autonomous** - No manual intervention required for standard systems  
✅ **Intelligent** - Agent adapts to specific hardware/configuration  
✅ **Educational** - Agent explains what's happening and why  
✅ **Maintainable** - Single document for all logic  
✅ **Scalable** - Deploy to thousands of systems

Simply:

1. **Host** the files on your website
2. **Configure** Opencode to use the agent
3. **Users run** the agent
4. **GPU acceleration** works!

---

**Questions?** Check the agent orchestration document (`AGENT_ORCHESTRATION.md`) or the Opencode documentation.

**Ready to deploy?** Start by hosting these files on your website, then point Opencode agents to the AGENT_ORCHESTRATION.md URL.
