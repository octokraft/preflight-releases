# Preflight

A free, local-only CLI for pre-PR branch checks. Reads a git working tree, builds a code graph, reports whether a branch is ready to become a pull request.

![Preflight in action](docs/assets/preflight-demo.gif)

```
preflight · main
mode: offline | risk: medium | files: 12 | +843/-21
12 changed files grouped into 2 review areas. Close, but review 2 risks
before you open the PR.

- API handlers [low known] 4 files, 120 lines
- Billing zones [medium unclear] 8 files, 742 lines

Team-level tracking for these signals: https://octokraft.com/preflight
Preflight is free and local · https://octokraft.com/preflight · issues: https://github.com/octokraft/preflight-releases/issues
```

## Install

macOS and Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.sh | sh
```

Windows:

```powershell
irm https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.ps1 | iex
```

Node.js environments (macOS, Linux, Windows):

```bash
npm install -g @octokraft/preflight
# or one-shot
npx @octokraft/preflight analyze
```

Supported platforms: Linux (amd64, arm64), macOS (Intel, Apple Silicon), Windows (amd64).

## What Preflight does

A single Go binary. Fully local. No account, no upload, no LLM dependency. Optional agent-backed analysis and optional MCP enrichment are both off by default.

Every branch analysis yields:

- **A verdict** — `ready`, `review`, or `hold`.
- **Blockers and warnings** — concrete findings with file references and scope tags (`BRANCH`, `MODIFIED`, `STAGED`).
- **Impact zones** — changed files grouped by package and purpose, each with a risk score.
- **Untested exported symbols** — newly exported functions with no test coverage in the branch.
- **High fan-out modules** — files whose references spread widely, so small edits have large blast radius.
- **Dead code that changed** — functions touched in the branch that nothing in the repo calls.
- **Scope creep** — changes outside the nominal intent of the branch.
- **Test quality signals** — coverage structure, assertion density, mock usage.
- **VCS state in one panel** — branch, staged, unstaged, untracked, stashes, recent commits, committed branch changes.

A local dashboard is available on `127.0.0.1:3647` when the daemon is running, with five panels: Overview, Issues, Files, Changes, Review.

## Quick start

```bash
preflight analyze --path /path/to/repo
preflight start --path /path/to/repo          # background daemon + dashboard
preflight status --path /path/to/repo
```

One-shot JSON for scripts and agents:

```bash
preflight analyze --path /path/to/repo --json
```

## Agent integration

`preflight skill` prints a Claude Code and Cursor skill definition that a coding agent installs once and then invokes at the end of a task. When the skill is active, an AI agent checks its own work against the verdict before claiming done.

```bash
preflight skill > ~/.claude/skills/preflight.md
```

## Configuration

All fields in `~/.preflight.json` are optional. Preflight runs with zero config.

```json
{
  "port": 3647,
  "agent": "codex",
  "agent_model": "gpt-5.4",
  "agent_timeout": 300,
  "octokraft_api_key": "ok_...",
  "projects": {
    "my-repo": {
      "path": "/home/user/source/my-repo",
      "octokraft_project": "My Project"
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `port` | Dashboard server port (default: 3647) |
| `agent` | Optional AI agent for zone classification: `codex`, `claude-code`, `gemini`, `opencode`, `kilo`, `roo` |
| `agent_model` | Model name for the agent |
| `agent_timeout` | Agent timeout in seconds |
| `octokraft_api_key` | Octokraft API key for online enrichment |
| `projects` | Map of repo directory names to project config |

## Preflight and Octokraft

Preflight is local by design. It runs on a developer's machine, against the working tree, before the PR exists.

Octokraft is the team platform at [octokraft.com](https://octokraft.com). It runs in the team's cloud account, against main and every PR, and tracks health, hotspots, conventions, and PR analysis across repos over time.

The two products are independent. Preflight works fully offline. If a repo has a `.mcp.json` with an Octokraft entry (common for teams already using Octokraft's MCP for their AI agents), Preflight auto-detects it and enriches the local analysis with team context at zero config. No Action, no CI runner, no webhook — CI and team-level enforcement are Octokraft's surface.

## Releases

Compiled archives and `checksums.txt` live on the [Releases page](https://github.com/octokraft/preflight-releases/releases).

## Docs

- [Install guide](docs/INSTALL.md)
- [Build from source](docs/BUILD_FROM_SOURCE.md)

## License

MIT. Source development happens in a private repository; tagged releases are built and published here automatically.
