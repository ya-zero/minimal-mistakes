---
title: "Мониторинг ospf соседей демона ospfd по snmp "
date: 2019-03-22 00:52:51 +0000
categories:
  - snmp
tags:
  - quagga frrouting snmp agentx
---

в snmpd.conf добавил (если нужно весь скину.)
```bash
agentAddress  udp:127.0.0.1:161
agentXSocket    tcp:localhost:705
master agentx
```


скачал и собрал netsnmp и собрал
```bash
./configure --enable-snmp
```

поставил пакет 
```bash
dpkg -i  ./frr-snmp_6.0.2-0.deb9u1_amd64.deb 
по истории вижу что делал :
modprobe frr-snmp
modprobe ospfd-snmpd
modprobe ospfd-snmp
```
но сейчас работает без них , может делал до того как прописал -M snmp



в daemons изменил на
```bash
ospfd_options="  -A 127.0.0.1 -M  snmp"
```
через #conf t прописал
```bash
agentx (если snmp frr не поддерживает, то не даст прописать )
```

```bash
snmpwalk -c public -v1 localhost 1.3.6.1.2.1.14.7  смотреть соседей 
```
http://cric.grenoble.cnrs.fr/Administrateurs/Outils/MIBS/?oid=1.3.6.1.2.1.14

```bash
lsof  -i -n -P | grep 705
snmpd       865 Debian-snmp   11u  IPv4 93698052      0t0  TCP 127.0.0.1:705 (LISTEN)
snmpd       865 Debian-snmp   12u  IPv4 93698066      0t0  TCP 127.0.0.1:705->127.0.0.1:51502 (ESTABLISHED)
ospfd     14290         frr   19u  IPv4 93693088      0t0  TCP 127.0.0.1:51502->127.0.0.1:705 (ESTABLISHED)
```
