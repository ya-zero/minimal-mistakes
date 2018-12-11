---
title: "Варианты уровня доступа"
date: 2018-12-11 09:00:00 +0000
categories:
  - network
tags:
  - access
sidebar:
  - title: "Сеть оператора"
    text: "Уровень доступа"
---


Устройство к которому мы подключаем абонента может быть как switch (dlink,snr,eltex,cisco,mt)  так и  абонентская точка доступа.

Расмотрим вариант когда мы подлючаем абонента к коммутатору

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








