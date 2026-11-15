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

# Read-only cipher-selection menu tests.
check_cipher() {
    local language="$1" input="$2" expected="$3" output
    output=$(printf '%s\n' "$input" | bash "$script" --lang "$language" --cipher-demo) ||
        fail "cipher-demo failed for $language"
    [[ "$output" == *"$expected"* ]] || fail "Expected cipher $expected, got $output"
    [[ "$output" == *"geen instellingen gewijzigd"* || "$output" == *"no settings changed"* ]] ||
        fail "cipher-demo must be read-only"
}
check_cipher nl "" 'Gekozen dataversleuteling: AES-256-GCM:AES-128-GCM'
check_cipher en "1" 'Selected data ciphers: AES-256-GCM:AES-128-GCM'
check_cipher nl "2" 'Gekozen dataversleuteling: AES-256-GCM'
check_cipher en "3" 'Selected data ciphers: AES-128-GCM'
check_cipher nl "4" 'Gekozen dataversleuteling: CHACHA20-POLY1305'
check_cipher en "4" 'Selected data ciphers: CHACHA20-POLY1305'

set +e
output=$(bash "$script" --lang en --cipher-demo </dev/null 2>&1)
status=$?
set -e
[[ "$status" -ne 0 ]] || fail "cipher-demo must reject EOF before selection"

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

# Self-test and diagnosis require no installation or root privileges.
for language in nl en; do
    output=$(bash "$script" --lang "$language" --self-test) || fail "$language self-test"
    [[ "$output" == *"geslaagd"* || "$output" == *"passed"* ]] || fail "self-test output"
done
set +e
output=$(bash "$script" --lang nl --diagnose 2>&1)
diagnose_status=$?
set -e
[[ "$output" == *"VPN-diagnose (alleen lezen)"* ]] || fail "Dutch diagnostic menu"
[[ "$diagnose_status" == 0 || "$diagnose_status" == 2 ]] || fail "diagnose unexpected status"

must_have 'valid_ipv4()'
must_have 'valid_hostname()'
must_have 'valid_menu_index()'
must_have 'if ! valid_ipv4 "$ip"; then'
must_have 'if ! valid_ipv4 "$dns_ip"; then'
must_have 'if [[ -n "$public_ip" ]] && valid_endpoint "$public_ip"; then'
must_have 'if ! apt-get update || ! apt-get install'
must_have 'chmod 0600 /etc/openvpn/server/server.key'
must_have '5) VPN-diagnose bekijken'
must_have "Package installation failed"
must_not_have 'cp pki/ca.crt pki/private/ca.key'

must_have "tls-crypt tc.key"
must_have "tls-version-min 1.2"
must_have 'data-ciphers $data_ciphers'
must_have 'data_ciphers="AES-256-GCM:AES-128-GCM"'
must_have 'data_ciphers="AES-256-GCM"'
must_have 'data_ciphers="AES-128-GCM"'
must_have 'data_ciphers="CHACHA20-POLY1305"'
must_have 'available_ciphers=$(openvpn --show-ciphers 2>/dev/null)'
must_have 'choose_vpn_cipher || exit 1'
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

echo "PASS: syntax, NL/EN interface, port/cipher menus, input validation, diagnostics, safe preview and security policy"


# Execute the actual publishing/error helpers in an isolated temporary directory.
# No packages, services, certificates or firewall rules on the host are modified.
(
    sandbox_dir=$(mktemp -d)
    trap 'rm -rf -- "$sandbox_dir"' EXIT
    sed -n '/^operation_failed()/,/^# Validate addresses/{ /^# Validate addresses/!p; }' "$script" > "$sandbox_dir/helpers.sh"
    source "$sandbox_dir/helpers.sh"
    say() { printf '%s\n' "$1"; }
    printf 'client\n' > "$sandbox_dir/template"
    printf '<key>\nexample\n</key>\n' > "$sandbox_dir/inline"
    printf 'existing profile\n' > "$sandbox_dir/profile"
    cp "$sandbox_dir/profile" "$sandbox_dir/original"
    if export_client_profile "$sandbox_dir/profile" "$sandbox_dir/template" "$sandbox_dir/missing" 2>/dev/null; then
        fail "missing inline key must fail export"
    fi
    cmp "$sandbox_dir/profile" "$sandbox_dir/original" || fail "failed export changed existing profile"
    export_client_profile "$sandbox_dir/profile" "$sandbox_dir/template" "$sandbox_dir/inline" || fail "profile export"
    [[ $(stat -c %a "$sandbox_dir/profile") == 600 ]] || fail "profile permissions"

    printf 'old CRL\n' > "$sandbox_dir/crl"
    printf 'new CRL\n' > "$sandbox_dir/new-crl"
    cp "$sandbox_dir/crl" "$sandbox_dir/old-crl"
    # Inject failure at each stage and prove the old file remains available.
    for command_name in cp chown chmod mv; do
        (
            eval "$command_name() { return 1; }"
            if publish_crl "$sandbox_dir/new-crl" "$sandbox_dir/crl" "$(id -u):$(id -g)"; then
                fail "CRL publishing accepted $command_name failure"
            fi
        ) || fail "CRL failure injection"
        cmp "$sandbox_dir/crl" "$sandbox_dir/old-crl" || fail "failed CRL update replaced old file"
    done
    publish_crl "$sandbox_dir/new-crl" "$sandbox_dir/crl" "$(id -u):$(id -g)" || fail "CRL publishing"
    cmp "$sandbox_dir/crl" "$sandbox_dir/new-crl" || fail "new CRL not published"
    [[ $(stat -c %a "$sandbox_dir/crl") == 600 ]] || fail "CRL permissions"
    [[ -z $(find "$sandbox_dir" -name '*.tmp.*' -print) ]] || fail "temporary files left behind"

    set +e
    (run_checked false; touch "$sandbox_dir/continued") > "$sandbox_dir/error" 2>&1
    failure_status=$?
    set -e
    [[ $failure_status == 1 && ! -e "$sandbox_dir/continued" ]] || fail "failed mutation did not stop execution"
    grep -q 'Partial changes may remain' "$sandbox_dir/error" || fail "partial failure explanation"

    # Check actual firewalld call sites are wired to the tested failure handler.
    if grep -Eq '^[[:space:]]+firewall-cmd ' "$script"; then
        fail "unchecked firewalld mutation"
    fi
    for bad_index in 0 -1 100000000000000000000; do
        # Exercise the actual validation helper, without running the installer.
        source <(sed -n '/^valid_menu_index()/,/^}/p' "$script")
        if valid_menu_index "$bad_index" 4; then fail "invalid revocation selection"; fi
    done
)
echo "PASS: failure injection, atomic profile/CRL publishing and revocation index bounds"

# Recovery tests use a synthetic PKI and a fake Easy-RSA executable.
(
    sandbox_dir=$(mktemp -d)
    trap 'rm -rf -- "$sandbox_dir"' EXIT
    source <(sed -n '/^operation_failed()/,/^# Validate addresses/{ /^# Validate addresses/!p; }' "$script")
    say() { printf '%s\n' "$1"; }
    L() { printf '%s' "$1"; }
    root="$sandbox_dir/server"
    mkdir -p "$root/easy-rsa/pki/private"
    for relative in server.conf ca.crt server.crt server.key dh.pem tc.key crl.pem         client-common.txt easy-rsa/easyrsa easy-rsa/pki/ca.crt         easy-rsa/pki/private/ca.key easy-rsa/pki/index.txt; do
        printf 'fixture\n' > "$root/$relative"
    done
    installation_files_complete "$root" || fail "complete fixture misclassified"
    rm "$root/server.key"
    if installation_files_complete "$root" 2>/dev/null; then fail "missing key accepted"; fi
    : > "$root/server.key"
    if installation_files_complete "$root" 2>/dev/null; then fail "empty key accepted"; fi

    printf 'old CRL\n' > "$root/crl.pem"
    printf 'alice\n' > "$root/.crl-update-pending"
    printf 'V\texpiry\t\t01\tunknown\t/CN=alice\n' > "$root/easy-rsa/pki/index.txt"
    cat > "$root/easy-rsa/easyrsa" <<'FAKE'
#!/usr/bin/env bash
[[ ! -e fail-generation ]] || exit 1
printf 'new CRL\n' > pki/crl.pem
FAKE
    chmod +x "$root/easy-rsa/easyrsa"
    owner="$(id -u):$(id -g)"
    if refresh_revocations "$root" "$owner" >/dev/null 2>&1; then fail "unrevoked client reported repaired"; fi
    [[ -e "$root/.crl-update-pending" ]] || fail "lost pending revocation"
    printf 'R\texpiry\tdate\t01\tunknown\t/CN=alice\n' > "$root/easy-rsa/pki/index.txt"
    touch "$root/easy-rsa/fail-generation"
    if refresh_revocations "$root" "$owner"; then fail "failed CRL generation accepted"; fi
    [[ $(cat "$root/crl.pem") == 'old CRL' && -e "$root/.crl-update-pending" ]] || fail "generation failure lost recovery state"
    rm "$root/easy-rsa/fail-generation"
    (
        mv() { return 1; }
        if refresh_revocations "$root" "$owner"; then fail "failed CRL publication accepted"; fi
    ) || fail "publication failure injection"
    [[ $(cat "$root/crl.pem") == 'old CRL' && -e "$root/.crl-update-pending" ]] || fail "publication failure lost recovery state"
    refresh_revocations "$root" "$owner" || fail "revocation retry failed"
    [[ $(cat "$root/crl.pem") == 'new CRL' && ! -e "$root/.crl-update-pending" ]] || fail "recovery not completed"
    refresh_revocations "$root" "$owner" || fail "repeat recovery not idempotent"

    # Exercise the actual protection guard against rerunning an incomplete install.
    sed -n '/^# Do not treat an interrupted install/,/^if \[\[ ! -e \/etc\/openvpn\/server\/server.conf \]\]; then/p' "$script" |
        sed '$d' | sed "s|/etc/openvpn|$sandbox_dir/openvpn|g" > "$sandbox_dir/guard.sh"
    mkdir -p "$sandbox_dir/openvpn/server/easy-rsa"
    printf 'existing private key\n' > "$sandbox_dir/openvpn/server/easy-rsa/key"
    export -f say
    set +e
    bash "$sandbox_dir/guard.sh" > "$sandbox_dir/guard-output" 2>&1
    guard_status=$?
    set -e
    [[ $guard_status == 3 ]] || fail "incomplete installation was not blocked"
    [[ $(cat "$sandbox_dir/openvpn/server/easy-rsa/key") == 'existing private key' ]] || fail "guard modified PKI"
)
echo "PASS: incomplete installation guard and revocation recovery after generation/publication failures"

# Run the actual removal branch with service/package/file operations mocked.
(
    sandbox_dir=$(mktemp -d)
    trap 'rm -rf -- "$sandbox_dir"' EXIT
    sed -n '/^operation_failed()/,/^# Validate addresses/{ /^# Validate addresses/!p; }' "$script" > "$sandbox_dir/helpers.sh"
    awk '/read -r -p.*Remove OpenVPN/ {active=1} active && /^\t\t;;/ {exit} active {print}' "$script" > "$sandbox_dir/remove.sh"
    cat > "$sandbox_dir/driver.sh" <<'DRIVER'
source "$1/helpers.sh"
L() { printf '%s' "$1"; }
say() { printf '%s\n' "$1"; }
systemctl() {
    [[ "$1" != is-active ]] || return 1
    [[ "$failure_command" != systemctl ]]
}
apt-get() { [[ "$failure_command" != apt-get ]]; }
rm() { [[ "$failure_command" != rm ]]; }
sestatus() { return 1; }
grep() {
    case "$1" in
        '^port ') printf 'port 1194\n' ;;
        '^proto ') printf 'proto udp\n' ;;
        *) return 1 ;;
    esac
}
os=debian
source "$1/remove.sh"
DRIVER
    for failure_command in systemctl apt-get rm none; do
        export failure_command
        set +e
        output=$(printf 'y\n' | bash "$sandbox_dir/driver.sh" "$sandbox_dir" 2>&1)
        removal_status=$?
        set -e
        if [[ "$failure_command" == none ]]; then
            [[ $removal_status == 0 && "$output" == *'OpenVPN removed.'* ]] || fail "mock removal success"
        else
            [[ $removal_status != 0 && "$output" != *'OpenVPN removed.'* ]] || fail "removal ignored $failure_command error"
        fi
    done
)
echo "PASS: removal aborts on service, package and file-operation failures"
