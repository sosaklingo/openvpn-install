# English manual

[Nederlands](HANDLEIDING-NL.md) · [Home](../README.md) · [Security](../SECURITY.md) · [Migration and recovery](../MIGRATION.md)

Updated: 15 November 2026. For the modern installer.

## 1. Preparation

You use **one installation file: openvpn-install.sh**. Documentation and tests are not additional installation components. The script installs and manages an OpenVPN server; install the VPN app on your phone or computer separately.

Version checks accept Ubuntu 22.04+, Debian 11+, AlmaLinux/Rocky/CentOS 9+ and Fedora. Debian Testing/Unstable is rejected. This does not mean every accepted version has been tested.

Requirements: Bash, systemd, TUN, internet access, sudo/root and curl or wget. Commands below use curl. Start on a separate test server. For an existing server, have a verified backup and console access independent of the VPN.

**Test status:** automated syntax, menu and failure-handling tests are available. A complete installation, real VPN connection, reboot and DNS/IPv6 leak test have not yet been confirmed.

For a server behind a router, forward the selected UDP or TCP port to the server's local address. Check the provider firewall too. The script does not configure your router or provider firewall. This concerns the server location; not every client needs port forwarding.

## 2. Download and checks

On the Linux server:

```bash
mkdir -p ~/openvpn-installer
cd ~/openvpn-installer
curl -fL --proto '=https' --tlsv1.2 -o openvpn-install.sh.download \
  https://raw.githubusercontent.com/sosaklingo/openvpn-install/d946773aa2066d71285134f86417ca646237e8f4/openvpn-install.sh
```

Continue only if the download completed without an error:

```bash
bash -n openvpn-install.sh.download &&
mv openvpn-install.sh.download openvpn-install.sh
```

Inspect the code before running it as root. Then try:

```bash
bash openvpn-install.sh --lang en --preview
bash openvpn-install.sh --lang en --check
bash openvpn-install.sh --lang en --self-test
```

These commands install nothing. --check is a basic check, not a complete security or reachability test. A missing TUN device may require a change at your server provider.

## 3. New installation

```bash
sudo bash openvpn-install.sh --lang en
```

Without a language option, choose Nederlands or English first. Where needed, the script asks for local IP addresses and a public address for NAT. Then choose:

| Step | Choice |
| --- | --- |
| Protocol | UDP (default) or TCP |
| Port | 1194 (default), or 1 to 65535 |
| Encryption | One of the four options below |
| DNS | System DNS, a listed provider or custom IPv4 addresses |
| Client name | For example marco-phone; letters, digits, - and _ |
| Confirmation | Type exactly YES; other input cancels |

Do not use server as a client name: it is reserved for the server certificate. Check that the VPN subnet 10.8.0.0/24 does not overlap with your network before installation.

### Encryption

| Option | Setting |
| --- | --- |
| 1 or Enter | AES-256-GCM:AES-128-GCM, automatic negotiation |
| 2 | AES-256-GCM only |
| 3 | AES-128-GCM only |
| 4 | CHACHA20-POLY1305 only |

Option 1 is the default. Both server and clients must support the selected method. The script checks server support, not every device. This selection does not change TLS settings. The menu appears on new installations; there is no menu for changing existing encryption live.

### DNS

| Option | Selection |
| --- | --- |
| 1 or Enter | System DNS |
| 2 | Google: 8.8.8.8 and 8.8.4.4 |
| 3 | Cloudflare: 1.1.1.1 and 1.0.0.1 |
| 4 | OpenDNS |
| 5 | Quad9 |
| 6 | Gcore |
| 7 | AdGuard |
| 8 | Custom IPv4 addresses separated by spaces or commas |

These are choices in the code, not a guarantee that every resolver is reachable. Selecting DNS does not prove the absence of DNS leaks.

## 4. Connecting

After success, clientname.ovpn is saved **beside the Bash script**. Its exact path is printed. The profile contains a private key; treat it like a password.

1. Transfer the profile securely to your device, for example using SFTP.
2. Import it into a compatible OpenVPN client.
3. Connect.
4. Check internet access, your visible public IP address and DNS/IPv6 behavior.

The output file is root-readable by default. Do not make it world-readable to simplify transfer. Use a separate client name per device. Never publish profiles, keys or backups on GitHub.

## 5. Management menu

Run the same script again:

```bash
sudo bash openvpn-install.sh --lang en
```

| Option | Behavior |
| --- | --- |
| 1 | Add a client and create a new .ovpn profile |
| 2 | Select a client and revoke its certificate |
| 3 | Remove OpenVPN after confirmation |
| 4 | Exit |
| 5 | Diagnostics without changing settings |
| 6 | Rebuild and publish the revoked certificates list |

Options 1, 2, 3 and 6 first attempt a configuration backup. If it fails, the action stops. Adding clients is blocked for an incomplete installation or pending revocation.

Revocation does not delete all previously copied profiles. There is no separate function to immediately disconnect an existing client session. Check revocation using a new connection attempt.

## 6. Recovery option 6

A CRL is a certificate revocation list. If revocation or publication of that list fails:

1. Read the original error and fix its cause, such as disk space or file permissions.
2. Run the script again and select **6**.
3. Check for the message confirming publication.
4. Verify that a new connection with the revoked profile is rejected.

The existing CRL remains until its replacement is ready. A new revocation may therefore not yet be enforced during a failed update.

If option 6 says the client was not revoked, select **2** to retry revoking that client first. Option 6 does not revoke an additional client, resume installation or repair the firewall. This recovery action also does not perform all local client-file cleanup.

## 7. Diagnostics and troubleshooting

```bash
sudo bash openvpn-install.sh --lang en --diagnose
sudo systemctl status openvpn-server@server.service --no-pager
sudo journalctl -u openvpn-server@server.service -n 80 --no-pager
```

| Problem | Next step |
| --- | --- |
| Incomplete installation | Preserve the error and backup; inspect missing files. No automatic resume. |
| Adding clients blocked | Repair installation or pending revocation. |
| Revocation update pending | Fix the cause; use 6, or first 2 if revocation itself failed. |
| No readable configuration | Use sudo; check whether installation completed. |
| Service not running | Read service logs; do not blindly reinstall. |
| Connection fails | Check address, protocol/port, router, provider firewall and client log. |
| Connected without internet | Check forwarding, firewall and DNS. |
| Removal fails | Some components may already be removed. Keep the backup and review the error. |

State files track unfinished work:

- /etc/openvpn/.sosaklingo-install-incomplete
- /etc/openvpn/server/.crl-update-pending

Do not simply delete these to bypass protection. Without server.conf, reinstallation is blocked if an installation marker or existing Easy-RSA directory is present. Diagnostics can stop early if required files are missing.

A DNS warning with the VPN disconnected does not establish that this installer caused it. Compare behavior with and without an active VPN. --diagnose does not run a leak test itself.

## 8. Backups, updates and removal

Backups are in /var/backups/openvpn-sosaklingo/. They contain /etc/openvpn and keys. They are protected by file permissions, **not encrypted**. Profiles outside /etc/openvpn are not automatically included. Packages, firewall rules and external settings are not fully backed up.

There is no automatic restore or full rollback. Read [Migration and recovery](../MIGRATION.md) for manual recovery.

To update the installer, download again using section 2. This changes **no** existing server configuration, profiles, certificates or packages. System and OpenVPN package updates use your distribution's package manager.

Option 3 removes the OpenVPN package and managed server directory and attempts to clean up associated rules and services. Other applications using the same package may be affected. Backups and profiles stored elsewhere remain. Router and provider rules are not automatically removed. Previous system settings are not guaranteed to be fully restored.

## 9. Command options and tests

Use one action option per command. If several are supplied, this version uses the last one.

| Option | Purpose |
| --- | --- |
| --help, -h | Help |
| --version | Version label and upstream revision; not a unique label per commit |
| --lang nl/en, --lang=nl/en, -l nl/en | Language; replace nl/en with nl or en |
| --nl, --en | Language shortcuts |
| --preview | Preview installation steps |
| --check | Read-only basic environment check |
| --port-demo | Try the port menu |
| --cipher-demo | Try the encryption menu |
| --self-test | Test input validation |
| --diagnose | Inspect server; use sudo for protected files |

For developers with the complete repository:

```bash
bash -n openvpn-install.sh
bash tests/test_installer.sh
```

These tests do not install a real VPN. See [Security](../SECURITY.md) and [Changes](../CHANGELOG.md).
