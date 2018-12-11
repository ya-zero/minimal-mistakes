---
title: "ч2.Физическое подключение. Уровень доступа "
date: 2018-12-11 09:00:00 +0000
categories:
  - Network
tags:
  - Access
sidebar:
  - title: "Сеть оператора"
    text: "Уровень доступа"
---


Устройство к которому мы подключаем абонента может быть как switch (dlink,snr,eltex,cisco,mt)  так и  абонентская точка доступа.

<h3>Расмотрим вариант когда мы подлючаем абонента к коммутатору</h3>

ч1. Физическое подключение.

![]({{ site.baseurl }}/uploads/simple_network_access.png "уровень доступа")


Физическое подключение очень простое, обжали кабель и подключили:
- проверим link на коммутаторе:

```bash
DES-3010G:4#sh ports 8
Command: show ports 8

 Port    State/         Settings             Connection           Address 
         MDIX     Speed/Duplex/FlowCtrl  Speed/Duplex/FlowCtrl    Learning
 -----  --------  ---------------------  ---------------------    --------
 8      Enabled   Auto/Disabled          100M/Full/None           Enabled 
        Auto    
```
- проверим длинну кабеля и нет ли обрывов

```bash
DES-3010G:4#cable_diag ports 8
Command: cable_diag ports 8

 Perform Cable Diagnostics ...

 Port   Type      Link Status          Test Result          Cable Length (M)
 ----  -------  --------------  -------------------------  -----------------
  8      FE        Link Up       OK                                8
```
-  когда будет трафик можно посмотреть не растут ли ошибки на порту:

```bash
DES-3010G:4#show error ports 8
Command: show error ports 8

 Port number : 8    
                 RX Frames                                  TX Frames
                 ---------                                  ---------
 CRC Error       0                    Excessive Deferral    0        
 Undersize       0                    CRC Error             0        
 Oversize        0                    Late Collision        0        
 Fragment        0                    Excessive Collision   0        
 Jabber          0                    Single Collision      0        
 Drop Pkts       0                    Collision             0        

```

все тоже самое можно повторить и на другом вендоре . к примеру на MT

```bash
[mgmt@MikroTik] > interface ethernet print 
Flags: X - disabled, R - running, S - slave 
 #    NAME               MTU MAC-ADDRESS       ARP             SWITCH            
 0 RS ;;; abon1
      ether1            1500 11:11:11:00:00:00 enabled         switch1           
 
```
мы видим что интерфейс в состоянии **R** активен, и **S** является **Slave** значит он в bridge

так можно проверить есть ли проблемы с портом через **cable_test**:
```bash
[admin@OFFICE] > interface ethernet cable-test ether2
    name: ether2-myPS
  status: link-ok
```
если  есть какая-то проблема с парами то вывод будет  вот таким:
```bash
[admin@OFFICE] > interface ethernet cable-test ether3-WIFI 
         name: ether3-WIFI
       status: no-link
  cable-pairs: open:0,open:0,open:0,open:0
```

проверим счетки на порту , в том числе и ошибки
```bash
[admin@OFFICE] > interface ethernet print stats-detail 
Flags: X - disabled, R - running, S - slave 
 0 RS ;;; okkkk
      name="ether1-WAN" driver-rx-byte=4 047 778 296 driver-rx-packet=8 803 882 
      driver-tx-byte=699 139 710 driver-tx-packet=2 272 196 
      rx-bytes=4 088 785 855 rx-too-short=0 rx-64=3 730 311 rx-65-127=2 005 089 
      rx-128-255=518 637 rx-256-511=167 531 rx-512-1023=42 450 
      rx-1024-1518=690 482 rx-1519-max=1 653 182 rx-too-long=0 
      rx-broadcast=4 810 926 rx-pause=0 rx-multicast=984 933 rx-fcs-error=0 
      rx-align-error=0 rx-fragment=0 rx-overflow=0 tx-bytes=708 857 177 
      tx-64=80 681 tx-65-127=1 660 919 tx-128-255=117 564 tx-256-511=19 804 
      tx-512-1023=33 678 tx-1024-1518=344 125 tx-1519-max=15 407 tx-too-long=0 
      tx-broadcast=151 641 tx-pause=0 tx-multicast=143 321 tx-underrun=0 
      tx-collision=0 tx-excessive-collision=0 tx-multiple-collision=0 
      tx-single-collision=0 tx-excessive-deferred=0 tx-deferred=0 
      tx-late-collision=0 tx-queue0-packet=2 268 633 tx-queue0-byte=708 289 977 
      tx-queue1-packet=3 545 tx-queue1-byte=567 200 tx-queue2-packet=0 
      tx-queue2-byte=0 tx-queue3-packet=0 tx-queue3-byte=0 tx-queue4-packet=0 
      tx-queue4-byte=0 tx-queue5-packet=0 tx-queue5-byte=0 tx-queue6-packet=0 
      tx-queue6-byte=0 tx-queue7-packet=0 tx-queue7-byte=0 
      tx-all-queue-drop-packet=0 tx-all-queue-drop-byte=0 
      tx-queue-custom0-drop-packet=0 tx-queue-custom0-drop-byte=0 
      tx-queue-custom1-drop-packet=0 tx-queue-custom1-drop-byte=0 
      policy-drop-packet=0 custom-drop-packet=0 current-learned=0 
```



После физ. подключения и наличия трафика на коммутаторе будет изучен mac address на порту (а можно сделать и привязку к mac/port , создав статичскую запись)
```
DES-3010G:4#sh fdb port 8
Command: show fdb port 8

VID   VLAN Name         MAC Address        Port    Type  
----  ----------------  -----------------  ----  ---------
2     vlan2             00-11-95-11-01-84    8    Dynamic
```

на MT 
L: mac адрес порта  
D: изученный адрес на порту 1 (id vlan2)
```bash 
[admin@OFFICE] > interface bridge host print 
Flags: X - disabled, I - invalid, D - dynamic, L - local, E - external 
 #       MAC-ADDRESS        VID ON-INTERFACE      BRIDGE     AGE                 
 0   DL  E4:8D:8C:81:3F:B9      br_DHCP           br_DHCP   
 1   D   00:18:51:02:66:01      ether1.2          br_vl2     24s                 
 2   D   00:18:51:02:67:01      ether1.2          br_vl2     25s 
```

