# Ollama Intel GPU Setup - Complete Web-Hosted Package

**Version:** 2.0-agent-driven  
**Updated:** May 2026  
**Format:** Web-optimized for Opencode agent deployment

---

## 🎯 What This Is

A complete, **autonomous setup system** for Ollama GPU acceleration that runs on any Ubuntu 24.04 LTS system with Intel iGPU.

The magic: **Host these files on your website**, configure Opencode to use them, and the agent handles setup autonomously while guiding the user through it.

---

## 📦 Files in This Package

### 1. **AGENT_ORCHESTRATION.md** (17 KB) ⭐ PRIMARY

**The agent's complete playbook.** Contains:

- **Decision Tree:** Logic for analyzing system state
- **Setup Actions:** Exact commands for each step
- **Verification Steps:** How to confirm success
- **Troubleshooting Guide:** How to handle failures

**Use:** Loaded automatically via `opencode.json` `instructions` — just run `opencode` in the cloned repo.

---

### 2. **AGENT_DEPLOYMENT.md** (13 KB)

**Guide for deploying this system to users.**

Contains:
- Quick start for users
- Agent workflow explanation
- Hosting instructions
- Implementation notes for Opencode agents
- Security considerations

**Use:** Read this to understand deployment options

---

### 3. **collect-state.sh** (4.8 KB)

**Simple system state collection script.**

What it does:
- Detects GPU hardware
- Checks i915 driver
- Verifies user groups
- Outputs JSON

**Use:** Users run this, agent analyzes the output

```bash
bash <(curl -s https://your-site.com/ollama-setup/collect-state.sh)
```

---

## 🚀 How It Works

### For End Users

```
1. Install Opencode on your system
2. Configure to use this agent guide
3. Run: bash <(curl -s https://.../collect-state.sh)
4. Paste JSON output to agent
5. Follow agent's guidance
6. Done! GPU acceleration works
```

**Time:** 10-15 minutes, mostly waiting for Ollama to install/restart

### For Admins

```
1. Copy these 3 files to your website
2. Point users to the Opencode setup guide
3. Users configure Opencode with your URL
4. Agent handles rest autonomously
```

**Minimal ongoing support needed** (most issues are handled by agent)

---

## 📋 Quick Deployment Checklist

### Step 1: Host Files

```bash
# On your web server, create directory:
mkdir -p /var/www/ollama-setup

# Copy files:
cp AGENT_ORCHESTRATION.md /var/www/ollama-setup/
cp AGENT_DEPLOYMENT.md /var/www/ollama-setup/
cp collect-state.sh /var/www/ollama-setup/

# Make accessible via HTTP(S)
# URL should be: https://your-domain.com/ollama-setup/AGENT_ORCHESTRATION.md
```

### Step 2: Test File Access

```bash
# Verify files are accessible:
curl -I https://your-domain.com/ollama-setup/AGENT_ORCHESTRATION.md
# Should return: 200 OK

curl -I https://your-domain.com/ollama-setup/collect-state.sh
# Should return: 200 OK
```

### Step 3: Run Opencode in the Repo

```bash
git clone https://github.com/growlf/intel_nuc_skullcanyon_ollama_with_gpu.git
cd intel_nuc_skullcanyon_ollama_with_gpu
opencode
```

The `AGENT_ORCHESTRATION.md` playbook is loaded automatically via `opencode.json`.

### Step 4: User Runs Agent

Agent will:
- Read your AGENT_ORCHESTRATION.md
- Ask user to collect system state
- Analyze system and identify issues
- Guide user through setup
- Verify success

---

## 🎓 Understanding the Architecture

### Traditional Approach
```
User → Menu Script → Bash Logic → Execute
       [User decides each step]
```

### This Agent-Driven Approach
```
User → Opencode Agent
       ↓ [Reads AGENT_ORCHESTRATION.md from your site]
       ↓ [Analyzes system state]
       ↓ [Follows decision tree]
       ↓ [Guides user intelligently]
       ↓ [Executes with user approval]
       ↓ [Verifies success]
       ↓ [Troubleshoots issues]
Done!
```

**Key difference:** Agent makes intelligent decisions based on your *specific* system, not a one-size-fits-all menu.

---

## 📊 Files vs. Responsibility

| What | Who | How |
|-----|-----|-----|
| **System detection** | collect-state.sh | Simple bash script |
| **Analysis & logic** | AGENT_ORCHESTRATION.md | Decision tree + actions |
| **Execution** | Opencode agent | Following orchestration doc |
| **User guidance** | Opencode agent + doc | Explanations & approvals |

**You (hosting these files) don't code anything** — the files provide the playbook, Opencode agent does the work.

---

## 🔒 Security

- ✅ Files are static (no code execution on server)
- ✅ HTTPS recommended (https://, not http://)
- ✅ collect-state.sh is non-destructive (info only)
- ✅ Agent requests user approval before sudo commands
- ✅ No sensitive data (passwords, SSH keys, etc.)

---

## 📝 What Gets Set Up

After agent finishes (all systems):

✅ Ollama native systemd service (not Docker)  
✅ GPU acceleration via Vulkan + Mesa ANV  
✅ User in render/video/ollama groups  
✅ Systemd override with GPU environment variables  
✅ Model directory owned by ollama user  
✅ GPU inference verified and working  

---

## 🆘 Troubleshooting

### "Agent can't access documentation"

**Fix:** Verify URL is correct
```bash
curl https://your-domain.com/ollama-setup/AGENT_ORCHESTRATION.md
# Should return file content, not error
```

### "collect-state.sh fails"

**Fix:** Ensure jq is installed on user's system
```bash
apt install -y jq
# Then retry
```

### "Agent takes wrong action"

**Most common:** GPU detection failed
```bash
# User should run:
lspci -nn | grep -i "vga\|3d"
# And share output with admin
```

---

## 📖 Reading Guide

**If you're deploying this:**

1. Read this file (INDEX.md) first
2. Read AGENT_DEPLOYMENT.md for full deployment guide
3. Skim AGENT_ORCHESTRATION.md to understand agent logic
4. Host the 3 files on your website
5. Test with `curl` to verify accessibility
6. Share deployment URL with users

**If you're a user:**

1. Read AGENT_DEPLOYMENT.md ("Quick Start for Users" section)
2. Install Opencode
3. Configure with your admin's URL
4. Run `collect-state.sh` when agent asks
5. Follow agent's guidance

**If you're implementing the agent:**

1. Read AGENT_ORCHESTRATION.md (entire document)
2. Implement decision tree logic
3. Follow implementation notes at end
4. Test with real systems

---

## 🌐 Hosting Options

### GitHub Pages (Free)

```bash
# Create repo, add files, enable Pages
# Files at: https://your-org.github.io/ollama-setup/
```

### Self-Hosted Web Server

```bash
# Copy files to /var/www/ollama-setup/
# Access at: https://your-domain.com/ollama-setup/
```

### Cloud Platforms

- **AWS S3** + CloudFront
- **Google Cloud Storage**
- **Azure Blob Storage**
- **Netlify**
- **Vercel**
- Any HTTP(S) server

---

## 📞 Support

### For Users

- Check AGENT_DEPLOYMENT.md ("Quick Start")
- Follow agent's instructions (it has full context)
- If agent gets stuck, contact your admin

### For Admins

- Check AGENT_DEPLOYMENT.md ("Troubleshooting for Admins")
- Verify files are accessible with `curl`
- Check agent implementation against AGENT_ORCHESTRATION.md

### For Agents (Implementation)

- AGENT_ORCHESTRATION.md is your complete spec
- Decision tree explains logic
- Actions describe exact commands
- Verification steps confirm success
- Troubleshooting section has solutions

---

## 📌 Key Concepts

### System State (What Agent Analyzes)

```json
{
  "gpu": {
    "pci": "Intel Iris Pro 580 [8086:193b]",
    "i915_loaded": 1,
    "render_node": "/dev/dri/renderD128"
  },
  "user": {
    "in_render": 0,
    "in_video": 0,
    "in_ollama": 0
  },
  "ollama": {
    "installed": 0,
    "running": 0
  },
  ...
}
```

Agent reads this and decides next steps.

### Decision Tree (How Agent Decides)

```
Is GPU Intel? → Is i915 loaded? → Is render node available?
→ Is user in render group? → Is Ollama installed?
→ Is Vulkan configured? → Test GPU inference
```

Each decision point maps to an action.

### Actions (What Agent Does)

Each action has:
- **Why:** Explanation (for user)
- **What:** Exact command (to run)
- **Check:** Verification (to confirm)
- **If fails:** Troubleshooting (fallback)

---

## 🎯 Success Criteria

User's system is **ready** when:

✅ Ollama service is running  
✅ GPU detected in logs (Vulkan)  
✅ Test model runs successfully  
✅ `ollama ps` shows % GPU in PROCESSOR column  

Agent confirms all four before declaring success.

---

## 📚 Document Sizes

| File | Size | Purpose |
|------|------|---------|
| AGENT_ORCHESTRATION.md | 17 KB | Agent playbook (primary) |
| AGENT_DEPLOYMENT.md | 13 KB | Deployment + user guide |
| collect-state.sh | 4.8 KB | State collection script |
| **Total** | **35 KB** | Complete system |

✅ **Small & efficient** — Fast to download and parse

---

## 🔄 Update Process

If you need to update any file:

1. Update the file locally
2. Test in lab environment
3. Deploy to live website
4. No agent restart needed (fetches fresh each time)
5. Existing setups unaffected

---

## 🚀 Next Steps

### To Deploy

1. Place these 3 files on your website
2. Verify with `curl`
3. Share URL with users

### To Use (If You're User)

1. Install Opencode
2. Configure with your admin's URL
3. Follow agent's guidance

### To Implement (If You're Building Agent)

1. Read AGENT_ORCHESTRATION.md completely
2. Implement decision tree logic
3. Implement action execution
4. Implement verification & troubleshooting
5. Test with real systems

---

## 📌 Summary

**This package enables:**

- ✅ **Autonomous setup** on multiple systems
- ✅ **Intelligent guidance** (adapts to hardware)
- ✅ **Minimal ongoing support** (agent handles most issues)
- ✅ **Scalable deployment** (host once, use everywhere)
- ✅ **Educational** (users understand what's happening)

**In ~10-15 minutes, any Ubuntu 24.04 system with Intel iGPU gets:**

- ✅ Ollama installed & configured
- ✅ GPU acceleration working
- ✅ Ready for inference

**Zero technical skill required from user** (agent guides them)

---

**Ready to deploy?** Start here:

1. Put files on your website
2. Test file access with curl
3. Share URL with users/system
4. Agent handles the rest!

---

*Version 2.0-agent-driven | Updated May 2026 | Tested with Ollama 0.24.0+*
