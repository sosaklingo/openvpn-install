# Beveiliging / Security

[Startpagina / Home](README.md) · [Testplan / Test plan](TESTING.md)

## Nederlands

### Aanwezige maatregelen

- Minimaal TLS 1.2 en tls-crypt; keuzemenu met AES-GCM of ChaCha20-Poly1305 als ondersteund.
- Easy-RSA 3.2.7 via HTTPS met vastgezette SHA-256:
  308743bc9fe871b902d47dbe98d749daff3a05b27531684f02625ce7208d4598.
  Een afwijkend archief wordt niet uitgepakt. Deze controle beschermt niet tegen een kwaadaardige oorspronkelijke release.
- umask 077, beperkte rechten op sleutels, profielen en back-ups; geen extra CA-sleutelkopie in de servermap.
- Invoercontroles en extra stopcontroles voor pakketten, firewallwijzigingen, certificaatbeheer en verwijderen. Niet iedere uitvoerregel in de installer is volledig gecontroleerd.
- Nieuwe profielen en CRL worden via een tijdelijk bestand in dezelfde map geplaatst; de oude versie blijft staan als een voorbereidende stap faalt.
- Markeringen voor onvoltooide installatie/intrekking; hersteloptie 6 voor CRL-verwerking.
- Geen automatische migratie vanaf de oude serverindeling.

### Grenzen en beheerkeuzes

De CA-privésleutel blijft op de VPN-server. CA- en clientkeys worden zonder wachtwoord aangemaakt. De code gebruikt 3650 dagen voor server-/clientcertificaten en CRL-generatie; er is geen automatische rotatie of verversingsplanning. Dit is geen offline-CA- of hardware-sleuteloplossing.

Back-ups bevatten geheimen en zijn niet versleuteld. Publiceer geen sleutels, .ovpn-profielen of back-ups. Bij herstel kan een oude CRL eerdere intrekkingen ongedaan maken; controleer dit afzonderlijk.

Optie 6 herstelt CRL-verwerking, niet iedere mislukte stap. Het bewaren van een oude CRL betekent ook dat een nieuwe intrekking na een fout mogelijk nog niet wordt afgedwongen. De installer biedt geen aparte onmiddellijke disconnect van actieve clients.

Er is geen algemene kill switch of gegarandeerde DNS-/IPv6-lekbeveiliging op alle clients. --diagnose is alleen een basiscontrole. De server gebruikt subnet 10.8.0.0/24; controleer overlap. De firewallregels zijn geen uitgewerkt beleid voor clientisolatie.

Geen volledige rollback, automatische hervatting, live versleutelingsmigratie, TLS-1.3-only of tls-crypt-v2. Er is geen volledige beveiligingsaudit of bewezen productiegeschiktheid.

### Verantwoord testen en melden

Test op een aparte VM en volg TESTING.md. Houd OS en OpenVPN-pakketten bij via je distributie. Houd beheer bereikbaar buiten de VPN en beperk toegang tot sleutels.

Voor een beveiligingsmelding: gebruik een privérapportagekanaal als dat op GitHub beschikbaar is. Is dat niet beschikbaar, vraag de beheerder eerst om een privécontactmogelijkheid zonder gevoelige details openbaar te plaatsen. Deze repository belooft geen specifiek privékanaal, responstijd of beveiligings-SLA.

## English

### Implemented safeguards

- Minimum TLS 1.2 and tls-crypt; selection of AES-GCM or ChaCha20-Poly1305 when supported.
- Easy-RSA 3.2.7 over HTTPS with pinned SHA-256:
  308743bc9fe871b902d47dbe98d749daff3a05b27531684f02625ce7208d4598.
  A mismatching archive is not extracted. This does not protect against a malicious original release.
- umask 077 and restricted permissions on keys, profiles and backups; no extra CA private-key copy in the server directory.
- Input validation and additional failure checks for packages, firewall mutations, certificate management and removal. Not every installer operation is comprehensively checked.
- Profiles and CRL are staged in a temporary file in the same directory; the previous file remains if a preparation step fails.
- Incomplete-installation/revocation markers; option 6 for CRL recovery.
- No automatic migration from the legacy server layout.

### Limitations and administration choices

The CA private key remains on the VPN server. CA and client keys are generated without passwords. Code uses 3650 days for server/client certificates and CRL generation; there is no automatic rotation or refresh schedule. This is not an offline CA or hardware-key solution.

Backups contain secrets and are not encrypted. Never publish keys, .ovpn profiles or backups. Restoring an older CRL may undo previous revocations; check this separately.

Option 6 repairs CRL processing, not every failed step. Preserving an older CRL also means a new revocation may not yet be enforced after an error. The installer has no separate immediate disconnect function for active clients.

There is no general kill switch or guaranteed DNS/IPv6 leak protection across clients. --diagnose is only a basic check. The server uses 10.8.0.0/24; check for overlaps. Firewall rules are not a comprehensive client-isolation policy.

No full rollback, automatic resume, live encryption migration, TLS-1.3-only or tls-crypt-v2. No comprehensive security audit or proven production readiness is claimed.

### Testing and reporting

Use a separate VM and follow TESTING.md. Maintain OS and OpenVPN packages through your distribution. Keep management access independent of the VPN and restrict access to keys.

For a security report, use private GitHub reporting if available. Otherwise first ask the maintainer for a private contact method without publishing sensitive details. This repository does not promise a particular private channel, response time or security SLA.
