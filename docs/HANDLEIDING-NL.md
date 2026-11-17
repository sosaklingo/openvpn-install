# Nederlandse handleiding

[English](MANUAL-EN.md) · [Startpagina](../README.md) · [Beveiliging](../SECURITY.md) · [Migratie en herstel](../MIGRATION.md)

Bijgewerkt: 15 november 2026. Voor de moderne installer.

## 1. Voorbereiden

Je gebruikt **één installatiebestand: openvpn-install.sh**. De documentatie en tests zijn geen extra installatieonderdelen. Het script installeert en beheert een OpenVPN-server; de VPN-app op je telefoon of computer installeer je afzonderlijk.

De versiecontrole accepteert Ubuntu 22.04+, Debian 11+, AlmaLinux/Rocky/CentOS 9+ en Fedora. Debian Testing/Unstable wordt geweigerd. Dat betekent niet dat iedere toegestane versie getest is.

Nodig: Bash, systemd, TUN, internettoegang, sudo/root en curl of wget. Voor de opdrachten hieronder gebruik je curl. Begin op een aparte testserver. Zorg bij een bestaande server voor een gecontroleerde back-up en consoletoegang buiten de VPN.

**Teststatus:** automatische syntax-, menu- en foutafhandelingstests zijn beschikbaar. Een volledige installatie, echte VPN-verbinding, herstart en DNS-/IPv6-lektest zijn nog niet bevestigd.

Bij een server achter een router moet de gekozen UDP- of TCP-poort naar het lokale serveradres worden doorgestuurd. Controleer ook de providerfirewall. Het script stelt je router of providerfirewall niet in. Dit betreft de serverlocatie; niet ieder clientapparaat heeft een poortdoorsturing nodig.

## 2. Downloaden en controleren

Op de Linux-server:

```bash
mkdir -p ~/openvpn-installer
cd ~/openvpn-installer
curl -fL --proto '=https' --tlsv1.2 -o openvpn-install.sh.download \
  https://raw.githubusercontent.com/sosaklingo/openvpn-install/d946773aa2066d71285134f86417ca646237e8f4/openvpn-install.sh
```

Ga alleen verder als de download zonder fout is voltooid:

```bash
bash -n openvpn-install.sh.download &&
mv openvpn-install.sh.download openvpn-install.sh
```

Bekijk de code voordat je deze als root uitvoert. Probeer vervolgens:

```bash
bash openvpn-install.sh --lang nl --preview
bash openvpn-install.sh --lang nl --check
bash openvpn-install.sh --lang nl --self-test
```

Dit installeert niets. --check is een basiscontrole, geen volledige beveiligings- of bereikbaarheidstest. Een ontbrekend TUN-apparaat kan aanpassing bij je serverprovider vereisen.

## 3. Nieuwe installatie

```bash
sudo bash openvpn-install.sh --lang nl
```

Zonder taaloptie kies je eerst Nederlands of English. Waar nodig vraagt het script lokale IP-adressen en het openbare adres bij NAT. Daarna volgen:

| Stap | Keuze |
| --- | --- |
| Protocol | UDP (standaard) of TCP |
| Poort | 1194 (standaard), of 1 t/m 65535 |
| Versleuteling | Een van de vier opties hieronder |
| DNS | Systeem-DNS, een getoonde provider of eigen IPv4-adressen |
| Clientnaam | Bijvoorbeeld marco-telefoon; letters, cijfers, - en _ |
| Bevestiging | Typ exact JA; andere invoer annuleert |

Gebruik server niet als clientnaam: deze naam is voor het servercertificaat. Controleer vooraf of het VPN-subnet 10.8.0.0/24 niet overlapt met je netwerk.

### Versleuteling

| Optie | Instelling |
| --- | --- |
| 1 of Enter | AES-256-GCM:AES-128-GCM, automatische onderhandeling |
| 2 | Alleen AES-256-GCM |
| 3 | Alleen AES-128-GCM |
| 4 | Alleen CHACHA20-POLY1305 |

Optie 1 is de standaard. Server én clients moeten de gekozen methode ondersteunen. Het script controleert serverondersteuning, niet alle apparaten. Deze keuze wijzigt niet de TLS-instellingen. Dit menu verschijnt bij een nieuwe installatie; er is geen menu om bestaande versleuteling live te wijzigen.

### DNS

| Optie | Keuze |
| --- | --- |
| 1 of Enter | DNS van het systeem |
| 2 | Google: 8.8.8.8 en 8.8.4.4 |
| 3 | Cloudflare: 1.1.1.1 en 1.0.0.1 |
| 4 | OpenDNS |
| 5 | Quad9 |
| 6 | Gcore |
| 7 | AdGuard |
| 8 | Eigen IPv4-adressen, gescheiden door spaties of komma's |

Dit zijn de keuzes in de code, geen garantie dat elke resolver bereikbaar is. DNS kiezen bewijst niet dat er geen DNS-lek is.

## 4. Verbinden

Na succes staat clientnaam.ovpn **in de map van het Bash-script**. Het exacte pad verschijnt in beeld. Het profiel bevat een privésleutel; behandel het als een wachtwoord.

1. Breng het profiel via een beveiligde overdracht, bijvoorbeeld SFTP, naar je apparaat.
2. Importeer het in een compatibele OpenVPN-client.
3. Maak verbinding.
4. Controleer internettoegang, het zichtbare openbare IP-adres en DNS-/IPv6-gedrag.

Het uitvoerbestand is standaard alleen voor root leesbaar. Maak het niet voor iedereen leesbaar om overdracht te vereenvoudigen. Gebruik een aparte clientnaam per apparaat. Publiceer geen profielen, sleutels of back-ups op GitHub.

## 5. Beheermenu

Start hetzelfde script opnieuw:

```bash
sudo bash openvpn-install.sh --lang nl
```

| Optie | Werking |
| --- | --- |
| 1 | Gebruiker toevoegen en nieuw .ovpn-profiel maken |
| 2 | Gebruiker selecteren en certificaat intrekken |
| 3 | OpenVPN verwijderen na bevestiging |
| 4 | Afsluiten |
| 5 | Diagnose zonder instellingen te wijzigen |
| 6 | Lijst met ingetrokken certificaten opnieuw maken en publiceren |

Bij 1, 2, 3 en 6 wordt eerst een configuratieback-up geprobeerd. Mislukt deze, dan stopt de actie. Toevoegen wordt geblokkeerd bij een onvolledige installatie of openstaande intrekking.

Intrekken verwijdert niet alle eerder gekopieerde profielen. Er is geen aparte functie om een bestaande clientsessie onmiddellijk te verbreken. Controleer intrekking met een nieuwe verbindingspoging.

## 6. Hersteloptie 6

Een CRL is de lijst met ingetrokken certificaten. Als een intrekking of het publiceren van die lijst mislukt:

1. Lees de oorspronkelijke fout en herstel de oorzaak, bijvoorbeeld schijfruimte of bestandsrechten.
2. Start het script opnieuw en kies **6**.
3. Controleer de melding dat de lijst is bijgewerkt.
4. Test dat het ingetrokken profiel bij een nieuwe verbinding wordt geweigerd.

De bestaande CRL blijft staan totdat de nieuwe klaar is. Een nieuwe intrekking kan tijdens een mislukte verwerking dus nog niet actief zijn.

Zegt optie 6 dat de gebruiker nog niet is ingetrokken? Kies eerst **2** en trek die gebruiker opnieuw in. Optie 6 trekt zelf geen extra gebruiker in, hervat geen installatie en herstelt geen firewall. De herstelactie ruimt ook niet alle lokale clientbestanden op.

## 7. Diagnose en problemen

```bash
sudo bash openvpn-install.sh --lang nl --diagnose
sudo systemctl status openvpn-server@server.service --no-pager
sudo journalctl -u openvpn-server@server.service -n 80 --no-pager
```

| Probleem | Volgende stap |
| --- | --- |
| Onvolledige installatie | Bewaar fout en back-up; inspecteer ontbrekende bestanden. Geen automatische hervatting. |
| Toevoegen geblokkeerd | Herstel de installatie of openstaande intrekking. |
| Intrekkingen nog niet verwerkt | Herstel de oorzaak; gebruik 6, of eerst 2 als intrekken zelf mislukte. |
| Geen leesbare configuratie | Gebruik sudo; controleer of installatie is afgerond. |
| Dienst niet actief | Lees het servicelog; niet blind opnieuw installeren. |
| Verbinding mislukt | Controleer adres, protocol/poort, router, providerfirewall en clientlog. |
| Verbonden zonder internet | Controleer forwarding, firewall en DNS. |
| Verwijderen mislukt | Onderdelen kunnen al verwijderd zijn. Bewaar de back-up en beoordeel de fout. |

Statusbestanden bewaken onvoltooid werk:

- /etc/openvpn/.sosaklingo-install-incomplete
- /etc/openvpn/server/.crl-update-pending

Verwijder deze niet zomaar om een blokkade te omzeilen. Zonder server.conf blokkeert het script herinstallatie als een installatiemarkering of bestaande Easy-RSA-map aanwezig is. Diagnose kan vroeg stoppen als vereiste bestanden ontbreken.

Een DNS-waarschuwing met de VPN uit bewijst niet dat deze installer de oorzaak is. Vergelijk met en zonder actieve VPN. --diagnose voert zelf geen lektest uit.

## 8. Back-up, bijwerken en verwijderen

Back-ups staan in /var/backups/openvpn-sosaklingo/. Ze bevatten /etc/openvpn en sleutels. Ze zijn afgeschermd met bestandsrechten, **niet versleuteld**. Profielen buiten /etc/openvpn worden niet automatisch meegenomen. Pakketten, firewallregels en externe instellingen worden niet volledig bewaard.

Er is geen automatische terugzetfunctie of volledige rollback. Lees [Migratie en herstel](../MIGRATION.md) voor handmatig herstel.

Download voor een nieuw installerbestand opnieuw volgens stap 2. Dit wijzigt **geen** bestaande serverconfiguratie, profielen, certificaten of pakketten. Systeem- en OpenVPN-pakketupdates verlopen via het pakketbeheer van je distributie.

Optie 3 verwijdert het OpenVPN-pakket en de beheerde servermap, en probeert bijbehorende regels en diensten op te ruimen. Andere toepassingen die hetzelfde pakket gebruiken kunnen hierdoor geraakt worden. Back-ups en elders opgeslagen profielen blijven bestaan. Router- en providerregels worden niet automatisch verwijderd. Eerdere systeeminstellingen worden niet gegarandeerd volledig hersteld.

## 9. Opdrachtopties en tests

Gebruik één actieoptie per opdracht. Bij meerdere actieopties gebruikt deze versie de laatste.

| Optie | Functie |
| --- | --- |
| --help, -h | Uitleg |
| --version | Versielabel en upstream-revisie; geen uniek label per commit |
| --lang nl/en, --lang=nl/en, -l nl/en | Taal; vervang nl/en door nl of en |
| --nl, --en | Korte taalkeuze |
| --preview | Installatiestappen bekijken |
| --check | Alleen-lezen basiscontrole |
| --port-demo | Poortmenu proberen |
| --cipher-demo | Versleutelingsmenu proberen |
| --self-test | Invoervalidatie testen |
| --diagnose | Server bekijken; gebruik sudo voor afgeschermde bestanden |

Voor ontwikkelaars met de volledige repository:

```bash
bash -n openvpn-install.sh
bash tests/test_installer.sh
```

Deze tests installeren geen echte VPN. Zie [Beveiliging](../SECURITY.md) en [Wijzigingen](../CHANGELOG.md).
