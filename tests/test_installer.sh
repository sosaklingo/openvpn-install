#!/usr/bin/env bash
# Non-destructive tests: no root installation or network changes.
set -euo pipefail
cd "$(dirname "$0")/.."
script="openvpn-install.sh"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
must_have() { grep -Fq -- "$1" "$script" || fail "missing: $1"; }
must_not_have() { if grep -Fq -- "$1" "$script"; then fail "unsafe option: $1"; fi; }

bash -n "$script" || fail "Bash syntax"

[[ "$(bash "$script" --version)" == *"2026-11-sosaklingo"* ]] || fail "--version"
[[ "$(bash "$script" --help)" == *"Eén installatieprogramma"* ]] || fail "Dutch help"
[[ "$(bash "$script" --lang en --help)" == *"One installer"* ]] || fail "English help"

[[ "$(bash "$script" --lang nl --preview)" == *"Kies protocol"* ]] || fail "Dutch preview"
[[ "$(bash "$script" --lang en --preview)" == *"Choose protocol"* ]] || fail "English preview"
[[ "$(printf '2\n' | bash "$script" --preview)" == *"Choose protocol"* ]] || fail "Interactive English selection"
[[ "$(printf '1\n' | bash "$script" --preview)" == *"Kies protocol"* ]] || fail "Interactive Dutch selection"
[[ "$(bash "$script" --en --preview)" == *"Choose protocol"* ]] || fail "--en alias"
[[ "$(bash "$script" --nl --preview)" == *"Kies protocol"* ]] || fail "--nl alias"

# Port-choice tests are non-destructive and run without root.
check_port() {
    local language="$1" input="$2" expected="$3" output
    output=$(printf '%s' "$input" | bash "$script" --lang "$language" --port-demo) ||
        fail "port-demo failed for $language with input $(printf %q "$input")"
    [[ "$output" == *"$expected"* ]] ||
        fail "Expected port $expected, got $output"
    [[ "$output" == *"geen instellingen gewijzigd"* || "$output" == *"no settings changed"* ]] ||
        fail "port-demo must explicitly report non-destructive behavior"
}
check_port nl $'\n' 'Gekozen VPN-poort: 1194'
check_port en $'1\n' 'Selected VPN port: 1194'
check_port nl $'2\n443\n' 'Gekozen VPN-poort: 443'
check_port en $'2\n5353\n' 'Selected VPN port: 5353'
check_port nl $'2\n0\n1194\n' 'Gekozen VPN-poort: 1194'
check_port en $'2\n65536\n65535\n' 'Selected VPN port: 65535'
check_port nl $'2\nabcd\n80\n' 'Gekozen VPN-poort: 80'
check_port en $'2\n999999999999999999\n8080\n' 'Selected VPN port: 8080'
check_port nl $'3\n2\n8443\n' 'Gekozen VPN-poort: 8443'
check_port en $'2\n00080\n' 'Selected VPN port: 80'

set +e
output=$(printf '2\n' | bash "$script" --lang nl --port-demo 2>&1)
status=$?
set -e
[[ "$status" -ne 0 ]] || fail "port-demo must not accept EOF without a port"


set +e
output=$(bash "$script" --lang xx --preview 2>&1)
status=$?
set -e
[[ "$status" -eq 2 && "$output" == *"Onbekende taal"* ]] || fail "Unknown language rejected"

set +e
output=$(bash "$script" --unknown 2>&1)
status=$?
set -e
[[ "$status" -eq 2 && "$output" == *"Onbekende optie"* ]] || fail "Unknown option rejected"

for language in nl en; do
    set +e
    output=$(bash "$script" --lang "$language" --check 2>&1)
    status=$?
    set -e
    [[ "$status" == 0 || "$status" == 2 ]] || fail "--check returned unexpected exit $status"
    if [[ "$language" == nl ]]; then
        [[ "$output" == *"systeem niet gewijzigd"* ]] || fail "Dutch --check read-only message"
    else
        [[ "$output" == *"did not modify the system"* ]] || fail "English --check read-only message"
    fi
done

must_have "tls-crypt tc.key"
must_have "tls-version-min 1.2"
must_have "data-ciphers AES-256-GCM:AES-128-GCM"
must_have "EasyRSA-3.2.7.tgz"
must_have "308743bc9fe871b902d47dbe98d749daff3a05b27531684f02625ce7208d4598"
must_have "sha256sum --check --status"
must_have 'if [[ -f /etc/openvpn/server.conf && ! -f /etc/openvpn/server/server.conf ]]'
must_have "umask 077"
must_have "backup_existing_openvpn"
must_have "mktemp \"\$backup_dir/openvpn-"
must_have 'Type YES to install OpenVPN'
must_have 'Typ JA om OpenVPN te installeren'
must_have "choose_vpn_port || exit 1"
must_have '10#$custom >= 1 && 10#$custom <= 65535'
must_have "https://api.ipify.org"
must_have "VPN-gebruiker"
must_have "VPN client"
must_have '^[yYjJ]$'
must_not_have "comp-lzo"
must_not_have "--no-check-certificate"
must_not_have "http://ip1.dynupdate.no-ip.com/"

echo "PASS: syntax, NL/EN interface, safe preview, flags and security policy"
