#!/bin/bash

################################################################################
# Ollama Intel GPU Setup - System State Collector
# For use with Opencode Agent
#
# This script collects system information and outputs JSON that the agent
# can analyze and use to guide setup. Run once at the beginning.
################################################################################

set -u

# Create temporary state file
STATE_FILE="/tmp/ollama-setup-state-$$.json"

# Initialize JSON
state="{}"

echo "🔍 Collecting system state..." >&2
echo "" >&2

# ─── Timestamp ───
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
state=$(echo "$state" | jq --arg ts "$timestamp" '. + {timestamp: $ts}')

# ─── OS & Kernel ───
echo "📋 OS and Kernel..." >&2
os_version=$(grep VERSION_ID /etc/os-release 2>/dev/null | cut -d'"' -f2)
os_codename=$(grep VERSION_CODENAME /etc/os-release 2>/dev/null | cut -d'=' -f2)
kernel=$(uname -r)
state=$(echo "$state" | jq --arg os "$os_version" --arg code "$os_codename" --arg k "$kernel" \
  '. + {os: {version: $os, codename: $code}, kernel: $k}')

# ─── CPU ───
echo "🔧 CPU..." >&2
cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs)
cpu_cores=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo "0")
state=$(echo "$state" | jq --arg m "$cpu_model" --arg c "$cpu_cores" '. + {cpu: {model: $m, cores: $c}}')

# ─── GPU ───
echo "🎮 GPU..." >&2
if command -v lspci &>/dev/null; then
    gpu_line=$(lspci -nn 2>/dev/null | grep -iE "vga|3d" | head -1)
    
    if [[ -n "$gpu_line" ]]; then
        i915_loaded=0
        if lspci -v -s 00:02.0 2>/dev/null | grep -q "Kernel driver in use: i915"; then
            i915_loaded=1
        fi
        
        render_node=$(ls /dev/dri/renderD* 2>/dev/null | head -1)
        if [[ -z "$render_node" ]]; then
            render_node=""
        fi
        
        state=$(echo "$state" | jq --arg gpu "$gpu_line" --arg i915 "$i915_loaded" --arg rn "$render_node" \
          '. + {gpu: {pci: $gpu, i915_loaded: ($i915 | tonumber), render_node: $rn}}')
    else
        state=$(echo "$state" | jq '. + {gpu: {pci: "", i915_loaded: 0, render_node: ""}}')
    fi
else
    state=$(echo "$state" | jq '. + {gpu: {pci: "unknown", i915_loaded: null, render_node: null}}')
fi

# ─── User & Groups ───
echo "👤 User..." >&2
current_user=$(whoami)
in_render=0
in_video=0
in_ollama=0
in_docker=0

[[ $(groups "$current_user" 2>/dev/null) =~ render ]] && in_render=1
[[ $(groups "$current_user" 2>/dev/null) =~ video ]] && in_video=1
[[ $(groups "$current_user" 2>/dev/null) =~ ollama ]] && in_ollama=1
[[ $(groups "$current_user" 2>/dev/null) =~ docker ]] && in_docker=1

state=$(echo "$state" | jq --arg u "$current_user" --arg r "$in_render" --arg v "$in_video" --arg o "$in_ollama" --arg d "$in_docker" \
  '. + {user: {name: $u, in_render: ($r | tonumber), in_video: ($v | tonumber), in_ollama: ($o | tonumber), in_docker: ($d | tonumber)}}')

# ─── Ollama ───
echo "🦙 Ollama..." >&2
ollama_installed=0
ollama_version=""
ollama_running=0

if command -v ollama &>/dev/null; then
    ollama_installed=1
    ollama_version=$(ollama --version 2>/dev/null || echo "unknown")
    
    if sudo systemctl is-active --quiet ollama 2>/dev/null; then
        ollama_running=1
    fi
fi

state=$(echo "$state" | jq --arg inst "$ollama_installed" --arg ver "$ollama_version" --arg run "$ollama_running" \
  '. + {ollama: {installed: ($inst | tonumber), version: $ver, running: ($run | tonumber)}}')

# ─── Docker ───
echo "🐳 Docker..." >&2
docker_ollama=""
if command -v docker &>/dev/null; then
    docker_ollama=$(docker ps --format "{{.ID}}" --filter "publish=11434" 2>/dev/null | head -1)
fi

state=$(echo "$state" | jq --arg do "$docker_ollama" '. + {docker: {ollama_container: $do}}')

# ─── Port 11434 Conflict Check ───
echo "🔌 Port 11434..." >&2
port_conflict=0
port_conflict_pid=""
port_conflict_process=""
if command -v ss &>/dev/null; then
    conflict_line=$(ss -tlnp 2>/dev/null | grep ":11434 " | head -1)
    if [[ -n "$conflict_line" ]]; then
        port_conflict=1
        # PID/process visible only with root; try sudo if available
        if command -v sudo &>/dev/null; then
            priv_line=$(sudo ss -tlnp 2>/dev/null | grep ":11434 " | head -1)
            if [[ -n "$priv_line" ]]; then
                port_conflict_pid=$(echo "$priv_line" | grep -oP 'pid=\K[0-9]+' || echo "")
                port_conflict_process=$(echo "$priv_line" | grep -oP 'users:\(\("[^"]+' | grep -oP '"[^"]+' | tr -d '"' || echo "")
                # Exclude the legit systemd ollama service (it's supposed to hold the port)
                if [[ "$port_conflict_process" == "ollama" ]]; then
                    ollama_svc_pid=$(sudo systemctl show --property=MainPID ollama 2>/dev/null | cut -d= -f2)
                    if [[ -n "$ollama_svc_pid" && "$ollama_svc_pid" != "0" && "$port_conflict_pid" == "$ollama_svc_pid" ]]; then
                        port_conflict=0
                        port_conflict_pid=""
                        port_conflict_process=""
                    fi
                fi
            fi
        fi
    fi
fi

state=$(echo "$state" | jq \
  --arg c "$port_conflict" \
  --arg pid "$port_conflict_pid" \
  --arg proc "$port_conflict_process" \
  '. + {port_conflict: {port: 11434, conflict: ($c | tonumber), pid: $pid, process: $proc}}')

# ─── Memory ───
echo "💾 Memory..." >&2
total_mem=$(free -h 2>/dev/null | grep Mem | awk '{print $2}')
available_mem=$(free -h 2>/dev/null | grep Mem | awk '{print $7}')

state=$(echo "$state" | jq --arg tot "$total_mem" --arg avl "$available_mem" \
  '. + {memory: {total: $tot, available: $avl}}')

# ─── Vulkan/Mesa ───
echo "🎨 Vulkan/Mesa..." >&2
mesa_installed=0
if dpkg -l 2>/dev/null | grep -q mesa-vulkan-drivers; then
    mesa_installed=1
fi

state=$(echo "$state" | jq --arg m "$mesa_installed" '. + {mesa: {vulkan_drivers_installed: ($m | tonumber)}}')

# ─── Save and output ───
echo "$state" > "$STATE_FILE"

echo "" >&2
echo "✅ System state collected!" >&2
echo "" >&2
echo "State file: $STATE_FILE" >&2
echo "" >&2
echo "Copy the following JSON and provide it to Opencode agent:" >&2
echo "" >&2

# Output the JSON
cat "$STATE_FILE" | jq '.'

echo "" >&2
echo "Or use this command to send directly:" >&2
echo "  cat $STATE_FILE" >&2
echo "" >&2
