---
title: "fastnetmon blackhole "
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

```bash
echo "withdraw route 10.10.10.123/32" > /var/run/exabgp.cmd
```

Что я прописывал на стороне шлюза:

```bash
router bgp 65002
bgp confederation identifier 43465
neighbor 192.168.0.43 remote-as 65002
 address-family ipv4 unicast
  network 91.197.7x.0/22
  network 91.197.7x.0/24
  network 91.197.7x.0/24
  network 91.197.7x.0/24
  network 91.197.7x.0/24
  network 195.178.2x.0/23
  network 195.178.2x.0/24
  network 195.178.2x.0/24

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

проверям.  дописав route-map мы свормировали новое update сообщение помимо /24 сетей, c другими path attributes для адрсеа 195.178.23.1/24  
что видно в wireshark


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
```

```bash
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

P.S.  example ddos attack
```console
IP: 195.178.22.106
Attack type: udp_flood
Initial attack power: 37753 packets per second
Peak attack power: 37753 packets per second
Attack direction: incoming
Attack protocol: udp
Total incoming traffic: 502 mbps
Total outgoing traffic: 0 mbps
Total incoming pps: 37753 packet
UDP flows: 4204
195.178.22.106:46 < 109.245.238.121:53 2247 bytes 1 packets
195.178.22.106:222 < 177.184.88.2:53 2230 bytes 1 packets
195.178.22.106:306 < 179.108.187.10:53 34298 bytes 11 packets
195.178.22.106:306 < 191.91.240.86:53 17232 bytes 12 packets
195.178.22.106:306 < 148.63.75.116:53 31458 bytes 14 packets
195.178.22.106:306 < 177.200.83.132:53 24717 bytes 11 packets
195.178.22.106:306 < 24.196.254.136:53 33594 bytes 11 packets
195.178.22.106:306 < 59.124.30.190:53 8640 bytes 9 packets
195.178.22.106:306 < 103.111.57.210:53 24717 bytes 11 packets
195.178.22.106:306 < 95.141.128.216:53 9927 bytes 9 packets
195.178.22.106:733 < 94.199.98.47:53 13233 bytes 11 packets
195.178.22.106:733 < 186.194.108.69:53 12480 bytes 13 packets
195.178.22.106:733 < 1.160.225.78:53 18668 bytes 13 packets
195.178.22.106:733 < 166.253.145.81:53 24717 bytes 11 packets
195.178.22.106:733 < 2.188.36.129:53 16394 bytes 14 packets
 
 
exabgp: 16996  reactor       Performing dynamic route update
exabgp: 16996  reactor       Updated peers dynamic routes successfully
exabgp: 16996  processes     Command from process service-dynamic : withdraw route 195.178.23.1/32
exabgp: 16996  reactor       Route removed : 195.178.23.1/32 next-hop 0.0.0.0
exabgp: 16996  reactor       Performing dynamic route update
exabgp: 16996  reactor       Updated peers dynamic routes successfully
exabgp: 16996  processes     Command from process service-dynamic : announce route 195.178.22.106/32 next-hop 192.168.0.43 community 65002:555
exabgp: 16996  reactor       Route added to neighbor 192.168.0.36 local-ip 192.168.0.43 local-as 65002 peer-as 65002 router-id 192.168.0.43 family-allowed in-open : 195.178.22.106/32 next-hop 192.168.0.43 community 65002:555
exabgp: 16996  reactor       Performing dynamic route update
exabgp: 16996  reactor       Updated peers dynamic routes successfully
exabgp: 16996  processes     Command from process service-dynamic : withdraw route 195.178.22.106/32 next-hop 192.168.0.43
exabgp: 16996  reactor       Route removed : 195.178.22.106/32 next-hop 192.168.0.43
exabgp: 16996  reactor       Performing dynamic route update
exabgp: 16996  reactor       Updated peers dynamic routes successfully
```
<!-- Yandex.Metrika counter --> <script type="text/javascript" > (function(m,e,t,r,i,k,a){m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)}; m[i].l=1*new Date();k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)}) (window, document, "script", "https://mc.yandex.ru/metrika/tag.js", "ym"); ym(53515717, "init", { clickmap:true, trackLinks:true, accurateTrackBounce:true, webvisor:true }); </script> <noscript><div><img src="https://mc.yandex.ru/watch/53515717" style="position:absolute; left:-9999px;" alt="" /></div></noscript> <!-- /Yandex.Metrika counter -->
