# Tests en praktijktestplan / Tests and live test plan

[Startpagina / Home](README.md) · [Beveiliging / Security](SECURITY.md)

## Nederlands

### Uitgevoerde automatische controles

Vanuit de repository:

```bash
bash -n openvpn-install.sh
bash tests/test_installer.sh
```

De tests controleren syntax, Nederlandse/Engelse menu's, poort- en versleutelingskeuzes, invoervalidatie, diagnose, profielexport en CRL-vervanging. Nagebootste fouten controleren behoud van oude bestanden, herstel na CRL-fouten, blokkering van onvolledige installatie en stoppen bij fouten tijdens verwijderen.

Er wordt geen echte VPN geïnstalleerd. Diensten, pakketbeheer en verschillende bestandsacties worden in fouttests nagebootst. Lees de uitvoer en [GitHub Actions](https://github.com/sosaklingo/openvpn-install/actions) voor de uitslag per commit.

### Nog uit te voeren: echte praktijktest

Alle onderstaande stappen zijn **nog niet bevestigd**, geen afgeronde resultaten.

- [ ] Noteer commit, OS-versie, OpenVPN-versie, clientversie en netwerkopstelling.
- [ ] Maak een schone test-VM en snapshot, met consoletoegang buiten de VPN.
- [ ] Installeer via het NL-menu; test het EN-menu afzonderlijk op een schone VM.
- [ ] Controleer dienststatus, gekozen poort/protocol en succesvolle profielimport.
- [ ] Verbind vanaf een extern netwerk; controleer internettoegang en openbaar IP.
- [ ] Test DNS en IPv6 met VPN aan en uit; leg uit welk verkeer via de tunnel hoort te gaan.
- [ ] Herstart de server en controleer dienst, firewall, verbinding en DNS opnieuw.
- [ ] Maak een tweede client; trek die in en controleer dat een nieuwe verbinding faalt.
- [ ] Test optie 6 op de test-VM, inclusief een gecontroleerde fout en herstel. Houd de oorspronkelijke back-up beschikbaar.
- [ ] Test verwijderen, back-upinspectie en eventuele handmatige terugzet op een wegwerp-VM.
- [ ] Herhaal voor iedere combinatie van distributie, protocol en client die je echt wilt ondersteunen.

Bewaar uitkomsten met datum en commit, zonder privésleutels of complete profielen. Een test van één combinatie bewijst geen werking op alle systemen.

## English

### Automated checks run

From the repository:

```bash
bash -n openvpn-install.sh
bash tests/test_installer.sh
```

Tests cover syntax, Dutch/English menus, port/encryption choices, input validation, diagnostics, profile export and CRL replacement. Injected failures check preservation of existing files, recovery after CRL failures, incomplete-installation protection and stopping on removal errors.

No real VPN is installed. Services, package management and several file operations are mocked in failure tests. Read the output and GitHub Actions for results per commit.

### Pending: real deployment test

Every step below is **unconfirmed**, not a completed result.

- [ ] Record commit, OS version, OpenVPN version, client version and network setup.
- [ ] Prepare a clean test VM and snapshot, with console access independent of the VPN.
- [ ] Install through the Dutch menu; test the English menu separately on a clean VM.
- [ ] Check service status, chosen port/protocol and successful profile import.
- [ ] Connect from an external network; check internet access and public IP.
- [ ] Test DNS and IPv6 with VPN on and off; define which traffic should use the tunnel.
- [ ] Reboot the server and recheck service, firewall, connection and DNS.
- [ ] Create a second client, revoke it and verify that a new connection fails.
- [ ] Test option 6 on the test VM, including a controlled failure and recovery. Retain the original backup.
- [ ] Test removal, backup inspection and any manual restore on a disposable VM.
- [ ] Repeat for each distribution, protocol and client combination you intend to support.

Record outcomes with date and commit, without private keys or complete profiles. One passing combination does not prove compatibility with all systems.
