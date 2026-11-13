#!/bin/bash
#
# openvpn-install (sosaklingo 2026 maintenance edition)
# Upstream: https://github.com/Nyr/openvpn-install
# Original copyright (c) 2013 Nyr. MIT license; see LICENSE.txt.
# Modernization by sosaklingo. Upstream revision: 7ff931a00c37a6806bd1fa8cb61bf3369d963e94.
#
# This program changes network routing, firewall rules, certificates, and services.
# Always back up a running VPN server before modifying it.
#
set -o pipefail
umask 077

# One installer, two languages. Only UI strings are translated; OpenVPN
# configuration syntax stays in English as required by OpenVPN.
VPN_LANG=""
VPN_ACTION=""
while (($#)); do
    case "$1" in
        --lang|-l)
            shift
            (($#)) || { printf 'Missing language / Taal ontbreekt.\n' >&2; exit 2; }
            VPN_LANG="$1" ;;
        --lang=*) VPN_LANG="${1#--lang=}" ;;
        --nl) VPN_LANG="nl" ;;
        --en) VPN_LANG="en" ;;
        --help|-h) VPN_ACTION="help" ;;
        --version) VPN_ACTION="version" ;;
        --check) VPN_ACTION="check" ;;
        --preview) VPN_ACTION="preview" ;;
        *) printf 'Unknown option / Onbekende optie: %s\n' "$1" >&2; exit 2 ;;
    esac
    shift
done
if [[ -n "$VPN_LANG" && "$VPN_LANG" != "nl" && "$VPN_LANG" != "en" ]]; then
    printf 'Unknown language / Onbekende taal: %s (nl/en)\n' "$VPN_LANG" >&2
    exit 2
fi

if [[ -z "$VPN_LANG" && ( -z "$VPN_ACTION" || "$VPN_ACTION" == "preview" ) ]]; then
    printf '\nOpenVPN Installer - sosaklingo\n'
    printf 'Kies je taal / Choose your language:\n'
    printf '  1) Nederlands\n  2) English\n'
    read -r -p 'Taal / Language [1]: ' user_lang || exit 1
    case "$user_lang" in
        1|"") VPN_LANG="nl" ;;
        2) VPN_LANG="en" ;;
        *) printf 'Ongeldige keuze / Invalid selection.\n' >&2; exit 2 ;;
    esac
fi
VPN_LANG="${VPN_LANG:-nl}"
# L english dutch -> localized string; no eval and no substitutions.
L() { if [[ "$VPN_LANG" == "nl" ]]; then printf '%s' "$2"; else printf '%s' "$1"; fi; }
say() { printf '%s\n' "$(L "$1" "$2")"; }

# Make root-readable-only backups before modifying an existing OpenVPN tree.
# This is a configuration backup, NOT a full firewall or package rollback.
backup_existing_openvpn() {
    local backup_dir="/var/backups/openvpn-sosaklingo" archive
    if [[ ! -d /etc/openvpn ]]; then return 0; fi
    if [[ -L "$backup_dir" ]]; then
        say 'Backup directory cannot be a symlink. Aborting.' 'Back-upmap mag geen symbolische link zijn. Gestopt.' >&2
        return 1
    fi
    if ! install -d -m 0700 -- "$backup_dir" || ! chmod 0700 -- "$backup_dir"; then
        say 'Cannot create a protected backup directory. Aborting.' 'Afgeschermde back-upmap maken mislukt. Gestopt.' >&2
        return 1
    fi
    archive=$(mktemp "$backup_dir/openvpn-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXXXX.tar.gz") || return 1
    if ! tar -czf "$archive" -C /etc openvpn || ! chmod 0600 -- "$archive"; then
        rm -f -- "$archive"
        say 'Backup failed. No changes will be made.' 'Back-up mislukt. Er worden geen wijzigingen aangebracht.' >&2
        return 1
    fi
    printf '%s %s\n' "$(L 'Protected configuration backup:' 'Afgeschermde configuratieback-up:')" "$archive"
}

show_help() {
    printf 'OpenVPN Installer - sosaklingo (2026)\n'
    printf '%s\n' "$(L 'One installer, English and Dutch.' 'Eén installatieprogramma, Nederlands en Engels.')"
    printf '%s\n' "$(L 'Usage:' 'Gebruik:')"
    printf '  bash openvpn-install.sh [--lang nl|en] [--help|--version|--check|--preview]\n'
    printf '  sudo bash openvpn-install.sh --lang nl\n'
    printf '  sudo bash openvpn-install.sh --lang en\n\n'
    say 'Without options you can choose a language and follow the menu.' 'Zonder opties kies je eerst je taal en volg je het menu.'
    say '--preview displays the menu without modifying your system.' '--preview toont het menu zonder iets aan je systeem te wijzigen.'
    say '--check performs a read-only basic environment check.' '--check voert een eenvoudige alleen-lezen systeemcontrole uit.'
    say 'Supports Ubuntu 22.04+, Debian 11+, AlmaLinux/Rocky/CentOS 9+ and Fedora.' 'Geschikt voor Ubuntu 22.04+, Debian 11+, AlmaLinux/Rocky/CentOS 9+ en Fedora.'
    say 'Do not use on a live VPN server without a backup and console access.' 'Niet uitvoeren op een actieve VPN-server zonder back-up en consoletoegang.'
    say 'Legacy 2015 server layouts are not migrated automatically.' 'Oude serverindelingen uit 2015 worden niet automatisch gemigreerd.'
}

readonly MAINTAINER_VERSION="2026-11-sosaklingo"
case "$VPN_ACTION" in
    help) show_help; exit 0 ;;
    version)
        printf 'openvpn-install %s\nUpstream: Nyr/openvpn-install @ 7ff931a00c37a6806bd1fa8cb61bf3369d963e94\n' "$MAINTAINER_VERSION"
        exit 0 ;;
    preview)
        printf '\n'
        say 'OpenVPN easy setup' 'OpenVPN eenvoudige installatie'
        say '1. Check your server (no changes)' '1. Controleer je server (geen wijzigingen)'
        say '2. Choose protocol (default: UDP)' '2. Kies protocol (standaard: UDP)'
        say '3. Choose port (default: 1194)' '3. Kies poort (standaard: 1194)'
        say '4. Choose DNS and client name' '4. Kies DNS en clientnaam'
        say '5. Confirm installation' '5. Bevestig de installatie'
        say 'No changes were made.' 'Er zijn geen wijzigingen aangebracht.'
        exit 0 ;;
    check)
        printf '%s\n' "$(L 'Read-only OpenVPN installer check' 'OpenVPN systeemcontrole (alleen lezen)')"
        failures=0
        for utility in bash grep sed ip tar sha256sum mktemp systemctl; do
            if command -v "$utility" >/dev/null 2>&1; then
                printf '  OK   %s\n' "$utility"
            else
                printf '  MISS %s\n' "$utility"
                failures=$((failures + 1))
            fi
        done
        if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
            printf '  OK   curl/wget\n'
        else
            printf '  MISS curl/wget\n'
            failures=$((failures + 1))
        fi
        if [[ -r /etc/os-release ]]; then
            . /etc/os-release
            printf '  %s: %s\n' "$(L 'System' 'Systeem')" "$PRETTY_NAME"
        fi
        if [[ -f /etc/openvpn/server.conf && ! -e /etc/openvpn/server/server.conf ]]; then
            say 'WARNING: legacy OpenVPN configuration found. No automatic migration.' 'WAARSCHUWING: oude OpenVPN-configuratie gevonden. Geen automatische migratie.'
        fi
        if [[ ! -e /dev/net/tun ]]; then
            say 'WARNING: /dev/net/tun is missing.' 'WAARSCHUWING: /dev/net/tun ontbreekt.'
        fi
        say 'The check did not modify the system.' 'De controle heeft het systeem niet gewijzigd.'
        [[ "$failures" -eq 0 ]] && exit 0 || exit 2
        ;;
    "") ;;
esac

#
# https://github.com/Nyr/openvpn-install
#
# Copyright (c) 2013 Nyr. Released under the MIT License.


# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -q "dash"; then
	say 'Run this installer with bash, not sh.' 'Start dit installatieprogramma met bash, niet met sh.'
	exit
fi

# Discard stdin. Needed when running from a one-liner which includes a newline
read -N 999999 -t 0.001

# Detect OS
# $os_version variables aren't always in use, but are kept here for convenience
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"
	os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
	group_name="nogroup"
elif [[ -e /etc/debian_version ]]; then
	os="debian"
	os_version=$(grep -oE '[0-9]+' /etc/debian_version | head -1)
	group_name="nogroup"
elif [[ -e /etc/almalinux-release || -e /etc/rocky-release || -e /etc/centos-release ]]; then
	os="centos"
	os_version=$(grep -shoE '[0-9]+' /etc/almalinux-release /etc/rocky-release /etc/centos-release | head -1)
	group_name="nobody"
elif [[ -e /etc/fedora-release ]]; then
	os="fedora"
	os_version=$(grep -oE '[0-9]+' /etc/fedora-release | head -1)
	group_name="nobody"
else
	say 'This Linux distribution is not supported. Supported: Ubuntu, Debian, AlmaLinux, Rocky Linux, CentOS and Fedora.' 'Deze Linux-distributie wordt niet ondersteund. Ondersteund: Ubuntu, Debian, AlmaLinux, Rocky Linux, CentOS en Fedora.'
	exit
fi

if [[ "$os" == "ubuntu" && "$os_version" -lt 2204 ]]; then
	say 'Ubuntu 22.04 or newer is required. Your version is too old.' 'Ubuntu 22.04 of nieuwer is vereist. Jouw versie is te oud.'
	exit
fi

if [[ "$os" == "debian" ]]; then
	if grep -q '/sid' /etc/debian_version; then
		say 'Debian Testing and Unstable are not supported.' 'Debian Testing en Unstable worden niet ondersteund.'
		exit
	fi
	if [[ "$os_version" -lt 11 ]]; then
		say 'Debian 11 or newer is required. Your version is too old.' 'Debian 11 of nieuwer is vereist. Jouw versie is te oud.'
		exit
	fi
fi

if [[ "$os" == "centos" && "$os_version" -lt 9 ]]; then
	os_name=$(sed 's/ release.*//' /etc/almalinux-release /etc/rocky-release /etc/centos-release 2>/dev/null | head -1)
	printf '%s\n' "$(L "$os_name 9 or newer is required. Your version is too old." "$os_name 9 of nieuwer is vereist. Jouw versie is te oud.")"
	exit
fi

# Detect environments where $PATH does not include the sbin directories
if ! grep -q sbin <<< "$PATH"; then
	say 'The PATH does not include sbin. Try su - instead of su.' 'Het PATH bevat geen sbin. Gebruik su - in plaats van su.'
	exit
fi

if [[ "$EUID" -ne 0 ]]; then
	say 'Administrator privileges are required. Use sudo.' 'Administratorrechten zijn vereist. Gebruik sudo.'
	exit
fi

if [[ ! -e /dev/net/tun ]] || ! ( exec 7<>/dev/net/tun ) 2>/dev/null; then
	say 'The /dev/net/tun device is missing or inaccessible. Enable TUN before installation.' 'Het apparaat /dev/net/tun ontbreekt of is niet toegankelijk. Schakel TUN in voordat je installeert.'
	exit
fi

# Safety: the old 2015 installer used a different config and service layout.
# Treating that as a new install could break an existing server.
if [[ -f /etc/openvpn/server.conf && ! -f /etc/openvpn/server/server.conf ]]; then
    say 'Old /etc/openvpn/server.conf found. Automatic migration is refused.' 'Oude /etc/openvpn/server.conf gevonden. Automatische migratie wordt geweigerd.'
    say 'Back up the VPN server and migrate it manually; see MIGRATION.md.' 'Maak een back-up van de VPN-server en migreer handmatig; zie MIGRATION.md.'
    exit 3
fi

# Store the absolute path of the directory where the script is located
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -e /etc/openvpn/server/server.conf ]]; then
	# HTTPS downloader must be installed before changing the server.
	# Unlike the historical installer, this works consistently on Debian and RPM systems.
	if ! command -v wget >/dev/null 2>&1 && ! command -v curl >/dev/null 2>&1; then
		say 'Please install curl or wget first, then run the installer again.' 'Installeer eerst curl of wget en start het script opnieuw.' >&2
		exit 1
	fi
	clear
	say 'Welcome to the OpenVPN installer.' 'Welkom bij de OpenVPN-installatie.'
	# If system has a single IPv4, it is selected automatically. Else, ask the user
	if [[ $(ip -4 addr | grep inet | grep -vEc '127(\.[0-9]{1,3}){3}') -eq 1 ]]; then
		ip=$(ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}' | cut -d '/' -f 1 | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}')
	else
		number_of_ip=$(ip -4 addr | grep inet | grep -vEc '127(\.[0-9]{1,3}){3}')
		echo
		say 'Which IPv4 address should OpenVPN use?' 'Welk IPv4-adres moet OpenVPN gebruiken?'
		ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}' | cut -d '/' -f 1 | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | nl -s ') '
		read -r -p "$(L 'IPv4 address [1]: ' 'IPv4-adres [1]: ')" ip_number
		until [[ -z "$ip_number" || "$ip_number" =~ ^[0-9]+$ && "$ip_number" -le "$number_of_ip" ]]; do
			printf '%s: %s\n' "$ip_number" "$(L 'invalid selection' 'ongeldige keuze')"
			read -r -p "$(L 'IPv4 address [1]: ' 'IPv4-adres [1]: ')" ip_number
		done
		[[ -z "$ip_number" ]] && ip_number="1"
		ip=$(ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}' | cut -d '/' -f 1 | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | sed -n "$ip_number"p)
	fi
	# If $ip is a private IP address, the server must be behind NAT
	if echo "$ip" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
		echo
		say 'This server is behind NAT. Enter the public IPv4 address or hostname.' 'Deze server staat achter NAT. Vul het openbare IPv4-adres of de hostnaam in.'
		# Get public IP and sanitize with grep
		get_public_ip=$(grep -m 1 -oE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' <<< "$(wget -T 10 -t 1 -4qO- "https://api.ipify.org" || curl -m 10 -4Ls "https://api.ipify.org")")
		read -r -p "$(L "Public IPv4 address / hostname [$get_public_ip]: " "Openbaar IPv4-adres / hostnaam [$get_public_ip]: ")" public_ip
		# If the checkip service is unavailable and user didn't provide input, ask again
		until [[ -n "$get_public_ip" || -n "$public_ip" ]]; do
			say 'Invalid input.' 'Ongeldige invoer.'
			read -r -p "$(L 'Public IPv4 address / hostname: ' 'Openbaar IPv4-adres / hostnaam: ')" public_ip
		done
		[[ -z "$public_ip" ]] && public_ip="$get_public_ip"
	fi
	# If system has a single IPv6, it is selected automatically
	if [[ $(ip -6 addr | grep -c 'inet6 [23]') -eq 1 ]]; then
		ip6=$(ip -6 addr | grep 'inet6 [23]' | cut -d '/' -f 1 | grep -oE '([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}')
	fi
	# If system has multiple IPv6, ask the user to select one
	if [[ $(ip -6 addr | grep -c 'inet6 [23]') -gt 1 ]]; then
		number_of_ip6=$(ip -6 addr | grep -c 'inet6 [23]')
		echo
		say 'Which IPv6 address should OpenVPN use?' 'Welk IPv6-adres moet OpenVPN gebruiken?'
		ip -6 addr | grep 'inet6 [23]' | cut -d '/' -f 1 | grep -oE '([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}' | nl -s ') '
		read -r -p "$(L 'IPv6 address [1]: ' 'IPv6-adres [1]: ')" ip6_number
		until [[ -z "$ip6_number" || "$ip6_number" =~ ^[0-9]+$ && "$ip6_number" -le "$number_of_ip6" ]]; do
			printf '%s: %s\n' "$ip6_number" "$(L 'invalid selection' 'ongeldige keuze')"
			read -r -p "$(L 'IPv6 address [1]: ' 'IPv6-adres [1]: ')" ip6_number
		done
		[[ -z "$ip6_number" ]] && ip6_number="1"
		ip6=$(ip -6 addr | grep 'inet6 [23]' | cut -d '/' -f 1 | grep -oE '([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}' | sed -n "$ip6_number"p)
	fi
	echo
	say 'Which protocol should OpenVPN use?' 'Welk protocol moet OpenVPN gebruiken?'
	say '   1) UDP (recommended)' '   1) UDP (aanbevolen)'
	echo "   2) TCP"
	read -r -p "$(L 'Protocol [1]: ' 'Protocol [1]: ')" protocol
	until [[ -z "$protocol" || "$protocol" =~ ^[12]$ ]]; do
		printf '%s: %s\n' "$protocol" "$(L 'invalid selection' 'ongeldige keuze')"
		read -r -p "$(L 'Protocol [1]: ' 'Protocol [1]: ')" protocol
	done
	case "$protocol" in
		1|"") 
		protocol=udp
		;;
		2) 
		protocol=tcp
		;;
	esac
	echo
	say 'Which port should OpenVPN use?' 'Welke poort moet OpenVPN gebruiken?'
	read -r -p "$(L 'Port [1194]: ' 'Poort [1194]: ')" port
	until [[ -z "$port" || ( "$port" =~ ^[0-9]+$ && "$port" -ge 1 && "$port" -le 65535 ) ]]; do
		printf '%s: %s\n' "$port" "$(L 'invalid port' 'ongeldige poort')"
		read -r -p "$(L 'Port [1194]: ' 'Poort [1194]: ')" port
	done
	[[ -z "$port" ]] && port="1194"
	echo
	say 'Choose a DNS server for VPN clients:' 'Kies een DNS-server voor VPN-gebruikers:'
	say '   1) Default system resolvers' '   1) DNS van het systeem (standaard)'
	echo "   2) Google"
	echo "   3) 1.1.1.1"
	echo "   4) OpenDNS"
	echo "   5) Quad9"
	echo "   6) Gcore"
	echo "   7) AdGuard"
	say '   8) Specify custom resolvers' '   8) Zelf DNS-servers invoeren'
	read -r -p "$(L 'DNS server [1]: ' 'DNS-server [1]: ')" dns
	until [[ -z "$dns" || "$dns" =~ ^[1-8]$ ]]; do
		printf '%s: %s\n' "$dns" "$(L 'invalid selection' 'ongeldige keuze')"
		read -r -p "$(L 'DNS server [1]: ' 'DNS-server [1]: ')" dns
	done
	# If the user selected custom resolvers, we deal with that here
	if [[ "$dns" = "8" ]]; then
		echo
		until [[ -n "$custom_dns" ]]; do
			say 'Enter DNS servers (one or more IPv4 addresses, separated by commas or spaces):' 'Voer DNS-servers in (IPv4-adressen, gescheiden door komma of spatie):'
			read -r -p "$(L 'DNS servers: ' 'DNS-servers: ')" dns_input
			# Convert comma delimited to space delimited
			dns_input=$(echo "$dns_input" | tr ',' ' ')
			# Validate and build custom DNS IP list
			for dns_ip in $dns_input; do
				if [[ "$dns_ip" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
					if [[ -z "$custom_dns" ]]; then
						custom_dns="$dns_ip"
					else
						custom_dns="$custom_dns $dns_ip"
					fi
				fi
			done
			if [ -z "$custom_dns" ]; then
				say 'Invalid input.' 'Ongeldige invoer.'
			fi
		done
	fi
	echo
	say 'Choose a name for the first VPN client:' 'Kies een naam voor de eerste VPN-gebruiker:'
	read -r -p "$(L 'Name [client]: ' 'Naam [client]: ')" unsanitized_client
	# Allow a limited set of characters to avoid conflicts
	client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_client")
	[[ -z "$client" ]] && client="client"
	echo
	say 'The OpenVPN installation is ready to begin.' 'OpenVPN staat klaar om te installeren.'
	# Install a firewall if firewalld or iptables are not already available
	if ! systemctl is-active --quiet firewalld.service && ! hash iptables 2>/dev/null; then
		if [[ "$os" == "centos" || "$os" == "fedora" ]]; then
			firewall="firewalld"
			# We don't want to silently enable firewalld, so we give a subtle warning
			# If the user continues, firewalld will be installed and enabled during setup
			say 'firewalld will also be installed to manage firewall rules.' 'firewalld wordt ook geïnstalleerd om firewallregels te beheren.'
		elif [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
			# iptables is way less invasive than firewalld so no warning is given
			firewall="iptables"
		fi
	fi
	printf '\n'
	printf '%s %s, %s %s\n' "$(L 'Selected protocol:' 'Gekozen protocol:')" "$protocol" "$(L 'port:' 'poort:')" "$port"
	read -r -p "$(L 'Type YES to install OpenVPN (anything else cancels): ' 'Typ JA om OpenVPN te installeren (anders annuleren): ')" confirm
	if [[ ( "$VPN_LANG" == "nl" && "$confirm" != "JA" ) ||
	      ( "$VPN_LANG" == "en" && "$confirm" != "YES" ) ]]; then
		say 'Installation cancelled. No changes made.' 'Installatie geannuleerd. Geen wijzigingen aangebracht.'
		exit 0
	fi
	# Back up any existing OpenVPN configuration before package and firewall changes.
	if [[ -d /etc/openvpn ]]; then
		backup_existing_openvpn || exit 1
	fi
	# If running inside a container, disable LimitNPROC to prevent conflicts
	if systemd-detect-virt -cq; then
		mkdir /etc/systemd/system/openvpn-server@server.service.d/ 2>/dev/null
		echo "[Service]
LimitNPROC=infinity" > /etc/systemd/system/openvpn-server@server.service.d/disable-limitnproc.conf
	fi
	if [[ "$os" = "debian" || "$os" = "ubuntu" ]]; then
		apt-get update
		apt-get install -y --no-install-recommends openvpn openssl ca-certificates $firewall
	elif [[ "$os" = "centos" ]]; then
		dnf install -y epel-release
		dnf install -y openvpn openssl ca-certificates tar $firewall
	else
		# Else, OS must be Fedora
		dnf install -y openvpn openssl ca-certificates tar $firewall
	fi
	# If firewalld was just installed, enable it
	if [[ "$firewall" == "firewalld" ]]; then
		systemctl enable --now firewalld.service
	fi
	# Get easy-rsa
	easy_rsa_url='https://github.com/OpenVPN/easy-rsa/releases/download/v3.2.7/EasyRSA-3.2.7.tgz'
	# Pinned digest is published in OpenVPN/easy-rsa v3.2.7 release metadata.
	# Fail closed on download or checksum errors; never pipe remote code into tar.
	easy_rsa_sha256='308743bc9fe871b902d47dbe98d749daff3a05b27531684f02625ce7208d4598'
	easy_rsa_archive=$(mktemp /tmp/openvpn-easyrsa.XXXXXXXX.tgz) || exit 1
	if command -v curl >/dev/null 2>&1; then
		if ! curl --fail --location --silent --show-error --retry 3 --connect-timeout 10 --max-time 120 --proto '=https' --tlsv1.2 --output "$easy_rsa_archive" "$easy_rsa_url"; then
			say 'Failed to download Easy-RSA securely.' 'Veilig downloaden van Easy-RSA is mislukt.' >&2
			rm -f -- "$easy_rsa_archive"
			exit 1
		fi
	elif command -v wget >/dev/null 2>&1; then
		if ! wget --https-only --timeout=120 --tries=3 -qO "$easy_rsa_archive" "$easy_rsa_url"; then
			say 'Failed to download Easy-RSA securely.' 'Veilig downloaden van Easy-RSA is mislukt.' >&2
			rm -f -- "$easy_rsa_archive"
			exit 1
		fi
	else
		say 'curl or wget is required for the verified Easy-RSA download.' 'Voor de geverifieerde Easy-RSA-download is curl of wget nodig.' >&2
		rm -f -- "$easy_rsa_archive"
		exit 1
	fi
	if ! printf '%s  %s\n' "$easy_rsa_sha256" "$easy_rsa_archive" | sha256sum --check --status; then
		say 'Easy-RSA SHA-256 verification failed. Refusing extraction.' 'De SHA-256-controle van Easy-RSA is mislukt. Uitpakken wordt geweigerd.' >&2
		rm -f -- "$easy_rsa_archive"
		exit 1
	fi
	mkdir -p /etc/openvpn/server/easy-rsa/ || exit 1
	if ! tar -xzf "$easy_rsa_archive" --strip-components 1 --no-same-owner --no-same-permissions -C /etc/openvpn/server/easy-rsa/; then
		say 'Could not extract the verified Easy-RSA archive.' 'Het geverifieerde Easy-RSA-archief kon niet worden uitgepakt.' >&2
		rm -f -- "$easy_rsa_archive"
		exit 1
	fi
	rm -f -- "$easy_rsa_archive"
	chown -R root:root /etc/openvpn/server/easy-rsa/ || exit 1
	cd /etc/openvpn/server/easy-rsa/ || exit 1
	# PKI failures are fatal: never continue with half-created keys.
	./easyrsa --batch init-pki || exit 1
	./easyrsa --batch build-ca nopass || exit 1
	./easyrsa gen-tls-crypt-key || exit 1
	# Create the DH parameters file using the predefined ffdhe2048 group
	echo '-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA//////////+t+FRYortKmq/cViAnPTzx2LnFg84tNpWp4TZBFGQz
+8yTnc4kmz75fS/jY2MMddj2gbICrsRhetPfHtXV/WVhJDP1H18GbtCFY2VVPe0a
87VXE15/V8k1mE8McODmi3fipona8+/och3xWKE2rec1MKzKT0g6eXq8CrGCsyT7
YdEIqUuyyOP7uWrat2DX9GgdT0Kj3jlN9K5W7edjcrsZCwenyO4KbXCeAvzhzffi
7MA0BM0oNC9hkXL+nOmFg/+OTxIy7vKBg8P+OxtMb61zO7X8vC7CIAXFjvGDfRaD
ssbzSibBsu/6iGtCOGEoXJf//////////wIBAg==
-----END DH PARAMETERS-----' > /etc/openvpn/server/dh.pem
	# Make easy-rsa aware of our external DH file (prevents a warning)
	ln -s /etc/openvpn/server/dh.pem pki/dh.pem
	# Create certificates and CRL
	./easyrsa --batch --days=3650 build-server-full server nopass || exit 1
	./easyrsa --batch --days=3650 build-client-full "$client" nopass || exit 1
	./easyrsa --batch --days=3650 gen-crl || exit 1
	# Move the stuff we need
	cp pki/ca.crt pki/private/ca.key pki/issued/server.crt pki/private/server.key pki/crl.pem /etc/openvpn/server
	cp pki/private/easyrsa-tls.key /etc/openvpn/server/tc.key
	# CRL is read with each client connection, while OpenVPN is dropped to nobody
	chown nobody:"$group_name" /etc/openvpn/server/crl.pem
	# Without +x in the directory, OpenVPN can't run a stat() on the CRL file
	chmod o+x /etc/openvpn/server/
	# Generate server.conf
	echo "local $ip
port $port
proto $protocol
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA512
tls-crypt tc.key
tls-version-min 1.2
data-ciphers AES-256-GCM:AES-128-GCM
topology subnet
server 10.8.0.0 255.255.255.0" > /etc/openvpn/server/server.conf
	# IPv6
	if [[ -z "$ip6" ]]; then
		echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server/server.conf
	else
		echo 'server-ipv6 fddd:1194:1194:1194::/64' >> /etc/openvpn/server/server.conf
		echo 'push "redirect-gateway def1 ipv6 bypass-dhcp"' >> /etc/openvpn/server/server.conf
	fi
	echo 'ifconfig-pool-persist ipp.txt' >> /etc/openvpn/server/server.conf
	# DNS
	case "$dns" in
		1|"")
			# Locate the proper resolv.conf
			# Needed for systems running systemd-resolved
			if grep '^nameserver' "/etc/resolv.conf" | grep -qv '127.0.0.53' ; then
				resolv_conf="/etc/resolv.conf"
			else
				resolv_conf="/run/systemd/resolve/resolv.conf"
			fi
			# Obtain the resolvers from resolv.conf and use them for OpenVPN
			grep -v '^#\|^;' "$resolv_conf" | grep '^nameserver' | grep -v '127.0.0.53' | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | while read line; do
				echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server/server.conf
			done
		;;
		2)
			echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server/server.conf
		;;
		3)
			echo 'push "dhcp-option DNS 1.1.1.1"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 1.0.0.1"' >> /etc/openvpn/server/server.conf
		;;
		4)
			echo 'push "dhcp-option DNS 208.67.222.222"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 208.67.220.220"' >> /etc/openvpn/server/server.conf
		;;
		5)
			echo 'push "dhcp-option DNS 9.9.9.9"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 149.112.112.112"' >> /etc/openvpn/server/server.conf
		;;
		6)
			echo 'push "dhcp-option DNS 95.85.95.85"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 2.56.220.2"' >> /etc/openvpn/server/server.conf
		;;
		7)
			echo 'push "dhcp-option DNS 94.140.14.14"' >> /etc/openvpn/server/server.conf
			echo 'push "dhcp-option DNS 94.140.15.15"' >> /etc/openvpn/server/server.conf
		;;
		8)
		for dns_ip in $custom_dns; do
			echo "push \"dhcp-option DNS $dns_ip\"" >> /etc/openvpn/server/server.conf
		done
		;;
	esac
	echo 'push "block-outside-dns"' >> /etc/openvpn/server/server.conf
	echo "keepalive 10 120
user nobody
group $group_name
persist-key
persist-tun
verb 3
crl-verify crl.pem" >> /etc/openvpn/server/server.conf
	if [[ "$protocol" = "udp" ]]; then
		echo "explicit-exit-notify" >> /etc/openvpn/server/server.conf
	fi
	# Enable net.ipv4.ip_forward for the system
	echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-openvpn-forward.conf
	# Enable without waiting for a reboot or service restart
	echo 1 > /proc/sys/net/ipv4/ip_forward
	if [[ -n "$ip6" ]]; then
		# Enable net.ipv6.conf.all.forwarding for the system
		echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.d/99-openvpn-forward.conf
		# Enable without waiting for a reboot or service restart
		echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
	fi
	if systemctl is-active --quiet firewalld.service; then
		# Using both permanent and not permanent rules to avoid a firewalld
		# reload.
		# We don't use --add-service=openvpn because that would only work with
		# the default port and protocol.
		firewall-cmd --add-port="$port"/"$protocol"
		firewall-cmd --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --permanent --add-port="$port"/"$protocol"
		firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
		# Set NAT for the VPN subnet
		firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
		firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
		if [[ -n "$ip6" ]]; then
			firewall-cmd --zone=trusted --add-source=fddd:1194:1194:1194::/64
			firewall-cmd --permanent --zone=trusted --add-source=fddd:1194:1194:1194::/64
			firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
			firewall-cmd --permanent --direct --add-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
		fi
	else
		# Create a service to set up persistent iptables rules
		iptables_path=$(command -v iptables)
		ip6tables_path=$(command -v ip6tables)
		# nf_tables is not available as standard in OVZ kernels. So use iptables-legacy
		# if we are in OVZ, with a nf_tables backend and iptables-legacy is available.
		if [[ $(systemd-detect-virt) == "openvz" ]] && readlink -f "$(command -v iptables)" | grep -q "nft" && hash iptables-legacy 2>/dev/null; then
			iptables_path=$(command -v iptables-legacy)
			ip6tables_path=$(command -v ip6tables-legacy)
		fi
		echo "[Unit]
After=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
ExecStart=$iptables_path -w 5 -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $ip
ExecStart=$iptables_path -w 5 -I INPUT -p $protocol --dport $port -j ACCEPT
ExecStart=$iptables_path -w 5 -I FORWARD -s 10.8.0.0/24 -j ACCEPT
ExecStart=$iptables_path -w 5 -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
ExecStop=$iptables_path -w 5 -t nat -D POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $ip
ExecStop=$iptables_path -w 5 -D INPUT -p $protocol --dport $port -j ACCEPT
ExecStop=$iptables_path -w 5 -D FORWARD -s 10.8.0.0/24 -j ACCEPT
ExecStop=$iptables_path -w 5 -D FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" > /etc/systemd/system/openvpn-iptables.service
		if [[ -n "$ip6" ]]; then
			echo "ExecStart=$ip6tables_path -w 5 -t nat -A POSTROUTING -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to $ip6
ExecStart=$ip6tables_path -w 5 -I FORWARD -s fddd:1194:1194:1194::/64 -j ACCEPT
ExecStart=$ip6tables_path -w 5 -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
ExecStop=$ip6tables_path -w 5 -t nat -D POSTROUTING -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to $ip6
ExecStop=$ip6tables_path -w 5 -D FORWARD -s fddd:1194:1194:1194::/64 -j ACCEPT
ExecStop=$ip6tables_path -w 5 -D FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/systemd/system/openvpn-iptables.service
		fi
		echo "RemainAfterExit=yes
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/openvpn-iptables.service
		systemctl enable --now openvpn-iptables.service
	fi
	# If SELinux is enabled and a custom port was selected, we need this
	if sestatus 2>/dev/null | grep "Current mode" | grep -q "enforcing" && [[ "$port" != 1194 ]]; then
		# Install semanage if not already present
		if ! hash semanage 2>/dev/null; then
				dnf install -y policycoreutils-python-utils
		fi
		semanage port -a -t openvpn_port_t -p "$protocol" "$port"
	fi
	# If the server is behind NAT, use the correct IP address
	[[ -n "$public_ip" ]] && ip="$public_ip"
	# client-common.txt is created so we have a template to add further users later
	echo "client
dev tun
proto $protocol
remote $ip $port
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
tls-version-min 1.2
data-ciphers AES-256-GCM:AES-128-GCM
ignore-unknown-option block-outside-dns
verb 3" > /etc/openvpn/server/client-common.txt
	# Enable and start the OpenVPN service
	if ! systemctl enable --now openvpn-server@server.service; then
		say 'OpenVPN did not start. Check: journalctl -u openvpn-server@server.service' 'OpenVPN kon niet starten. Controleer: journalctl -u openvpn-server@server.service' >&2
		exit 1
	fi
	# Build the $client.ovpn file, stripping comments from easy-rsa in the process
	grep -vh '^#' /etc/openvpn/server/client-common.txt /etc/openvpn/server/easy-rsa/pki/inline/private/"$client".inline > "$script_dir"/"$client".ovpn
	echo
	say 'Installation completed!' 'Installatie voltooid!'
	echo
	printf '%s %s\n' "$(L 'Client configuration:' 'VPN-gebruikersbestand:')" "$script_dir/$client.ovpn"
	say 'Run this script again to add VPN clients.' 'Start dit script opnieuw om VPN-gebruikers toe te voegen.'
else
	clear
	say 'OpenVPN is already installed.' 'OpenVPN is al geïnstalleerd.'
	echo
	say 'Choose an option:' 'Kies een optie:'
	say '   1) Add a new VPN client' '   1) VPN-gebruiker toevoegen'
	say '   2) Revoke a VPN client' '   2) VPN-gebruiker intrekken'
	say '   3) Remove OpenVPN' '   3) OpenVPN verwijderen'
	say '   4) Exit' '   4) Afsluiten'
	read -r -p "$(L 'Option: ' 'Optie: ')" option
	until [[ "$option" =~ ^[1-4]$ ]]; do
		printf '%s: %s\n' "$option" "$(L 'invalid selection' 'ongeldige keuze')"
		read -r -p "$(L 'Option: ' 'Optie: ')" option
	done
	# Backup before client addition, revocation or removal (not when exiting).
	if [[ "$option" =~ ^[123]$ ]]; then
		backup_existing_openvpn || exit 1
	fi
	case "$option" in
		1)
			echo
			say 'Enter a name for the VPN client:' 'Voer een naam in voor de VPN-gebruiker:'
			read -r -p "$(L 'Name: ' 'Naam: ')" unsanitized_client
			client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_client")
			while [[ -z "$client" || -e /etc/openvpn/server/easy-rsa/pki/issued/"$client".crt ]]; do
				printf '%s: %s\n' "$client" "$(L 'invalid client name' 'ongeldige gebruikersnaam')"
				read -r -p "$(L 'Name: ' 'Naam: ')" unsanitized_client
				client=$(sed 's/[^0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-]/_/g' <<< "$unsanitized_client")
			done
			cd /etc/openvpn/server/easy-rsa/
			./easyrsa --batch --days=3650 build-client-full "$client" nopass
			# Build the $client.ovpn file, stripping comments from easy-rsa in the process
			grep -vh '^#' /etc/openvpn/server/client-common.txt /etc/openvpn/server/easy-rsa/pki/inline/private/"$client".inline > "$script_dir"/"$client".ovpn
			echo
			printf '%s %s\n' "$(L "$client added. Client configuration:" "$client toegevoegd. VPN-gebruikersbestand:")" "$script_dir/$client.ovpn"
			exit
		;;
		2)
			# This option could be documented a bit better and maybe even be simplified
			# ...but what can I say, I want some sleep too
			number_of_clients=$(tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep -c "^V")
			if [[ "$number_of_clients" = 0 ]]; then
				echo
				say 'There are no VPN clients to revoke.' 'Er zijn geen VPN-gebruikers om in te trekken.'
				exit
			fi
			echo
			say 'Choose the VPN client to revoke:' 'Kies de VPN-gebruiker die je wilt intrekken:'
			tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
			read -r -p "$(L 'Client: ' 'Gebruiker: ')" client_number
			until [[ "$client_number" =~ ^[0-9]+$ && "$client_number" -le "$number_of_clients" ]]; do
				printf '%s: %s\n' "$client_number" "$(L 'invalid selection' 'ongeldige keuze')"
				read -r -p "$(L 'Client: ' 'Gebruiker: ')" client_number
			done
			client=$(tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$client_number"p)
			echo
			read -r -p "$(L "Revoke VPN client $client? [y/N]: " "VPN-gebruiker $client intrekken? [j/N]: ")" revoke
			until [[ "$revoke" =~ ^[yYjJnN]*$ ]]; do
				printf '%s: %s\n' "$revoke" "$(L 'invalid selection' 'ongeldige keuze')"
				read -r -p "$(L "Revoke VPN client $client? [y/N]: " "VPN-gebruiker $client intrekken? [j/N]: ")" revoke
			done
			if [[ "$revoke" =~ ^[yYjJ]$ ]]; then
				cd /etc/openvpn/server/easy-rsa/
				./easyrsa --batch revoke "$client"
				./easyrsa --batch --days=3650 gen-crl
				rm -f /etc/openvpn/server/crl.pem
				rm -f /etc/openvpn/server/easy-rsa/pki/reqs/"$client".req
				rm -f /etc/openvpn/server/easy-rsa/pki/private/"$client".key
				cp /etc/openvpn/server/easy-rsa/pki/crl.pem /etc/openvpn/server/crl.pem
				# CRL is read with each client connection, when OpenVPN is dropped to nobody
				chown nobody:"$group_name" /etc/openvpn/server/crl.pem
				echo
				printf '%s\n' "$(L "VPN client $client revoked!" "VPN-gebruiker $client is ingetrokken!")"
			else
				echo
				printf '%s\n' "$(L "Revocation of $client cancelled." "Intrekken van $client geannuleerd.")"
			fi
			exit
		;;
		3)
			echo
			read -r -p "$(L 'Remove OpenVPN? [y/N]: ' 'OpenVPN verwijderen? [j/N]: ')" remove
			until [[ "$remove" =~ ^[yYjJnN]*$ ]]; do
				printf '%s: %s\n' "$remove" "$(L 'invalid selection' 'ongeldige keuze')"
				read -r -p "$(L 'Remove OpenVPN? [y/N]: ' 'OpenVPN verwijderen? [j/N]: ')" remove
			done
			if [[ "$remove" =~ ^[yYjJ]$ ]]; then
				port=$(grep '^port ' /etc/openvpn/server/server.conf | cut -d " " -f 2)
				protocol=$(grep '^proto ' /etc/openvpn/server/server.conf | cut -d " " -f 2)
				if systemctl is-active --quiet firewalld.service; then
					ip=$(firewall-cmd --direct --get-rules ipv4 nat POSTROUTING | grep '\-s 10.8.0.0/24 '"'"'!'"'"' -d 10.8.0.0/24' | grep -oE '[^ ]+$')
					# Using both permanent and not permanent rules to avoid a firewalld reload.
					firewall-cmd --remove-port="$port"/"$protocol"
					firewall-cmd --zone=trusted --remove-source=10.8.0.0/24
					firewall-cmd --permanent --remove-port="$port"/"$protocol"
					firewall-cmd --permanent --zone=trusted --remove-source=10.8.0.0/24
					firewall-cmd --direct --remove-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
					firewall-cmd --permanent --direct --remove-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
					if grep -qs "server-ipv6" /etc/openvpn/server/server.conf; then
						ip6=$(firewall-cmd --direct --get-rules ipv6 nat POSTROUTING | grep '\-s fddd:1194:1194:1194::/64 '"'"'!'"'"' -d fddd:1194:1194:1194::/64' | grep -oE '[^ ]+$')
						firewall-cmd --zone=trusted --remove-source=fddd:1194:1194:1194::/64
						firewall-cmd --permanent --zone=trusted --remove-source=fddd:1194:1194:1194::/64
						firewall-cmd --direct --remove-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
						firewall-cmd --permanent --direct --remove-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
					fi
				else
					systemctl disable --now openvpn-iptables.service
					rm -f /etc/systemd/system/openvpn-iptables.service
				fi
				if sestatus 2>/dev/null | grep "Current mode" | grep -q "enforcing" && [[ "$port" != 1194 ]]; then
					semanage port -d -t openvpn_port_t -p "$protocol" "$port"
				fi
				systemctl disable --now openvpn-server@server.service
				rm -f /etc/systemd/system/openvpn-server@server.service.d/disable-limitnproc.conf
				rm -f /etc/sysctl.d/99-openvpn-forward.conf
				if [[ "$os" = "debian" || "$os" = "ubuntu" ]]; then
					rm -rf /etc/openvpn/server
					apt-get remove --purge -y openvpn
				else
					# Else, OS must be CentOS or Fedora
					dnf remove -y openvpn
					rm -rf /etc/openvpn/server
				fi
				echo
				say 'OpenVPN removed.' 'OpenVPN is verwijderd.'
			else
				echo
				say 'OpenVPN removal cancelled.' 'Verwijderen van OpenVPN is geannuleerd.'
			fi
			exit
		;;
		4)
			exit
		;;
	esac
fi
