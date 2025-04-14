# hadolint global ignore=DL3018
# Use the first layer to download plugins and next copy them to the final image
FROM alpine:3.21 AS builder

COPY ./download_plugins.sh ./plugins.list /

RUN apk add \
        bash \
        wget \
        unzip \
    && chmod +x /download_plugins.sh \
    && /download_plugins.sh

# Tiny image with only the plugins and entrypoint script
FROM alpine:3.21

# User "nobody"
ENV USER_UID=65534

COPY --from=builder --chmod=${USER_UID} /tmp/plugins/ /opt/graylog/plugins
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER ${USER_UID}

ENTRYPOINT [ "/entrypoint.sh" ]
