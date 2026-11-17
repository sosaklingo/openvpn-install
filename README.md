# OpenVPN road warrior installer

## Nederlands

Deze handleiding hoort bij het historische [Bash-script](openvpn-install.sh) op `master`. De [moderne installer in PR #1](https://github.com/sosaklingo/openvpn-install/pull/1) heeft een eigen handleiding.

### Controleer eerst je systeem

Het script vereist root en `/dev/net/tun`. Het herkent Debian/Ubuntu en CentOS via releasebestanden en weigert CentOS 5. Die detectie bevestigt geen compatibiliteit met een specifieke huidige versie. Het script gebruikt onder meer `iptables`, `rc.local` en, bij systemd, `openvpn@server.service`. Server en client gebruiken IPv4, UDP (standaardpoort 1194), `comp-lzo` en `cipher AES-256-CBC`. Controleer of je server en client deze configuratie ondersteunen.

### Downloaden en bekijken

Gebruik de opdrachten hieronder in een lege map als gewone gebruiker. De HTTPS-link verwijst naar een vaste versie in deze repository. Bekijk het hele script voordat je het rootrechten geeft. Stop bij een download- of certificaatfout.

```sh
wget -O openvpn-install.sh https://raw.githubusercontent.com/sosaklingo/openvpn-install/18b7ffc1e6219abf6aec7607ab9f4f2f75fd482b/openvpn-install.sh && less openvpn-install.sh
```

### Vóór uitvoering

- Test eerst op een aparte VM met consoletoegang. Het script installeert pakketten, schakelt IPv4-forwarding in en wijzigt NAT- en firewallregels.
- Maak een back-up van `/etc/openvpn` en je netwerkinstellingen. Bij een nieuwe installatie verwijdert het script een bestaande map `/etc/openvpn/easy-rsa/`. Het downloadt Easy-RSA 3.0.1 en pakt het archief uit zonder de checksum of handtekening te controleren.
- Na beoordeling kun je in de VM als root `bash openvpn-install.sh` uitvoeren. Het gegenereerde `.ovpn`-profiel bevat de privésleutel van de client zonder wachtwoord. Bewaar het privé en draag het beveiligd over.
- Bij een volgende start verschijnt het beheermenu als `/etc/openvpn/server.conf` bestaat. Je kunt een client aanmaken, een certificaat intrekken of OpenVPN verwijderen. Na bevestiging verwijdert de laatste optie de **hele map** `/etc/openvpn`.

## English

This guide covers the historical [Bash script](openvpn-install.sh) on `master`. The [modern installer proposed in PR #1](https://github.com/sosaklingo/openvpn-install/pull/1) has its own guide.

### Check your system

The script requires root and `/dev/net/tun`. It recognizes Debian/Ubuntu and CentOS through release files and rejects CentOS 5. Detection alone does not establish compatibility with a particular current release. It relies on `iptables`, `rc.local` and, on the systemd path, `openvpn@server.service`. The server and client configurations use IPv4, UDP (default port 1194), `comp-lzo` and `cipher AES-256-CBC`. Check that your server and client support these settings.

### Download and review

Run the `wget` command above as a regular user in an empty directory. It downloads a fixed revision from this repository over HTTPS and opens it for review. Read the entire script before granting root privileges. Stop if the download or certificate check fails.

### Before running

- Test in a separate VM with console access. The script installs packages, enables IPv4 forwarding and changes NAT and firewall rules.
- Back up `/etc/openvpn` and your network settings. A fresh install deletes any existing `/etc/openvpn/easy-rsa/` directory. The script downloads Easy-RSA 3.0.1 and extracts it without verifying a checksum or signature.
- After review, run `bash openvpn-install.sh` as root in the VM. The generated `.ovpn` profile contains the client's passwordless private key. Store it privately and transfer it securely.
- Running the script again opens the management menu if `/etc/openvpn/server.conf` exists. You can add a client, revoke a certificate or uninstall OpenVPN. Confirming uninstall deletes the **entire** `/etc/openvpn` directory.
