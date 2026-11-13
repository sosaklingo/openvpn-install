# Security policy and scope

The `modern-2026` branch is a maintenance candidate based on upstream [Nyr/openvpn-install](https://github.com/Nyr/openvpn-install) revision `7ff931a`.

## Confirmed safeguards

- Uses the current pinned Easy-RSA `3.2.7` archive.
- Verified SHA-256 for the release archive:
  `308743bc9fe871b902d47dbe98d749daff3a05b27531684f02625ce7208d4598`.
- Fails on checksum mismatch, so unexpected archive contents are **not extracted**.
- No use of TLS certificate checking bypasses or deprecated `comp-lzo`.
- TLS minimum 1.2; `tls-crypt`; AES-GCM data ciphers.
- Does not silently attempt to migrate old server configuration.
- Tight default file permissions (`umask 077`) for output files.

## What has not been audited

- Full threat modeling, firewall persistence, distribution-specific networking, active client compatibility, all upstream paths, package supply chain, runtime tests as root, and rollback.
- The pinned archive hash protects against *changes relative to the published hash*, not a malicious upstream release or a compromised pinned commit.

## Administrator precautions

- Do **not** store client `.ovpn` profiles or private keys in GitHub.
- Never run this script on a live server without reviewing the code, a backup, and a recovery console.
- Update the operating system and OpenVPN packages using the distribution security repositories.
- Limit SSH/management exposure, keep client credentials private, and revoke lost client profiles.
- Prefer changes in a disposable test VM before production.
- Do not assume a green GitHub Actions check means a safe live deployment.

Report security issues privately through an appropriate GitHub channel, rather than opening an issue containing credentials.
