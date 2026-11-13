#!/usr/bin/env bash
# Safe tests: no OpenVPN install, no root, no network or firewall changes.
set -euo pipefail
cd "$(dirname "$0")/.."
script="openvpn-install.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
must_have() { grep -Fq -- "$1" "$script" || fail "missing: $1"; }
must_not_have() { if grep -Fq -- "$1" "$script"; then fail "unsafe option: $1"; fi; }
bash -n "$script" || fail "Bash syntax"
[[ "$(bash "$script" --version)" == *"2026-11-sosaklingo"* ]] || fail "--version"
[[ "$(bash "$script" --help)" == *"--check"* ]] || fail "--help"
set +e
output=$(bash "$script" --unknown 2>&1)
status=$?
set -e
[[ "$status" -eq 2 && "$output" == *"Onbekende optie"* ]] || fail "invalid args must be rejected"
set +e
output=$(bash "$script" --check 2>&1)
status=$?
set -e
[[ "$status" == 0 || "$status" == 2 ]] || fail "--check exit code must be 0 or 2"
[[ "$output" == *"zonder instellingen te wijzigen"* ]] || fail "--check must report read-only"
must_have "tls-crypt tc.key"
must_have "tls-version-min 1.2"
must_have "data-ciphers AES-256-GCM:AES-128-GCM"
must_have "EasyRSA-3.2.7.tgz"
must_have "308743bc9fe871b902d47dbe98d749daff3a05b27531684f02625ce7208d4598"
must_have "sha256sum --check --status"
must_have "Legacy /etc/openvpn/server.conf detected"
must_have "umask 077"
must_have "https://api.ipify.org"
must_not_have "comp-lzo"
must_not_have "--no-check-certificate"
must_not_have "http://ip1.dynupdate.no-ip.com/"
echo "PASS: OpenVPN installer syntax, interface, and static security policy"
