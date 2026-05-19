# Security Policy

## Scope

This repo contains static documentation files and a shell script for system state collection. It does not contain executable server-side code or handle sensitive data.

## What `collect-state.sh` does

- Reads-only: GPU info, user groups, installed packages, running services
- Outputs JSON to stdout and a temp file at `/tmp/ollama-setup-state-$$.json`
- Makes no modifications to the system
- Requires `sudo` only for checking `systemctl` status (fails gracefully without it)

## What it does NOT do

- Collect passwords, SSH keys, environment variables, or file contents
- Send data anywhere (output is printed to terminal, user chooses to share)
- Modify system configuration

## Reporting a vulnerability

If you find a security issue in `collect-state.sh` or any other file, please open an issue with the "security" label rather than a public pull request. Do not post detailed exploit steps publicly before a fix is available.
