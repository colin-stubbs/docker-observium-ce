* 2026-09-27 09:03 AEST - Skip Observium MIBs in `make scan`

- `trivy.yaml` `skip-dirs` for `/opt/observium/mibs`. Vendor SNMP MIBs contain example PEM blocks; they are not keys

* 2026-09-27 08:57 AEST - Collapse the Dockerfile to one COPY and one RUN

- Overlay files copy into `/tmp/image` then install, Observium extract, and Apache/PHP setup share a single layer. Combined ENV, LABEL, and EXPOSE
- Image label 1.9. A cron or script change now rebuilds the install layer

* 2026-09-27 08:44 AEST - Build linux/amd64 and linux/arm64 together

- Makefile + `docker-bake.hcl`: `make build` / `make push` via a docker-container buildx builder. `docker compose build` stays native-only
- `make lint` (hadolint, shellcheck) and GitHub Actions `check`. `make scan` is optional trivy. Dependabot for the Dockerfile and Actions
- Init scripts quoted for shellcheck. Dockerfile `SHELL` pipefail. Dropped empty build-time `ENV OBSERVIUM_*`. Image label 1.8

* 2026-09-27 08:38 AEST - Pin Ubuntu 24.04 so the image still builds

- `ubuntu:latest` is Resolute (26.04) and has PHP 8.5 only. `php8.3-*` packages are gone from that archive, not from Ubuntu
- `FROM ubuntu:24.04` with `ARG PHP_VERSION=8.3`. Observium documents PHP 8.2+; 8.3 is the 24.04 default
- Parameterised package and `a2enmod` names. Dropped `phpenmod mcrypt` (module not installed). Fetch Observium over HTTPS. Image HEALTHCHECK matches compose
- Do not switch this image to 26.04 / PHP 8.5 until Observium CE is known to run on 8.5
