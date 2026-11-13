# OpenVPN Installer — sosaklingo · Nederlands / English (2026)

**Een enkel Bash-script. Kies Nederlands of Engels wanneer je het start.**  
**One Bash script. Choose Dutch or English when you start it.**

Onderhoudsversie van [Nyr/openvpn-install](https://github.com/Nyr/openvpn-install), gebaseerd op upstream commit `7ff931a` (22 september 2026). Oorspronkelijke auteur Nyr, MIT-licentie. De `sosaklingo`-fork begon in 2015.

Maintenance version of Nyr's original MIT-licensed OpenVPN installer. The 2015 version remains available in branch [`legacy-2015`](https://github.com/sosaklingo/openvpn-install/tree/legacy-2015).

> **Let op / Important:** De automatische Bash- en menutests slagen, maar een volledige installatie op echte servers is nog niet getest. Gebruik eerst een test-VM, maak een back-up en zorg voor consoletoegang. Passing CI does **not** prove a production install is safe.

## Nederlands — snel beginnen

**Geschikt voor:** Ubuntu 22.04+, Debian 11+ en actuele Fedora / AlmaLinux / Rocky Linux / CentOS 9+-systemen, afhankelijk van de beschikbare pakketten. Vereist een Linux-server met Bash, `sudo`, `systemd`, TUN en internettoegang.

1. Download het **ene** script en controleer eerst wat het doet:

   ```bash
   curl -fL --proto '=https' --tlsv1.2 -o openvpn-install.sh \
     https://raw.githubusercontent.com/sosaklingo/openvpn-install/modern-2026/openvpn-install.sh
   bash -n openvpn-install.sh
   bash openvpn-install.sh --preview
   bash openvpn-install.sh --check
   ```

2. Test op een **lege testserver** en start de begeleide installatie:

   ```bash
   sudo bash openvpn-install.sh
   ```

3. Kies **1. Nederlands** (of **2. English**) en druk op Enter om standaardkeuzes te accepteren, zoals UDP, poort 1194 en de DNS-resolvers van het systeem.

Je kunt de taal ook direct vastzetten met `sudo bash openvpn-install.sh --nl` of `sudo bash openvpn-install.sh --en`.

**Voor een bestaande VPN-server**: niet meteen installeren. Raadpleeg [MIGRATION.md](MIGRATION.md) voor oude servers. Een server uit 2015 wordt bewust niet automatisch gemigreerd.

## English — quick start

1. Download the single script and inspect it before using root privileges:

   ```bash
   curl -fL --proto '=https' --tlsv1.2 -o openvpn-install.sh \
     https://raw.githubusercontent.com/sosaklingo/openvpn-install/modern-2026/openvpn-install.sh
   bash -n openvpn-install.sh
   bash openvpn-install.sh --preview --lang en
   bash openvpn-install.sh --check --lang en
   ```

2. On a **disposable test VM**, run:

   ```bash
   sudo bash openvpn-install.sh
   ```

3. Choose **2. English**, then follow the prompts. Default choices are UDP, port 1194 and the system DNS resolvers. Use `sudo bash openvpn-install.sh --lang en` to skip the language selection.

Do not execute this on an existing production server without backups, out-of-band console access, and a migration plan.

## Functies / Features

- Eenvoudig tweetalig interactief menu / Simple bilingual interactive installer and management menu.
- Een script, twee talen / One script, two languages.
- `--preview` bekijkt de stappen zonder veranderingen / previews the steps without changes.
- `--check` controleert het systeem zonder wijzigingen / performs a read-only preflight.
- `--nl`, `--en`, `--lang nl`, `--lang en`: taal kiezen / language override.
- Voor het installeren moet je **JA** (Nederlands) of **YES** (English) typen / explicit confirmation before install.
- Bij aanpassingen aan bestaande OpenVPN-configuraties wordt een afgeschermde back-up gemaakt in `/var/backups/openvpn-sosaklingo/`. Alleen root krijgt toegang / protected root-only backup before changing existing configs.
- De back-up bewaart **OpenVPN-configuratie en sleutels**, geen firewall of geïnstalleerde pakketten. Er is **geen automatische rollback** / configuration backup only, not a full-system rollback.
- Modern OpenVPN `tls-crypt`, minimaal TLS 1.2, AES-256-GCM en AES-128-GCM.
- Easy-RSA **3.2.7**, HTTPS-download en controle met de officiële SHA-256-hash.
- Voorkomt automatische migratie van de indeling uit 2015 / blocks implicit legacy migration.
- `umask 077` beperkt toegang tot gemaakte configuratiebestanden / restricts file permissions.

**Nog niet bewezen / Not yet proven:** echte installatie, volledige automatische rollback, firewallgedrag op alle distributies, DNS-lektests en langdurige VPN-verbindingen. See [SECURITY.md](SECURITY.md) and [MIGRATION.md](MIGRATION.md).

## Tests

```bash
bash -n openvpn-install.sh
bash tests/test_installer.sh
```

CI controleert de shellsyntax, tweetalige menu's, foutieve opties en beveiligingscontroles zonder met rootrechten een VPN te installeren.  
CI checks syntax, bilingual menus, rejected options and static safeguards; it does not provision VPN servers.

## Licentie / Attribution

OpenVPN install installer original © 2013 **Nyr**, licensed MIT. Fork maintained by **sosaklingo** (2015), further developed in collaboration with ChatGPT (OpenAI) in November 2026. No endorsement by OpenVPN, Nyr or OpenAI is implied.
