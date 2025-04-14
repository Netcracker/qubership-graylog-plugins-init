#!/bin/sh

LOCAL_PLUGINS_DIR=/opt/plugins
GRAYLOG_PLUGINS_DIR=/usr/share/graylog/plugins

echo "Start graylog-plugins-init container..."

echo "Available plugins:"
ls -lah ${LOCAL_PLUGINS_DIR}

echo "Copy plugins from ${LOCAL_PLUGINS_DIR} to ${GRAYLOG_PLUGINS_DIR} (which should be mounted as a volume)..."
cp -r "${LOCAL_PLUGINS_DIR}" "${GRAYLOG_PLUGINS_DIR}"

echo "Plugins are successfully copied"
