# Install Preflight

## Supported platforms

- Linux (amd64, arm64)
- macOS (Intel, Apple Silicon)
- Windows (amd64)

## Unix / macOS

Install the latest release:

```bash
curl -fsSL https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.sh | sh
```

Install a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.sh | sh -s -- --version=0.2.0
```

Flags:

- `--version=X.Y.Z` - install a specific version
- `--dir=/path/to/bin` - override install directory (default: `~/.local/bin`)
- `--repo=owner/name` - override release repository

The installer downloads the correct archive for your OS and architecture, verifies the checksum, and places the binary at `~/.local/bin/preflight`.

## Windows

Install the latest release:

```powershell
irm https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.ps1 | iex
```

Install a specific version:

```powershell
irm https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.ps1 | iex -Version 0.2.0
```

The installer places `preflight.exe` into `%LOCALAPPDATA%\Preflight` and adds that directory to the user `PATH`.

## Verify

```bash
preflight version
```

## Update

```bash
preflight update
```

Or rerun the install script to get the latest version.

## Quick start

```bash
preflight init --path /path/to/repo
preflight start --path /path/to/repo
preflight status --path /path/to/repo
```
