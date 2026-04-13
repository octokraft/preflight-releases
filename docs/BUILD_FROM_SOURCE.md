# Build Preflight From Source

The public repository is for distribution. Source development happens in a private repository.

If you have source access, these are the main local build paths.

## Build the CLI

```bash
go build -o bin/preflight ./cmd/preflight
```

## Run targeted tests

```bash
go test ./internal/preflight ./cmd/preflight
```

## Build a release archive

```bash
./scripts/package-release.sh
```

Override the target release repo baked into the updater:

```bash
PREFLIGHT_RELEASE_REPO=octokraft/preflight-releases ./scripts/package-release.sh 0.1.0
```

The release archive includes the `preflight` binary only.
