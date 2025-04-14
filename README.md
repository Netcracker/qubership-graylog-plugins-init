# qubership-graylog-plugins-init

This init container is intended for Graylog customization with predefined list of plugins.

All the plugins listed in plugins list file will be added to Graylog while appropriate Graylog pod start in Kubernetes.

These plugins are downloaded while this image build instead of init container runtime.

## Plugins list

* [Telegram Notification](https://github.com/irgendwr/TelegramAlert/releases/download/v2.3.7/graylog-plugin-telegram-notification-2.3.7.jar)
* [Metrics Reporter Plugin](https://github.com/graylog-labs/graylog-plugin-metrics-reporter/releases/download/3.0.0/metrics-reporter-prometheus-3.0.0.jar)

## How to it work

During build graylog-plugin-init container all plugins download from
[https://github.com](https://github.com) (usually almost all Graylog plugins published on GitHub)
and add into docker image.

When operator create or update Graylog deployment it create deployment with two containers:

* graylog-plugins-init - `initContainer` which run with volume `graylog-plugins` (mount to `/opt/graylog/plugin`)
  in which it copy all plugins
* graylog - `container` with Graylog which also has volume `graylog-plugins` (mount to `/usr/share/graylog/plugin`)

When pod `graylog-0` start with init container, it always run first and execute initialize actions.
So when `initContainer` start it copy all plugins from image to mounted volume `graylog-plugins`.

Next it complete it work and Graylog container start also with volume `graylog-plugins`.

Structure of init image:

```bash
/
└── entrypoint.sh
└── /opt
    └── /graylog
        └── /plugins
            ├── graylog-plugin-telegram-notification-2.3.7.jar
            └── metrics-reporter-prometheus-3.0.0.jar
```

## How to add plugin

There is file `plugins.list` which contains plugin link.
Currently plugins can be download only from:

* [https://community.graylog.org/c/marketplace/31](https://community.graylog.org/c/marketplace/31)

Format:

```bash
<url>
```

For example:

```bash
https://github.com/graylog-labs/graylog-plugin-metrics-reporter/releases/download/3.0.0/metrics-reporter-prometheus-3.0.0.jar
```
