# Ollama Intel GPU Acceleration Setup - Agent Orchestration Guide

**Version:** 2.0-agent-driven  
**Last Updated:** May 2026  
**For:** Opencode Terminal Agent (Zen Bigpickle or equivalent)

---

## 🤖 For the Opencode Agent

This document contains all information needed for autonomous system setup and user guidance. You have full context to:

1. **Analyze** the user's system state
2. **Decide** the correct setup path
3. **Execute** remediation steps (with user confirmation)
4. **Verify** GPU acceleration is working
5. **Troubleshoot** if issues arise

No external documentation or decision-making required. This is your complete guide.

---

## Executive Summary

**Goal:** Set up Ollama with Intel GPU acceleration (Vulkan via Mesa ANV) on Ubuntu 24.04 LTS

**Hardware Support:**
- Intel NUC6i7KYB (Iris Pro 580, Skylake Gen9)
- Other Intel iGPU systems (Kaby Lake Gen10+)
- ~12-23 GB unified memory available for models

**Software Stack:**
- Ollama 0.24.0+ (native systemd service)
- Mesa ANV (Intel Vulkan driver)
- Kernel: i915 driver (Skylake+)
- Render node: `/dev/dri/renderD128` or similar

**Success Criteria:**
- Ollama service running
- GPU detected in Ollama logs (shows Vulkan)
- Test model runs on GPU (ollama ps shows % GPU in PROCESSOR column)

---

## System State Analysis

### Hardware Detection

First, collect hardware information from the user's system:

```bash
# GPU Detection
lspci -nn | grep -iE "vga|3d"
# Expected output examples:
#   - Intel Iris Pro 580: [8086:193b]
#   - Intel UHD Graphics: [8086:5912] or similar
#   - NOT NVIDIA or AMD (unsupported by this guide)

# Check i915 driver
lspci -v -s 00:02.0 | grep "Kernel driver"
# Expected: i915

# Check render nodes
ls -l /dev/dri/
# Expected: renderD128 or renderD129 (with crw-rw---- permissions, render group)
```

**Supported GPUs:**
| GPU | Code | Gen | Notes |
|-----|------|-----|-------|
| Iris Pro 580 | 193b | Skylake (Gen9) | Full support, 128MB eDRAM |
| Iris Graphics | 591b, 5912 | Kaby Lake (Gen10) | Full support |
| UHD Graphics | 5912+ | Coffee Lake+ | Full support |

**Unsupported:**
- NVIDIA (use nvidia-cuda-toolkit instead)
- AMD Radeon (use ROCm instead)
- Very old Intel (pre-Skylake may lack proper drivers)

### Software State

Check what's already installed:

```bash
# OS Version
cat /etc/os-release | grep VERSION
# Expected: 24.04 or 22.04

# Kernel
uname -r
# Expected: 6.x.x or later

# Current Ollama
ollama --version 2>/dev/null || echo "Not installed"

# Docker conflict
docker ps --format "{{.Ports}}" 2>/dev/null | grep 11434 || echo "No conflict"

# User groups
groups $USER
# Check for: render, video, ollama

# Mesa Vulkan
dpkg -l | grep mesa-vulkan-drivers || echo "Not installed"

# Available memory
free -h | grep Mem
```

### Permission State

```bash
# Render node ownership
ls -l /dev/dri/renderD* | head -1
# Expected: crw-rw---- root render

# Can user access it?
if [[ $(id -G) =~ (^|[^0-9])$(getent group render | cut -d: -f3)([^0-9]|$) ]]; then
    echo "User can access render node"
else
    echo "User CANNOT access render node (needs group add)"
fi
```

---

## Decision Tree

Based on system state, follow this logic:

### Step 0: Is this Intel iGPU?

```
GPU manufacturer check: lspci -nn | grep -i "vga\|3d"
├─ Contains "Intel" 
│  └─ Proceed to Step 1
├─ Contains "NVIDIA"
│  └─ STOP: Guide user to nvidia-cuda-toolkit (out of scope)
├─ Contains "AMD"
│  └─ STOP: Guide user to ROCm (out of scope)
└─ Unknown/None detected
   └─ WARN: Verify with `lspci` or check BIOS settings
```

### Step 1: Is i915 driver loaded?

```
Check: lspci -v -s 00:02.0 | grep "Kernel driver"
├─ Shows "i915"
│  └─ Proceed to Step 2
└─ Shows anything else or missing
   └─ CRITICAL BLOCKER
      Action: Advise kernel update or GPU enable in BIOS
      This setup cannot proceed without i915
```

### Step 2: Is render node available?

```
Check: ls /dev/dri/renderD*
├─ Shows renderD128, renderD129, etc.
│  └─ Proceed to Step 3
└─ No render nodes found
   └─ CRITICAL BLOCKER
      Action: Verify i915 loaded (step 1)
      Check BIOS GPU settings
      May need kernel update
```

### Step 3: Can user access render node?

```
Check: User in 'render' group?
├─ YES (groups output contains 'render')
│  └─ User can skip group addition, proceed to Step 4
└─ NO
   └─ BLOCKER (blocks GPU access)
      Action: sudo usermod -aG render,video,ollama $USER
      Then: User must log out and back in
      After: Verify with `groups $USER` (should show render, video, ollama)
```

### Step 4: Is Ollama installed?

```
Check: command -v ollama >/dev/null
├─ YES
│  └─ Proceed to Step 5
└─ NO (or wrong version < 0.24.0)
   ├─ Is Docker Ollama running? docker ps | grep ollama
   │  ├─ YES: Stop Docker container first (docker stop <container>)
   │  └─ NO: Safe to install
   └─ INSTALL ACTION:
      curl -fsSL https://ollama.com/install.sh | sh
      This will:
       • Install native Ollama service
       • Add 'ollama' user
       • Create systemd service
       • Start service automatically
```

### Step 5: Is Vulkan GPU support configured?

```
Check: sudo cat /etc/systemd/system/ollama.service.d/override.conf
├─ Shows OLLAMA_VULKAN=1
│  └─ Proceed to Step 6
└─ Missing or empty
   └─ CRITICAL CONFIG
      Action: Create override.conf with GPU settings
      Location: /etc/systemd/system/ollama.service.d/override.conf
      Content:
        [Service]
        Environment="OLLAMA_VULKAN=1"
        Environment="RUSTICL_ENABLE=iris"
        Environment="GPU_MAX_ALLOC_PERCENT=100"
        Environment="OLLAMA_GPU_OVERHEAD=0"
      Then: sudo systemctl daemon-reload && sudo systemctl restart ollama
```

### Step 6: Verify GPU inference works

```
Check: sudo journalctl -u ollama --no-pager -n 30 | grep -i vulkan
├─ Shows Vulkan GPU detected with size (e.g., "23.4 GiB")
│  └─ SUCCESS! GPU acceleration is working
└─ No Vulkan mention or error shown
   ├─ Check if service is running: sudo systemctl status ollama
   ├─ Restart: sudo systemctl restart ollama
   ├─ Wait 10 seconds
   └─ Check logs again
```

---

## Setup Actions

### Action: Add User to GPU Groups

**Purpose:** Allow user to access `/dev/dri/renderD128` (render node)

**Prerequisites:** User not in render/video/ollama groups

**Command:**
```bash
sudo usermod -aG render,video,ollama $USER
```

**Post-action:**
1. User must **log out completely** (or run `newgrp render` for temporary fix)
2. Verify with: `groups $USER` (should include render, video, ollama)
3. Verify access: `ls /dev/dri/renderD128` (should work without error)

**Timeout:** After user logs back in, run system analysis again

---

### Action: Install Ollama

**Purpose:** Install native Ollama systemd service

**Prerequisites:**
- i915 driver loaded
- Render node available
- No Docker Ollama running on port 11434

**Command:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**What it does:**
- Downloads Ollama binary to `/usr/local/bin/ollama`
- Creates `ollama` system user
- Adds user to render and video groups (automatically)
- Creates `/etc/systemd/system/ollama.service`
- Starts service: `sudo systemctl start ollama`
- Enables on boot: `sudo systemctl enable ollama`

**Post-action:**
- Check: `sudo systemctl status ollama` (should show active/running)
- Logs: `sudo journalctl -u ollama -n 20` (check for startup messages)
- Proceed to GPU configuration

**Timeout:** 2-3 minutes for install

---

### Action: Configure Vulkan GPU Support

**Purpose:** Enable GPU acceleration via Vulkan/Mesa ANV

**Prerequisites:**
- Ollama installed
- i915 driver loaded
- Mesa Vulkan libraries available (usually pre-installed on Ubuntu 24.04)

**Command:**
```bash
# Create directory if needed
sudo mkdir -p /etc/systemd/system/ollama.service.d

# Write override configuration
sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null << 'EOF'
[Service]
Environment="OLLAMA_VULKAN=1"
Environment="RUSTICL_ENABLE=iris"
Environment="GPU_MAX_ALLOC_PERCENT=100"
Environment="OLLAMA_GPU_OVERHEAD=0"
EOF

# Reload systemd and restart service
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

**What it does:**
- `OLLAMA_VULKAN=1` - Forces Vulkan GPU backend (vs. CPU)
- `RUSTICL_ENABLE=iris` - Enables Intel Mesa OpenCL support
- `GPU_MAX_ALLOC_PERCENT=100` - Uses full GPU memory
- `OLLAMA_GPU_OVERHEAD=0` - Minimizes overhead (for iGPU)

**Post-action:**
- Wait 5 seconds for service restart
- Check: `sudo systemctl status ollama`
- Verify GPU detected: `sudo journalctl -u ollama -n 50 | grep -i "Vulkan\|GPU"`
- Look for: `inference compute ... library=Vulkan name=Vulkan0 description="Intel(R)..."`

---

### Action: Fix Model Directory Permissions

**Purpose:** Ensure models owned by `ollama` user (prevents permission errors)

**Prerequisites:**
- Ollama installed
- Models directory exists at `/usr/share/ollama/.ollama/`

**Command:**
```bash
sudo chown -R ollama:ollama /usr/share/ollama/.ollama/
```

**When needed:**
- Models were downloaded by different user (e.g., from Docker setup)
- Ollama shows permission denied errors when loading models

**Post-action:**
- Verify: `ls -la /usr/share/ollama/.ollama/` (should show ollama:ollama ownership)

---

### Action: Hold Critical Packages

**Purpose:** Prevent `apt autoremove` from removing packages needed for GPU acceleration

**Prerequisites:**
- Setup completed (Ollama installed, Vulkan configured)

**Command:**
```bash
sudo apt-mark hold mesa-vulkan-drivers intel-gpu-tools jq
```

**What it does:**
- `mesa-vulkan-drivers` — Intel Vulkan driver (GPU inference won't work without it)
- `intel-gpu-tools` — `intel_gpu_top` for real-time GPU monitoring
- `jq` — Required by `collect-state.sh` for JSON output

**Post-action:**
- Check: `apt-mark showhold` (should list the held packages)
- Remember: `apt-mark unhold <package>` if you ever need to upgrade or remove them

---

## Verification Steps

### Quick Health Check

```bash
# Service running?
sudo systemctl status ollama
# Expected: active (running)

# GPU detected?
sudo journalctl -u ollama --no-pager -n 50 | grep -i "Vulkan\|GPU"
# Expected: Shows Vulkan GPU with available VRAM (e.g., "23.4 GiB")

# Render node accessible?
ls -l /dev/dri/renderD*
# Expected: User can read/write without sudo
```

### Test Model Inference

```bash
# Pull a small test model
ollama pull qwen2.5:1.5b

# Run test inference
ollama run qwen2.5:1.5b "Explain what GPU acceleration means in 2 sentences."

# Check processor usage
ollama ps
# Expected PROCESSOR column: shows % GPU (e.g., "100% GPU" or "95% GPU")
```

### Advanced Diagnostics

```bash
# Real-time GPU monitoring
sudo intel_gpu_top
# Expected: Shows GPU engine utilization percentage

# Detailed service logs
sudo journalctl -u ollama -f
# Run a model in another terminal
# Watch logs for inference activity

# Check system memory during inference
watch -n 1 'free -h && echo "---" && ollama ps'
```

---

## Troubleshooting Guide

### Issue: "Permission denied on /dev/dri/renderD128"

**Cause:** User not in `render` group

**Diagnosis:**
```bash
groups $USER | grep -q render && echo "User is in render" || echo "User NOT in render"
```

**Solution:**
1. Add to group: `sudo usermod -aG render,video,ollama $USER`
2. **User must log out and back in** (critical!)
3. Verify: `groups $USER` (should include render)

**Alternative (temporary):**
```bash
newgrp render  # Activates render group for this session only
# Then retry the command
```

---

### Issue: "No NVIDIA/AMD GPU detected" warning

**Cause:** Expected! Ollama installer doesn't know about Intel iGPUs

**Diagnosis:** This is just a warning, not an error

**Solution:** Configure Vulkan override (Action: Configure Vulkan GPU Support)

**Result:** After override, warning disappears and GPU is used

---

### Issue: Port 11434 already in use

**Cause:** Something else is already listening on port 11434.

Can be:
- **A manually-run `ollama serve`** from a previous session
- **A Docker Ollama container** still running
- **Another process or second Ollama instance**

This makes the systemd service fail immediately on boot, entering an **infinite restart loop** (systemd keeps retrying since `Restart=always` is set). Unless the conflicting process is killed, the loop never stops.

**Diagnosis (always start here):**
```bash
# Find exactly what's on port 11434
sudo ss -tlnp | grep 11434
# Example output showing PID and process name:
#   LISTEN 0 4096 127.0.0.1:11434 0.0.0.0:* users:(("ollama",pid=1234,fd=5))
```

**Solution — kill the conflicting process:**
```bash
# Get the PID from the ss output above, then:
sudo kill <PID>
# Wait a moment, then verify port is free:
sudo ss -tlnp | grep 11434 || echo "Port is free"

# If systemd is in a restart loop, stop it first:
sudo systemctl stop ollama

# Then start cleanly:
sudo systemctl start ollama
```

**If it's a Docker container specifically:**
```bash
docker ps | grep ollama
docker stop <container-id>
```

**If the process keeps coming back (e.g., a user-terminal `ollama serve` launched on boot):**
```bash
# Find the process that keeps restarting
ps aux | grep "ollama serve" | grep -v grep
# Kill it permanently
sudo pkill -f "ollama serve"
```

**Then:** Verify with `sudo systemctl status ollama` and `ollama ps`

---

### Issue: Vulkan GPU not detected after setup

**Cause:** Service didn't restart properly or config not applied

**Diagnosis:**
```bash
# Check if override exists
sudo cat /etc/systemd/system/ollama.service.d/override.conf

# Check service environment
systemctl show -p Environment --user ollama

# Check logs
sudo journalctl -u ollama -n 100 | grep -i "vulkan\|gpu\|error"
```

**Solution:**
1. Verify override.conf exists and has OLLAMA_VULKAN=1
2. Reload: `sudo systemctl daemon-reload`
3. Restart: `sudo systemctl restart ollama`
4. Wait 5 seconds
5. Check logs: `sudo journalctl -u ollama -n 30 | grep -i vulkan`

---

### Issue: Model loading fails with permission error

**Cause:** Model files owned by wrong user

**Diagnosis:**
```bash
ls -la /usr/share/ollama/.ollama/models/ | head
# Check ownership (should be ollama:ollama)
```

**Solution:**
```bash
sudo chown -R ollama:ollama /usr/share/ollama/.ollama/
```

**Then:** Try loading model again

---

### Issue: Service crashes or won't start

**Diagnosis:**
```bash
# Check service status
sudo systemctl status ollama
# Look for error message

# Check detailed logs
sudo journalctl -u ollama -n 100 | tail -20

# Check if binary exists
which ollama
ls -l /usr/local/bin/ollama
```

**Solutions by cause:**

**Binary missing:**
```bash
# Reinstall
curl -fsSL https://ollama.com/install.sh | sh
```

**Service file corrupted:**
```bash
# Check service file
sudo cat /etc/systemd/system/ollama.service

# Reinstall service
sudo systemctl stop ollama
curl -fsSL https://ollama.com/install.sh | sh
```

**Out of disk space:**
```bash
df -h
# Check if / or /usr is full
# Models are in /usr/share/ollama/.ollama/models/
```

---

## Model Selection Guide

Based on available VRAM (for Intel NUC6i7KYB with ~12-13 GB available):

| Model | Size | Fits? | Speed | Quality | Use Case |
|-------|------|-------|-------|---------|----------|
| qwen2.5:0.5b | 397 MB | ✅ | Very Fast | Low | Testing, quick answers |
| qwen2.5:1.5b | 986 MB | ✅ | Fast | Medium | Recommended starting point |
| llama3.2:3b | 2.0 GB | ✅ | Fast | Medium | General purpose |
| qwen2.5:7b | 4.7 GB | ✅ | Medium | High | Sweet spot for quality/speed |
| llama3.1:8b | 4.9 GB | ✅ | Medium | High | Similar to qwen2.5:7b |
| qwen2.5:14b | 9.0 GB | ✅ | Slow | Very High | Best quality, fits barely |
| qwen3.5:27b | 17 GB | ⚠️ | Very Slow | Excellent | Will offload to CPU (slower) |

**Recommendation:** Start with `qwen2.5:1.5b`, then try `qwen2.5:7b`

---

## Agent Implementation Notes

### Key Behaviors

1. **Collect First:** Always collect system state before making decisions
2. **Decide Then Act:** Never run installation without analyzing state first
3. **Confirm Before Executing:** Tell user what you're about to do and get approval
4. **Verify After:** Always check success after each action
5. **Handle Errors:** If command fails, explain why and suggest fix

### Interaction Pattern

```
Agent: [Analyzes system state]
Agent: "Your system has Intel GPU, but user is not in render group. 
        This is the first blocker. I'll add you to the group."

User: [Approves]

Agent: [Executes command]
Agent: "Done! Now you need to log out and back in for the change to take effect."

User: [Logs out/back in]

Agent: [Re-analyzes, finds next blocker]
```

### Handling Unknowns

If system state is ambiguous:
- Ask user clarifying questions
- Suggest diagnostic commands to run
- Explain what you're looking for and why
- Don't guess or assume

---

## Environment Variables

Set by systemd override for GPU acceleration:

```bash
OLLAMA_VULKAN=1                 # Force Vulkan backend
RUSTICL_ENABLE=iris             # Enable Intel Mesa OpenCL
GPU_MAX_ALLOC_PERCENT=100       # Use full GPU memory
OLLAMA_GPU_OVERHEAD=0           # Minimize overhead
```

Optional for debugging:
```bash
OLLAMA_DEBUG=1                  # Verbose logging
OLLAMA_KEEP_ALIVE=5m            # Keep models loaded (for frequent use)
```

---

## Success Indicators

User's system is **ready for GPU inference** when:

✅ Ollama service is running (`sudo systemctl status ollama` shows active)  
✅ GPU detected in logs (`journalctl` shows Vulkan GPU with size)  
✅ User can run test model (`ollama run qwen2.5:1.5b "test"`)  
✅ GPU is actually being used (`ollama ps` shows % GPU in PROCESSOR column)  

---

## Failure States (Stop & Require Manual Help)

Stop setup and recommend manual intervention if:

❌ GPU is not Intel (NVIDIA/AMD detected)  
❌ i915 driver not loaded  
❌ No render nodes found  
❌ Kernel is very old (< 5.x)  
❌ OS is not Ubuntu 22.04 or 24.04  
❌ User has no sudo access  
❌ /usr filesystem is full  

For these, explain the issue and point user to manual resources.

---

## External Resources

- **Ollama Documentation:** https://github.com/ollama/ollama
- **Mesa ANV (Intel Vulkan):** https://docs.mesa3d.org/drivers/iris.html
- **Intel iGPU on Linux:** https://www.intel.com/content/www/us/en/support/articles/000090440/graphics.html
- **Ubuntu GPU Support:** https://ubuntu.com/

---

## Contact & Support

This guide covers standard Intel iGPU setups on Ubuntu 24.04 LTS.

For issues:
1. Check the Troubleshooting Guide (above)
2. Run diagnostic commands (Verification Steps)
3. Check Ollama GitHub issues
4. Consult system documentation for your specific hardware

---

**Document Version:** 2.0-agent-driven  
**Last Updated:** May 2026  
**Compatible with:** Ollama 0.24.0+, Ubuntu 24.04 LTS, Intel Iris Pro 580 / Newer iGPUs
