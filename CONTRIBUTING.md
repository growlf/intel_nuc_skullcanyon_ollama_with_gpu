# Contributing

Thanks for considering contributing to this project.

## Scope

This repo is a deployment package of static files (documentation + one shell script) for an Opencode agent-driven setup system. Contributions should stay within that scope.

## What's helpful

- **Bug fixes** in `collect-state.sh` — better hardware detection, edge cases, portability
- **Troubleshooting additions** to `AGENT_ORCHESTRATION.md` — real-world failure modes you've encountered
- **Clarifications** — instructions that could be misinterpreted
- **New hardware support** — verified steps for additional Intel iGPU models

## What's not

- Adding support for NVIDIA or AMD GPUs (out of scope)
- Rewriting the agent orchestration into a standalone script (defeats the purpose)
- Large structural changes without prior discussion

## Process

1. Open an issue describing your change before starting work
2. Fork the repo, make your changes on a branch
3. Test with a real system if changing `collect-state.sh`
4. Submit a pull request with a clear description

## Style

- Keep markdown concise — these files are parsed by LLM agents, not just humans
- Shell scripts use `set -u`, `2>/dev/null` for silent fallbacks, and `jq` for JSON
- Prefer executable truth over prose; if a command works, include it
