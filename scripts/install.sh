#!/bin/sh
# Preflight install script. Downloads a release archive and installs the binary.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.sh | sh
#   curl -fsSL https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.sh | sh -s -- --version=0.2.0
#
set -eu

REPO="${PREFLIGHT_RELEASE_REPO:-octokraft/preflight-releases}"
VERSION=""
INSTALL_DIR="${PREFLIGHT_BIN_DIR:-}"
TMP_DIR=""

info()  { printf '  \033[1;34m→\033[0m %s\n' "$*"; }
ok()    { printf '  \033[1;32m✓\033[0m %s\n' "$*"; }
err()   { printf '  \033[1;31m✗\033[0m %s\n' "$*" >&2; }
fatal() { err "$@"; exit 1; }

download() {
    if command -v curl > /dev/null 2>&1; then
        curl -fsSL -o "$2" "$1"
    elif command -v wget > /dev/null 2>&1; then
        wget -qO "$2" "$1"
    else
        fatal "Neither curl nor wget found. Install one and try again."
    fi
}

detect_os() {
    case "$(uname -s)" in
        Linux*)  OS="linux" ;;
        Darwin*) OS="darwin" ;;
        *) fatal "Unsupported OS: $(uname -s)" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) fatal "Unsupported architecture: $(uname -m)" ;;
    esac
}

detect_paths() {
    if [ -z "$INSTALL_DIR" ]; then
        INSTALL_DIR="$HOME/.local/bin"
    fi
    mkdir -p "$INSTALL_DIR"
}

get_latest_version() {
    if [ -n "$VERSION" ]; then
        return
    fi
    info "Fetching latest version..."
    tmp=$(mktemp)
    download "https://api.github.com/repos/${REPO}/releases/latest" "$tmp" || fatal "Failed to fetch latest release metadata."
    VERSION=$(sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\([^"]*\)".*/\1/p' "$tmp" | head -1)
    rm -f "$tmp"
    if [ -z "$VERSION" ]; then
        fatal "Could not determine latest version. Specify one with --version=X.Y.Z"
    fi
}

do_install() {
    archive="preflight-v${VERSION}-${OS}-${ARCH}.tar.gz"
    base_url="https://github.com/${REPO}/releases/download/v${VERSION}"
    archive_url="${base_url}/${archive}"
    checksum_url="${base_url}/checksums.txt"

    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    info "Downloading preflight v${VERSION} for ${OS}/${ARCH}..."
    download "$archive_url" "${TMP_DIR}/${archive}" || fatal "Download failed."
    download "$checksum_url" "${TMP_DIR}/checksums.txt" || fatal "Failed to download checksums."

    expected=$(grep "${archive}" "${TMP_DIR}/checksums.txt" | awk '{print $1}')
    [ -n "$expected" ] || fatal "Checksum not found for ${archive}"

    if command -v sha256sum > /dev/null 2>&1; then
        actual=$(sha256sum "${TMP_DIR}/${archive}" | awk '{print $1}')
    elif command -v shasum > /dev/null 2>&1; then
        actual=$(shasum -a 256 "${TMP_DIR}/${archive}" | awk '{print $1}')
    else
        fatal "Neither sha256sum nor shasum found. Cannot verify checksum."
    fi

    [ "$expected" = "$actual" ] || fatal "Checksum mismatch."

    info "Extracting..."
    tar -xzf "${TMP_DIR}/${archive}" -C "${TMP_DIR}"
    [ -f "${TMP_DIR}/preflight" ] || fatal "preflight binary missing from archive"

    install -m 755 "${TMP_DIR}/preflight" "${INSTALL_DIR}/preflight"

    case ":$PATH:" in
        *":${INSTALL_DIR}:"*) ;;
        *)
            err "${INSTALL_DIR} is not in your PATH."
            info "Add it with: export PATH=\"${INSTALL_DIR}:\$PATH\""
            ;;
    esac

    echo ""
    ok "preflight v${VERSION} installed to ${INSTALL_DIR}/preflight"
    echo ""
    info "Next steps:"
    echo "  preflight init --path /path/to/repo"
    echo "  preflight start --path /path/to/repo"
    echo "  preflight status --path /path/to/repo"
    echo ""
}

parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --version=*) VERSION="${arg#*=}" ;;
            --dir=*) INSTALL_DIR="${arg#*=}" ;;
            --repo=*) REPO="${arg#*=}" ;;
            --help|-h)
                echo "Usage: install.sh [--version=X.Y.Z] [--dir=/path/to/bin] [--repo=owner/name]"
                exit 0
                ;;
            *)
                fatal "Unknown argument: $arg"
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    detect_os
    detect_arch
    detect_paths
    get_latest_version
    do_install
}

main "$@"
