# Wijzigingen / Changelog

[Startpagina / Home](README.md)

## 2026-11-15 — documentatie / documentation

### Nederlands

- Volledige afzonderlijke handleidingen in Nederlands en Engels toegevoegd.
- README, beveiligingsinformatie en migratie/herstel bijgewerkt in beide talen.
- Alle zes beheeropties, opdrachtopties, downloaden, verbinden, back-ups, bijwerken en verwijderen beschreven.
- Grenzen van optie 6, onvolledige installaties en automatische tests expliciet gemaakt.
- Praktijktestplan toegevoegd; de stappen zijn nog niet als uitgevoerd gemarkeerd.
- Deze documentatiewijziging verandert de installatiecode niet.

### English

- Added separate complete Dutch and English manuals.
- Updated README, security and migration/recovery information in both languages.
- Documented all six management choices, command options, downloading, connection, backups, updates and removal.
- Clarified limits of option 6, incomplete installations and automated tests.
- Added a live test plan; its steps are not marked as completed.
- This documentation update does not change installer code.

## 2026-11-15 — foutafhandeling en herstel / failure handling and recovery

### Nederlands

- Firewalld-wijzigingen stoppen bij fouten; extra controles voor toevoegen en intrekken van clients.
- Profielen en CRL worden via een tijdelijk bestand vervangen, met behoud van de oude versie bij voorbereidende fouten.
- Gebruikersselectie voor intrekken aangescherpt; servercertificaat uitgesloten.
- Onvolledige installatie herkend; opnieuw installeren over bestaande PKI geblokkeerd.
- Openstaande intrekkingen bijgehouden; menuoptie 6 herstelt CRL-generatie/publicatie.
- Extra foutcontroles bij verwijderen van diensten, bestanden en pakketten.
- Tests met nagebootste fouten toegevoegd. Geen volledige rollback of automatische installatiehervatting.

### English

- Firewalld mutations stop on failure; additional checks for client creation and revocation.
- Profiles and CRL are replaced through temporary files, preserving existing versions on preparation failures.
- Tightened revocation selection and excluded the server certificate.
- Detect incomplete installations and block reinstallation over existing PKI.
- Track pending revocations; menu option 6 repairs CRL generation/publication.
- Additional checks for service, file and package removal.
- Added injected-failure tests. No full rollback or automatic installation resume.

## 2026-11 — modern-2026

### Nederlands

- Installer gebaseerd op Nyr/openvpn-install, revisie 7ff931a00c37a6806bd1fa8cb61bf3369d963e94.
- Moderne distributiecontroles en systemd-serverindeling.
- Eén Bash-bestand met Nederlandse/Engelse menu's en bevestiging vóór installatie.
- Poort- en versleutelingskeuze, IP-/hostnaam-/DNS-validatie.
- Easy-RSA 3.2.7 via HTTPS met SHA-256-controle; minimaal TLS 1.2 en tls-crypt.
- Afgeschermde configuratieback-ups, beperktere sleutelkopieën en bestandsrechten.
- Alleen-lezen help, versie, voorcontrole, menuvoorbeelden, diagnose en zelftest.
- Oude serverindeling wordt niet automatisch gemigreerd; MIT-licentie en bronvermelding behouden.

### English

- Based on Nyr/openvpn-install revision 7ff931a00c37a6806bd1fa8cb61bf3369d963e94.
- Modern distribution checks and systemd server layout.
- One Bash file with Dutch/English menus and confirmation before installation.
- Port/encryption choices and IP/hostname/DNS validation.
- Easy-RSA 3.2.7 over HTTPS with SHA-256 verification; minimum TLS 1.2 and tls-crypt.
- Restricted configuration backups, fewer private-key copies and restricted file permissions.
- Read-only help, version, preflight, menu demonstrations, diagnostics and self-test.
- No automatic legacy migration; preserved MIT license and attribution.

## 2015

Oorspronkelijke sosaklingo-fork en aanpassingen bewaard in de Git-geschiedenis en legacy-2015.  
Original sosaklingo fork and customization retained in Git history and legacy-2015.
