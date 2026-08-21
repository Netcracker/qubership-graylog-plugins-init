#!/bin/bash

set -euo pipefail

######################################################################################################################
#                                                      Constants                                                     #
######################################################################################################################

readonly DOWNLOADS_PATH="${PLUGIN_DOWNLOADS_PATH:-/tmp/plugins}"
readonly PLUGINS_FILE="${PLUGINS_FILE:-plugins.list}"
readonly GITHUB_RELEASE_URL_PATTERN='^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/releases/download/[^/?#[:space:]]+/[A-Za-z0-9_.+-]+\.jar$'

######################################################################################################################
#                                                  Download plugins                                                  #
######################################################################################################################

mkdir -p "${DOWNLOADS_PATH}"

echo "Start to read file with plugins ..."
while IFS='' read -r line || [[ -n "${line}" ]]; do
    if [[ -n "${line}" && "${line}" != \#* ]]; then
        if [[ ! "${line}" =~ ${GITHUB_RELEASE_URL_PATTERN} ]]; then
            echo "Unsupported plugin URL: ${line}" >&2
            echo "Use an HTTPS JAR URL from a GitHub release." >&2
            exit 1
        fi

        filename=$(basename -- "${line}")

        echo "Try to download plugin: ${filename} ..."
        wget --quiet \
            --output-document "${DOWNLOADS_PATH}/${filename}" \
            "${line}"

        if [[ ! -s "${DOWNLOADS_PATH}/${filename}" ]]; then
            echo "Downloaded plugin is empty: ${filename}" >&2
            exit 1
        fi
    fi
done <"${PLUGINS_FILE}"
echo "Plugins successfully downloaded"

echo "List of plugins directories:"
ls -lah "${DOWNLOADS_PATH}"

echo "Plugins download process successfully complete"

echo "Build script successfully complete"
