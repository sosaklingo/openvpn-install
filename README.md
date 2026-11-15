# OpenVPN Installer — Nederlands / English

**Eén Bash-bestand voor installatie en beheer, met Nederlandse en Engelse menu's.**  
**One Bash file for installation and management, with Dutch and English menus.**

Deze documentatie hoort bij **modern-2026**, bijgewerkt op 15 november 2026.  
This documentation covers **modern-2026**, updated on 15 November 2026.

## Handleiding / Manual

| Nederlands | English |
| --- | --- |
| [Volledige Nederlandse handleiding](docs/HANDLEIDING-NL.md) | [Complete English manual](docs/MANUAL-EN.md) |
| [Migratie en herstel](MIGRATION.md) | [Migration and recovery](MIGRATION.md) |
| [Beveiliging en grenzen](SECURITY.md) | [Security and limitations](SECURITY.md) |
| [Testen en praktijktestplan](TESTING.md) | [Tests and live test plan](TESTING.md) |
| [Wijzigingen](CHANGELOG.md) | [Changes](CHANGELOG.md) |

**Status:** automatische syntax-, menu- en foutafhandelingstests zijn uitgevoerd. Een volledige serverinstallatie, echte clientverbinding, herstart en DNS-/IPv6-lektest zijn nog niet bevestigd. Een groene test is geen bewijs van een veilige productie-installatie.

**Status:** automated syntax, menu and failure-handling tests have been run. A complete server installation, real client connection, reboot and DNS/IPv6 leak test have not yet been confirmed. Passing tests do not prove production readiness.

## Snel beginnen / Quick start

Begin op een aparte Linux-testserver met Bash, systemd, TUN, sudo/root en curl. Het script accepteert Ubuntu 22.04+, Debian 11+, AlmaLinux/Rocky/CentOS 9+ en Fedora, zonder dat al deze systemen volledig zijn getest.

Start on a separate Linux test server with Bash, systemd, TUN, sudo/root and curl. The script accepts Ubuntu 22.04+, Debian 11+, AlmaLinux/Rocky/CentOS 9+ and Fedora; not all these systems have been fully tested.

Download het ene bestand / Download the single file:

```bash
mkdir -p ~/openvpn-installer
cd ~/openvpn-installer
curl -fL --proto '=https' --tlsv1.2 -o openvpn-install.sh.download \
  https://raw.githubusercontent.com/sosaklingo/openvpn-install/modern-2026/openvpn-install.sh
```

Ga alleen verder als de download slaagt. / Continue only after a successful download.

```bash
bash -n openvpn-install.sh.download &&
mv openvpn-install.sh.download openvpn-install.sh
```

Bekijk de code, kies je taal en controleer vóór installatie.  
Inspect the code, choose your language and check before installing.

**Nederlands:**

```bash
bash openvpn-install.sh --lang nl --preview
bash openvpn-install.sh --lang nl --check
bash openvpn-install.sh --lang nl --self-test
sudo bash openvpn-install.sh --lang nl
```

**English:**

```bash
bash openvpn-install.sh --lang en --preview
bash openvpn-install.sh --lang en --check
bash openvpn-install.sh --lang en --self-test
sudo bash openvpn-install.sh --lang en
```

Los gemelde problemen op voordat je installeert. Kies protocol, poort, versleuteling, DNS en clientnaam. Bevestig met **JA** of **YES**. Het .ovpn-profiel komt naast het script; importeer dit veilig in je OpenVPN-client.

Resolve reported problems before installation. Choose protocol, port, encryption, DNS and client name. Confirm with **JA** or **YES**. The .ovpn profile is saved beside the script; securely import it into your OpenVPN client.

Een nieuwe scriptdownload wijzigt je bestaande server niet automatisch. De standaardbranch kan andere code bevatten: gebruik de link naar **modern-2026** hierboven.  
Downloading a new script does not automatically update your existing server. The default branch may contain different code: use the **modern-2026** link above.

## Beheer / Management

Start hetzelfde script opnieuw. / Run the same script again.

| Optie / Option | Nederlands | English |
| --- | --- | --- |
| 1 | Gebruiker toevoegen | Add client |
| 2 | Gebruiker intrekken | Revoke client |
| 3 | OpenVPN verwijderen | Remove OpenVPN |
| 4 | Afsluiten | Exit |
| 5 | Diagnose bekijken | Show diagnostics |
| 6 | Intrekkingslijst herstellen | Rebuild and publish revocation list |

Optie 6 herstelt het maken/publiceren van de certificaatintrekkingslijst. Als intrekken zelf mislukte, moet je eerst optie 2 opnieuw gebruiken. Optie 6 hervat geen installatie en herstelt geen firewall.

Option 6 repairs generation/publication of the certificate revocation list. If revocation itself failed, retry option 2 first. Option 6 does not resume installation or repair the firewall.

## Inbegrepen / Included

- Taal-, poort- en dataversleutelingsmenu / Language, port and data-encryption menus.
- Automatische AES-GCM-keuze, AES-256-GCM, AES-128-GCM of ChaCha20-Poly1305 bij ondersteuning / Automatic AES-GCM selection, AES-256-GCM, AES-128-GCM or ChaCha20-Poly1305 when supported.
- tls-crypt, minimaal TLS 1.2, vastgezette Easy-RSA 3.2.7-download met SHA-256-controle / tls-crypt, minimum TLS 1.2, pinned Easy-RSA 3.2.7 download with SHA-256 verification.
- Afgeschermde configuratieback-ups; gecontroleerde vervanging van profielen en CRL / Restricted configuration backups; staged replacement of profiles and CRL.
- Detectie van onvolledige installatie, hersteloptie voor intrekkingen, extra foutcontroles / Incomplete-install detection, revocation recovery and additional error checks.
- Alleen-lezen diagnose en demonstraties / Read-only diagnostics and demonstrations.

Back-ups bevatten sleutels en zijn **niet versleuteld**. Er is geen volledige rollback, automatische hervatting of automatische migratie vanaf de oude indeling. DNS-/IPv6-lekbeveiliging moet per client worden getest. Zie de handleiding voor alle opties en beperkingen.

Backups contain keys and are **not encrypted**. There is no full rollback, automatic resume or automatic migration from the legacy layout. DNS/IPv6 leak protection must be tested per client. See the manual for all options and limitations.

## Tests

```bash
bash -n openvpn-install.sh
bash tests/test_installer.sh
```

De tests vereisen de repository, niet alleen het installerbestand. Ze installeren geen VPN.  
Tests require the repository, not just the installer file. They do not install a VPN.

[GitHub Actions](https://github.com/sosaklingo/openvpn-install/actions) · [Praktijktestplan / Live test plan](TESTING.md)

## Herkomst en licentie / Attribution and license

Gebaseerd op [Nyr/openvpn-install](https://github.com/Nyr/openvpn-install), upstream-revisie 7ff931a00c37a6806bd1fa8cb61bf3369d963e94. Oorspronkelijke auteur © 2013 Nyr, [MIT-licentie](LICENSE.txt). Fork onderhouden door sosaklingo; verdere ontwikkeling met ChatGPT (OpenAI) in november 2026.

Based on Nyr/openvpn-install at the upstream revision above. Original author © 2013 Nyr, MIT license. Fork maintained by sosaklingo, further developed with ChatGPT (OpenAI) in November 2026. No endorsement by OpenVPN, Nyr or OpenAI is implied.

De historische code staat in [legacy-2015](https://github.com/sosaklingo/openvpn-install/tree/legacy-2015), uitsluitend ter referentie.  
Historical code is in legacy-2015 for reference.
