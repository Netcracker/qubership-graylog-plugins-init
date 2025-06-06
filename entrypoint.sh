#!/bin/sh

set -e

LOCAL_PLUGINS_DIR=/opt/graylog/plugins
# See https://github.com/Graylog2/graylog-docker/blob/main/docker-entrypoint.sh#L73
GRAYLOG_PLUGINS_DIR=/usr/share/graylog/plugin

echo "Start graylog-plugins-init container..."

echo "Available plugins:"
ls -lah ${LOCAL_PLUGINS_DIR}

echo "Copy plugins from ${LOCAL_PLUGINS_DIR} to ${GRAYLOG_PLUGINS_DIR} (which should be mounted as a volume)..."
cp -r "${LOCAL_PLUGINS_DIR}" "${GRAYLOG_PLUGINS_DIR}"

echo "Plugins are successfully copied"
