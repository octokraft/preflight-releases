# Preflight

`preflight` is a local-first CLI and dashboard for understanding branch risk before the work becomes a pull request.

This public repository is the distribution surface for Preflight:

- release bundles and checksums
- shell and PowerShell installers
- user-facing documentation
- issues and release notes

Source development happens in a private repository. Tagged releases are built there and published here automatically.

## Install

Linux and macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.sh | sh
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.ps1 | iex
```

Supported platforms:

- Linux (amd64, arm64)
- macOS (Intel, Apple Silicon)
- Windows (amd64)

## What Preflight gives you

- changed-file and blast-radius analysis against your base branch
- local branch readiness with blocker detection before PR creation
- test quality, scope drift, and impact summaries for the current worktree
- optional AI review that stays scoped to the exact snapshot being analyzed
- a local dashboard plus CLI commands for status, issues, logs, and review

## Releases

Download compiled archives from the [Releases](https://github.com/octokraft/preflight-releases/releases) page. Each release includes:

- a platform archive
- `checksums.txt`

## Docs

- [Install guide](docs/INSTALL.md)
- [Build from source](docs/BUILD_FROM_SOURCE.md)

## Quick start after install

```bash
preflight init --path /path/to/repo
preflight start --path /path/to/repo
preflight status --path /path/to/repo
```
