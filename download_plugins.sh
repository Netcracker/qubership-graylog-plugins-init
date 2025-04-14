#!/bin/bash

set -e

######################################################################################################################
#                                                      Constants                                                     #
######################################################################################################################

TEMP_PATH="/tmp"
DOWNLOADS_PATH="${TEMP_PATH}/plugins"

######################################################################################################################
#                                                  Download plugins                                                  #
######################################################################################################################

mkdir -p ${DOWNLOADS_PATH}

echo "Start to read file with plugins ..."
while IFS='' read -r line || [[ -n "${line}" ]]; do
    if [[ "${line}" != \#* ]]; then
        filename=$(basename "${line}")

        echo "Try to download plugin: ${filename} ..."
        wget --no-check-certificate -P "${DOWNLOADS_PATH}/${filename}" \
            -r -nd --quiet --no-parent \
            "${line}"
    fi
done <"plugins.list"
echo "Plugins successfully downloaded"

echo "List of plugins directories:"
ls -lah "${DOWNLOADS_PATH}"

echo "Plugins download process successfully complete"

echo "Build script successfully complete"
