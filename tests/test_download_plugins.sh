#!/usr/bin/env bash

set -euo pipefail

REPOSITORY_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
readonly REPOSITORY_ROOT
TEST_ROOT=$(mktemp -d)
readonly TEST_ROOT
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/bin"

write_wget_stub() {
    local empty=${1:-0}

    cat >"$TEST_ROOT/bin/wget" <<EOF
#!/usr/bin/env bash
set -euo pipefail

output=''
while [[ "\$#" -gt 0 ]]; do
    case "\$1" in
        --no-check-certificate)
            echo 'TLS certificate verification was disabled' >&2
            exit 1
            ;;
        --output-document)
            output=\$2
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [[ "${empty}" -eq 1 ]]; then
    : >"\$output"
else
    printf 'plugin-content\\n' >"\$output"
fi
EOF
    chmod +x "$TEST_ROOT/bin/wget"
}

run_downloader() {
    local fixture=$1
    local downloads=$2

    PLUGINS_FILE="$fixture" \
        PLUGIN_DOWNLOADS_PATH="$downloads" \
        PATH="$TEST_ROOT/bin:$PATH" \
        "$REPOSITORY_ROOT/download_plugins.sh"
}

assert_fails_with() {
    local fixture=$1
    local downloads=$2
    local needle=$3
    local err

    err=$(mktemp)
    if run_downloader "$fixture" "$downloads" 2>"$err"; then
        echo 'Downloader succeeded when a failure was required' >&2
        cat "$err" >&2
        exit 1
    fi
    if ! grep -q "$needle" "$err"; then
        echo "Downloader stderr did not contain: $needle" >&2
        cat "$err" >&2
        exit 1
    fi
}

write_wget_stub 0

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
assert_fails_with "$invalid_source_list" "$TEST_ROOT/invalid-source-downloads" 'Unsupported plugin URL:'

write_wget_stub 1
empty_download_list="$TEST_ROOT/empty-download.list"
cat >"$empty_download_list" <<'EOF'
https://github.com/example/plugin/releases/download/1.0.0/plugin-1.0.0.jar
EOF
assert_fails_with "$empty_download_list" "$TEST_ROOT/empty-downloads" 'Downloaded plugin is empty:'
