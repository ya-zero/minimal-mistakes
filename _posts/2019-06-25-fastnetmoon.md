---
title: "fastnetmon exabgp blackhole to rt and retn  "
date: 2019-06-25 09:52:51 +0000
categories:
  - fastnetmon
  - bgp
  - blackhole
  - exabgp
sidebar:
  - title: "bgp blackhole"
---


документация по проекту  https://fastnetmon.com/docs/exabgp_integration/

Устанвливаем необходимый софт. Согласно документации  добавляем в fastnetmon.conf
```bash
exabgp = on
exabgp_command_pipe = /var/run/exabgp.cmd
# сами назначаем community
exabgp_community = 65002:555
exabgp_next_hop = 192.168.0.43
exabgp_announce_host = on
```
Как протестировать анонсы :
добавление адреса:
```bash
echo "announce route 10.10.10.123/32 next-hop 10.0.3.114 community 65002:555" > /var/run/exabgp.cmd
```
удаление адреса:
echo "withdraw route 10.10.10.123/32" > /var/run/exabgp.cmd


Что я прописывал на стороне шлюза:
```bash
router bgp 65002
bgp confederation identifier 43465
neighbor 192.168.0.43 remote-as 65002
 address-family ipv4 unicast
  # 
  neighbor 192.168.0.43 soft-reconfiguration inbound
  #запрещаем анонс на fastnetmon
  neighbor 192.168.0.43 route-map rmp.AS65002-out out
  #retn
  neighbor 87.245.23x.1xx route-map map-AS9002_out out
  #rt
  neighbor 188.128.4x.2xx route-map map-AS12389_out out

# хз как правильно , но блокируем анонсы со шлюза в сторону fastnetmon, т.к. ненужны они там.
ip prefix-list prl.ALL seq 10 permit 0.0.0.0/0 le 32
route-map rmp.AS65002-out deny 10
 match ip address prefix-list prl.ALL

# создаем community list  для выбора маршрутов который прилетают с fastnetmon
ip community-list 10 permit 65002:555

# route map для retn   permit 90  до основного анонса
route-map map-AS9002_out permit 90
 match community 10
 set community 9002:666
# основной route-map retn
route-map map-AS9002_out permit 100
 description match out prefix
 match ip address prefix-list reinfokom
 set as-path prepend 43465
 set community 9002:65533 additive
# route map для rt   permit 90  до основного анонса
route-map map-AS12389_out permit 90
 match community 10
 set community 12389:55555
# основной route-map rt
!
route-map map-AS12389_out permit 100
 description match out prefix
 match ip address prefix-list reinfokom
 set as-path prepend 43465
 set community 12389:6991 additive
```

проверям.

```bash
sh ip bgp route-map map-AS12389_out
BGP table version is 21656955, local router ID is 195.178.23.254, vrf id 0
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 91.197.76.0/24   0.0.0.0                  0         32768 i
*> 91.197.77.0/24   0.0.0.0                  0         32768 i
*> 91.197.78.0/24   0.0.0.0                  0         32768 i
*> 91.197.79.0/24   0.0.0.0                  0         32768 i
*> 195.178.22.0/24  0.0.0.0                  0         32768 i
*> 195.178.23.0/24  0.0.0.0                  0         32768 i
*>i195.178.23.1/32  192.168.0.43                  100      0 i
```
```bash
sh ip bgp 195.178.23.1
BGP routing table entry for 195.178.23.1/32
Paths: (1 available, best #1, table Default-IP-Routing-Table)
  Advertised to non peer-group peers:
  87.245.238.136 188.128.49.221
  Local
    192.168.0.43 from 192.168.0.43 (192.168.0.43)
      Origin IGP, localpref 100, valid, confed-internal, best
      Community: 65002:555
      AddPath ID: RX 0, TX 13980539
      Last update: Tue Jun 25 15:05:39 2019

sh ip bgp neighbors 188.128.49.221 advertised-routes 
BGP table version is 21660769, local router ID is 195.178.23.254, vrf id 0
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 91.197.76.0/24   0.0.0.0                  0         32768 43465 i
*> 91.197.77.0/24   0.0.0.0                  0         32768 43465 i
*> 91.197.78.0/24   0.0.0.0                  0         32768 43465 i
*> 91.197.79.0/24   0.0.0.0                  0         32768 43465 i
*> 195.178.22.0/24  0.0.0.0                  0         32768 43465 i
*> 195.178.23.0/24  0.0.0.0                  0         32768 43465 i
*> 195.178.23.1/32  0.0.0.0                       100      0 i
```
заходим на http://lg.ip.rt.ru/

```bash
195.178.23.1/32    unreachable [sr2 15:12:28 from 217.107.65.1] * (100/-) [AS43465i]
	Type: BGP unicast univ
	BGP.origin: IGP
	BGP.as_path: 43465
	BGP.next_hop: 192.0.2.1
	BGP.med: 0
	BGP.local_pref: 850
	BGP.community: (12389,1) (12389,1100) (12389,1105) (12389,1231) (12389,55555) (65535,65281)
	BGP.originator_id: 95.167.89.49
	BGP.cluster_list: 95.167.88.79 95.167.88.49 213.59.207.197 81.177.113.79
```
