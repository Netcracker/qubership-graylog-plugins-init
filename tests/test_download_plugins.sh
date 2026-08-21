#!/usr/bin/env bash

set -euo pipefail

REPOSITORY_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
readonly REPOSITORY_ROOT
TEST_ROOT=$(mktemp -d)
readonly TEST_ROOT
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/bin"
cat >"$TEST_ROOT/bin/wget" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

output=''
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --no-check-certificate)
            echo 'TLS certificate verification was disabled' >&2
            exit 1
            ;;
        --output-document)
            output=$2
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

printf 'plugin-content\n' >"$output"
EOF
chmod +x "$TEST_ROOT/bin/wget"

run_downloader() {
    local fixture=$1
    local downloads=$2

    PLUGINS_FILE="$fixture" \
        PLUGIN_DOWNLOADS_PATH="$downloads" \
        PATH="$TEST_ROOT/bin:$PATH" \
        "$REPOSITORY_ROOT/download_plugins.sh"
}

valid_list="$TEST_ROOT/valid.list"
cat >"$valid_list" <<'EOF'
# Comments and blank lines are allowed.

https://github.com/example/plugin/releases/download/1.0.0/plugin-1.0.0.jar
EOF
run_downloader "$valid_list" "$TEST_ROOT/valid-downloads"
test -s "$TEST_ROOT/valid-downloads/plugin-1.0.0.jar"

invalid_source_list="$TEST_ROOT/invalid-source.list"
cat >"$invalid_source_list" <<'EOF'
https://example.com/plugin-1.0.0.jar
EOF
if run_downloader "$invalid_source_list" "$TEST_ROOT/invalid-source-downloads"; then
    echo 'Downloader accepted a plugin outside GitHub Releases' >&2
    exit 1
fi
