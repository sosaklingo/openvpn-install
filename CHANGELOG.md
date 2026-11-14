# Changelog

## 2026-11 — modern-2026 review candidate

- Rebased installer source on Nyr/openvpn-install upstream commit `7ff931a00c37a6806bd1fa8cb61bf3369d963e94`.
- Updated supported Linux distributions, systemd service layout, OpenVPN configuration, and client lifecycle management.
- Updated Easy-RSA to 3.2.7 with HTTPS and SHA-256 archive verification.
- Enforced TLS 1.2 minimum and AES-GCM data cipher negotiation.
- Preserved MIT license and upstream attribution.
- Added read-only `--check`, `--help`, `--version`.
- Added safety refusal for the 2015 legacy server layout and restrictive file `umask`.
- Removed insecure README examples and documented migration limits.
- Added non-destructive automated smoke and static policy tests.

## 2015

- Original sosaklingo fork and local customization retained in Git history and on the `legacy-2015` branch for reference.
