# Migratie en herstel / Migration and recovery

[Startpagina / Home](README.md) · [Nederlands](docs/HANDLEIDING-NL.md) · [English](docs/MANUAL-EN.md)

## Nederlands

### Oude installatie uit 2015

Gebruik dit script niet als automatische upgrade voor een oude VPN-server. De oude indeling gebruikt /etc/openvpn/server.conf; deze versie gebruikt /etc/openvpn/server/server.conf en openvpn-server@server.service. Als alleen de oude configuratie bestaat, weigert het script installatie.

1. Leg Linux-/OpenVPN-versie, routes, DNS, firewallregels, services en gebruikte certificaten vast.
2. Maak en controleer een afzonderlijke back-up van configuratie, sleutels, clientprofielen, forwardinginstellingen en services. Versleutel een kopie die je extern bewaart.
3. Regel consoletoegang buiten de VPN.
4. Test een nieuwe installatie op een aparte VM.
5. Plan omschakeling, nieuwe profielen/certificaten waar nodig, onderhoudstijd en terugkeer naar de oude server.

De code in legacy-2015 is een historisch naslagwerk, geen aanbevolen installer voor een moderne server.

### Onvolledige moderne installatie

Het script zet vóór installatieveranderingen /etc/openvpn/.sosaklingo-install-incomplete. De markering wordt pas na de laatste controles en profieluitvoer verwijderd.

Zonder server.conf, maar met deze markering of een Easy-RSA-map, wordt opnieuw installeren geblokkeerd om sleutels te bewaren. Met een serverconfiguratie maar ontbrekende vereiste bestanden of een markering, is gebruikers toevoegen geblokkeerd.

Bewaar de foutmelding, gebruik --diagnose en lees het servicelog. **Er is geen automatische hervatting.** Verwijder geen markering of PKI-map om de controle te omzeilen. Handmatig herstel hangt af van de mislukte stap; alleen aanwezige bestanden bewijzen nog niet dat de firewall en VPN werken.

### Mislukte intrekking

/etc/openvpn/server/.crl-update-pending bewaart welke intrekking nog verwerkt moet worden. Herstel de oorzaak en kies menuoptie 6. Als het certificaat nog niet ingetrokken is, gebruik eerst optie 2. De oude CRL blijft beschikbaar tot de nieuwe volledig is geplaatst. Optie 6 repareert geen installatie, firewall of alle lokale clientbestandopruiming.

### Back-up terugzetten

Automatische back-ups staan in /var/backups/openvpn-sosaklingo/ en zijn tar.gz-archieven met /etc/openvpn. Ze zijn alleen via bestandsrechten afgeschermd, niet versleuteld.

Er is geen automatische restore-opdracht. Controleer het archief eerst in een aparte, afgeschermde map of test-VM. Vergelijk configuratie en rechten; plan daarna herstel met consoletoegang. Blind terugzetten op een actieve server kan instellingen overschrijven en ingetrokken certificaten opnieuw geldig maken als een oude intrekkingslijst wordt teruggezet.

Back-ups bevatten geen volledige pakket-, firewall- of systeemstatus en missen elders opgeslagen clientprofielen. Een volledige rollback vereist die informatie afzonderlijk. Test na herstel verbinding, DNS, IPv6 en intrekkingen opnieuw.

### Bijwerken versus migreren

Een nieuw openvpn-install.sh-bestand downloaden vervangt alleen het hulpmiddel. Het herschrijft geen bestaande serverinstellingen, voert geen certificaatrotatie uit en installeert geen pakketupdates. Versleuteling wijzigen en oude servers migreren zijn afzonderlijke beheerwerkzaamheden.

## English

### Legacy 2015 installation

Do not use this script as an automatic upgrade for an old VPN server. The legacy layout uses /etc/openvpn/server.conf; this version uses /etc/openvpn/server/server.conf and openvpn-server@server.service. If only the old configuration exists, installation is refused.

1. Record Linux/OpenVPN versions, routes, DNS, firewall rules, services and certificates.
2. Make and verify a separate backup of configuration, keys, client profiles, forwarding settings and services. Encrypt any externally stored copy.
3. Arrange console access independent of the VPN.
4. Test a new installation on a separate VM.
5. Plan cutover, new profiles/certificates where needed, maintenance time and return to the old server.

The legacy-2015 branch is historical reference, not a recommended installer for a modern server.

### Incomplete modern installation

Before installation changes, the script creates /etc/openvpn/.sosaklingo-install-incomplete. It removes that marker only after final checks and profile export.

Without server.conf but with this marker or an Easy-RSA directory, reinstallation is blocked to preserve keys. With server configuration but missing required files or an installation marker, adding clients is blocked.

Keep the error message, use --diagnose and read the service log. **There is no automatic resume.** Do not delete the marker or PKI directory to bypass checks. Manual recovery depends on the failed step; file presence alone does not prove the firewall and VPN work.

### Failed revocation

/etc/openvpn/server/.crl-update-pending records the revocation awaiting completion. Fix the cause and choose menu option 6. If the certificate was not revoked, use option 2 first. The old CRL remains available until its replacement is fully published. Option 6 does not repair installation, firewall or all local client-file cleanup.

### Restoring backups

Automatic backups are tar.gz archives of /etc/openvpn in /var/backups/openvpn-sosaklingo/. File permissions restrict access; archives are not encrypted.

There is no automatic restore command. Inspect an archive in a separate restricted directory or test VM first. Compare configuration and permissions, then plan restoration with console access. Blind restoration on a running server can overwrite settings and re-enable revoked certificates if an older revocation list is restored.

Backups do not include complete package, firewall or system state and omit client profiles stored elsewhere. Full rollback needs that information separately. Retest connectivity, DNS, IPv6 and revocations after restoration.

### Updating versus migration

Downloading a new openvpn-install.sh only replaces the tool. It does not rewrite existing server settings, rotate certificates or install package updates. Changing encryption and migrating old servers are separate administration tasks.
