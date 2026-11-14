# Migration from the 2015 installer — read before changes

**Do not use this 2026 installer as an in-place upgrader for a 2015 VPN server.**

The older script stores configuration in `/etc/openvpn/server.conf`, whereas the modern script uses `/etc/openvpn/server/server.conf` and the service `openvpn-server@server.service`. Old installations may also use different firewall startup methods and legacy client profiles.

## Before considering migration

1. Identify the server's Linux distribution, OpenVPN version, certificates and network layout.
2. Make a verified, **encrypted** backup of `/etc/openvpn`, keys, existing client profiles, IP forwarding settings, firewall rules, and VPN service units. Do **not** upload this backup to GitHub.
3. Record existing routes, DNS rules and firewall policies. Establish out-of-band SSH/console access so you do not lock yourself out.
4. Test a fresh installation on a **separate test VM** with the intended Linux version before planning a production cutover.
5. Plan client certificate/profile rotation, DNS changes, maintenance time and rollback procedures. Consult the upstream [OpenVPN documentation](https://openvpn.net/community-resources/) as needed.

## Automatic safeguards

The modern script exits without installing when it finds the old `/etc/openvpn/server.conf` and no modern `/etc/openvpn/server/server.conf`.

**No automatic migration, rollback, or production compatibility is promised.** The original code is preserved on the `legacy-2015` branch for reference; do not run it on modern production systems.
