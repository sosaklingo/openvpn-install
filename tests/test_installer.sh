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
must_have "https://api.ipify.org"
must_have "VPN-gebruiker"
must_have "VPN client"
must_have '^[yYjJ]$'
must_not_have "comp-lzo"
must_not_have "--no-check-certificate"
must_not_have "http://ip1.dynupdate.no-ip.com/"

echo "PASS: syntax, NL/EN interface, safe preview, flags and security policy"
