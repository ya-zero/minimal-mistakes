---
title: "Lldp linux в поисках линка"
date: 2019-10-26 00:00:51 +0000
categories:
  - linux
  - lldp
  - devops
  - автоматизация
---

 При удаленной работе на сервере к примеру когда ты находишся в дороге или  не за своим буком или что-то подобное. Понадобилось изменить  
параметры порта коммутатора куда подключен сервер, посмотреть mac адреса.   Схемы собой нет, даже есть если но она в Visio, хотя можно сконвертить с pdf 
Но схема может быть не актуальной.  какой выход ?
 - cтавим пакет lldpd 
 - запускаем lldpcli

```
show neighbors
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
Interface:    enp0s8, via: LLDP, RID: 1, Time: 0 day, 00:00:05
  Chassis:
    ChassisID:    mac 08:00:27:1b:5d:4a
    SysName:      debian
    SysDescr:     Debian GNU/Linux 10 (buster) Linux 4.19.0-6-amd64 #1 SMP Debian 4.19.67-2+deb10u1 (2019-09-20) x86_64
    MgmtIP:       10.0.2.15
    MgmtIP:       fe80::a00:27ff:fe1b:5d4a
    Capability:   Bridge, off
    Capability:   Router, off
    Capability:   Wlan, off
    Capability:   Station, on
  Port:
    PortID:       mac 08:00:27:43:c1:37
    PortDescr:    enp0s8
    TTL:          120

```


 
