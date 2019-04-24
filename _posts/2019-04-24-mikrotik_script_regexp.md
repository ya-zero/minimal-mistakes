---
title: "mikrotik script regexp"
date: 2019-03-22 00:52:51 +0000
categories:
  - mikrotik
tags:
  - mikrotik,script,regexp
---
 источники:
 - https://wiki.mikrotik.com/wiki/Manual:Regular_Expressions
 - http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html

нужно было распарсить порты в бридже и отключить только "ether."  для экранирования применяют \,  но тут нужно двойной. 

```bash 
root@accel-ppp] > /interface bridge port print                                                                          
Flags: X - disabled, I - inactive, D - dynamic, H - hw-offload 
 #     INTERFACE                                     BRIDGE                                     HW  PVID PRIORITY  PATH-COST INTERNAL-PATH-COST    HORIZON
 0     eoip_to_192.168.30.254                        br_vl29                                           1     0x80         10                 10       none
 1     wlan1.29                                      br_vl29                                           1     0x80         10                 10       none
 2 XI   ;;; 11
       ether.420.PPPoE                               br_vl_PPPoE                                       1     0x80         10                 10       none
 3     wlan1.375                                     br_vl_PPPoE                                       1     0x80         10                 10       none
 4     wlan1.606                                     br_vl606                                          1     0x80         10                 10       none
 5     ether1.606                                    br_vl606                                          1     0x80         10                 10       none
 6 I   wds--shilkov.375                              br_vl_PPPoE                                       1     0x80         10                 10       none
 7 I   wds--shilkov.29                               br_vl29                                           1     0x80         10                 10       none
 8     ether1.4000.222                               br_vl_PPPoE   
```

```bash
/interface bridge port set comment="11" [ find bridge =br_vl_PPPoE interface ~ "ether\\."]
```
