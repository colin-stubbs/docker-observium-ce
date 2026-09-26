# docker-observium-ce

Yet another containerised version of Observium Community Edition, though this one includes:
1. rsyslog to support device log collection via syslog
2. php-ldap for LDAP authentication support
3. A /status.php endpoint to ensure testing of both Apache availability and PHP functionality when conducting health monitoring
4. Timezone management for php
5. Database auto-creation including creation of a default set of alerting rules
6. logrotate based rotation of both Apache and Observium logs
7. Zero requirement to inject a config.php file, database configuration and base URL variables are all taken from environment variables and so can be controlled by the container definition.

You can still inject the config.php file, which may be necessary for more complex configurations, e.g. LDAP based authentication.

This image does not include a SQL server of any kind, you're expected to have one elsewhere or you should add another service definition to the compose file as appropriate.

HTTPS is not enabled by default, only HTTP.

Container images are published via [Docker Hub](https://hub.docker.com/r/colinstubbs/observium-ce).

## Base image and PHP

The Dockerfile pins **Ubuntu 24.04 (noble)** and **PHP 8.3**. Do not use `ubuntu:latest`.

`ubuntu:latest` now tracks 26.04 Resolute. That archive's PHP is 8.5; there are no `php8.3-*` packages. A build against `latest` fails with `Unable to locate package php8.3-cli`.

PHP 8.3 is still the 24.04 LTS default. It is not obsolete. Observium requires PHP 7.4+ and recommends 8.2+ ([software requirements](https://docs.observium.org/software_requirements/)). Stay on 24.04 / 8.3 until Observium CE is known to run on PHP 8.5.

To retarget later, change both lines together in `build/Dockerfile`:

```
FROM ubuntu:24.04
ARG PHP_VERSION=8.3
```

`apache-init.sh` writes `date.timezone` under `/etc/php/${PHP_VERSION}/`.

## Build

Release images are **linux/amd64** and **linux/arm64** in one manifest. `docker compose build` is native-only and is for local run. Use the Makefile for the published image.

```bash
make lint          # hadolint + shellcheck
make build         # both platforms into the buildx builder
make load          # native platform into the local docker engine
make push          # both platforms to Docker Hub (docker login first)
make scan          # trivy HIGH/CRITICAL on a loaded image
```

`make push` is what podman `AutoUpdate=registry` consumes. Rebuild after changing `FROM` or `PHP_VERSION`. The Dockerfile is one `COPY` plus one `RUN`; a change to any overlay file rebuilds the install layer.

## Checks

| Target | Why |
|--------|-----|
| `make lint` | Dockerfile and init-script mistakes. Runs in GitHub Actions on push/PR |
| `make scan` | Host `trivy` on PATH (`trivy.yaml`). Skips `/opt/observium/mibs` (vendor MIB example PEMs). HIGH/CRITICAL on a loaded image |
| Dependabot | Weekly `ubuntu:24.04` and Actions bumps |

Not added: pinning every `apt` package (fights Ubuntu security updates), Docker Bench CIS, or registry auto-push from CI (needs Hub credentials).

## Still worth doing later

- Pin the Observium tarball (today: `observium-community-latest.tar.gz`) so two builds get the same CE revision
- Drop unused `EXPOSE` for 443 / 6514 if those listeners stay off
