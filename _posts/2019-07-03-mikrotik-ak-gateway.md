---
title: "Черновик: Настройка абонентского комлекта в качестве роутера, с авторизацией по PPPoE"
date: 2019-07-03 00:52:51 +0000
categories:
  - mikrotik
  - pppoe
  - nat
sidebar:
   - title: "mikrotik cpe gateway"
---

Убираем ether порт из бриджа. Из плюсов для абонента , ненужно настривать абон. роутер, можно подклбючить комп или бук. 
Для оператора, это уменьшение broadcast на сети,  в случае заваратора небудет шторма. 
```bash
/interface bridge port
add bridge=br_vl375 disabled=yes interface=ether1
```
***
Настройка dhcp на CPE

Вешаем адрес на интерфейс:
```sh
/ip address
add address=172.16.0.1/24 interface=ether1 network=172.16.0.0
```

Создаем диапазон из которого брать адреса  для выдачи:
```sh
/ip pool
add name=dhcp_pool0 ranges=172.16.0.2-172.16.0.254
```
Вешаем dhcp server на ether1:
```sh
/ip dhcp-server
add address-pool=dhcp_pool0 disabled=no interface=ether1 name=dhcp
```
Указываем из какой сети выдавать:
```sh
/ip dhcp-server network
add address=172.16.0.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=172.16.0.1
```
Создаем pppoe клиента  
```sh
/interface pppoe-client
add add-default-route=yes disabled=no interface=br_vl375 name=pppoe-out1 password=admin_test user=admin_test
```
Добавили правило для nat трансляции адресов:
```sh
/ip firewall nat
add action=masquerade chain=srcnat out-interface=pppoe-out1 src-address=172.16.0.0/24
```
Вариант когда абоненту нужно выдать белый :
 - 1) оставить pppoe
 - 2) сделать src-nat dst-nat , самого клиента  привязать как make static , либо ограничить pool
```sh
/ip pool
add name=dhcp_pool0 ranges=172.16.0.254
/ip firewall nat
add action=dst-nat chain=dstnat dst-address=91.1.1.1 in-interface=pppoe-out1 to-addresses=172.16.0.254
add action=src-nat chain=srcnat out-interface=pppoe-out1 src-address=172.16.0.254 to-addresses=91.1.1.1.1
```

P.S. также можно настроить dhcp  выше и  выдавать адреса по opt 82.
на mikrotik сервер не делал, но в качестве BRAS был accel-ppp.  В биллинг летит запрос по radius [accel-ppp](https://accel-ppp.org/forum/viewtopic.php?f=10&t=2260).


UPD.  скрипт для добавления в /system script имя pppoe_and_dhcp

для запуска лучше использовать /system script run pppoe_and_dhcp , так как есть хоть какойто уровень отладки скрипта.

```sh
:global  dfnether [/interface ethernet get [ find default-name="ether1"] name] ;
:global dhcppool; 
:set dhcppool "dhcp_ipoe";

:global dhcpserver;
:set dhcpserver "dhcp_ipoe_server";

:global pppoeclient;
:set pppoeclient "pppoe_client_int";

:global brpppoe;
:set brpppoe "br_vl375";


:put  $dfnether;
:put $dhcpserver;
:put $dhcppool;
:put $pppoeclient;
:put $brpppoe;
########################################################################
#disabled old configuration

#DHCP SERVER
/ip dhcp-server remove numbers=[find name=$dhcpserver]

# POOL
/ip pool remove numbers=[find name=$dhcppool];

#string 25 delete old PPPoE_Client
 /interface pppoe-client remove numbers=[find name=$pppoeclient]
#/interface pppoe-client remove $pppoeclient

#DHCP NETWORK remove
#/ip dhcp-server network remove numbers=0;
/ip dhcp-server network remove numbers=[find address="10.100.0.0/24"]

#######################################################################3

# del ether1 intreface fron bridge 
/interface bridge port set disabled=yes   numbers=[find interface ~ $dfnether] 

# disable address on ether1
/ip address set disabled=yes numbers=[find interface ~ $dfnether]

# add ip address to ether1
/ip address add address=10.100.0.1/24 interface=$dfnether network=10.100.0.0

#create pool
/ip pool add name=$dhcppool ranges=10.100.0.2-10.100.0.254

#create network for access
/ip dhcp-server network add address=10.100.0.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=10.100.0.1

#creade dhcp server
/ip dhcp-server add address-pool=$dhcppool disabled=no interface=$dfnether name=$dhcpserver


#create pppoe-clint
/interface pppoe-client add add-default-route=yes disabled=no interface=$brpppoe name=$pppoeclient password=admin_test user=admin_test

#create firewall nat rules 
/ip firewall nat add action=masquerade chain=srcnat out-interface=$pppoeclient  src-address=10.100.0.0/24

#change station bridge -> station
#/interface wireless set mode=station numbers=[find name ~"wlan"]
```
откат назад

```
:global  dfnether [/interface ethernet get [ find default-name="ether1"] name] ;
:global dhcppool; 
:set dhcppool "dhcp_ipoe";

:global dhcpserver;
:set dhcpserver "dhcp_ipoe_server";

:global pppoeclient;
:set pppoeclient "pppoe_client_int";

:global brpppoe;
:set brpppoe "br_vl375";

:put $dfnether;
:put $dhcpserver;
:put $dhcppool;
:put $pppoeclient;
:put $brpppoe;
########################################################################
#restore old configuration

#DHCP SERVER
/ip dhcp-server remove numbers=[find name=$dhcpserver]

# POOL
/ip pool remove numbers=[find name=$dhcppool];

#string 29 delete old PPPoE_Client
 /interface pppoe-client remove numbers=[find name=$pppoeclient]

#DHCP NETWORK remove
/ip dhcp-server network remove numbers=[find address="10.100.0.0/24"]

# disable address on ether1
/ip address set disabled=yes numbers=[find interface ~ $dfnether]

# restore ether1 intreface fron bridge 
/interface bridge port set disabled=no   numbers=[find interface ~ $dfnether] 

#remove firewall nat rules 
/ ip firewall nat remove [/ip firewall nat find]

#restore change station bridge -> station
/interface wireless set mode=station-bridge numbers=[find name ~"wlan"]

```

upd [sample script presentations](https://mum.mikrotik.com//presentations/RU16/presentation_3759_1475646696.pdf)

<!-- Yandex.Metrika counter --> <script type="text/javascript" > (function(m,e,t,r,i,k,a){m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)}; m[i].l=1*new Date();k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)}) (window, document, "script", "https://mc.yandex.ru/metrika/tag.js", "ym"); ym(53515717, "init", { clickmap:true, trackLinks:true, accurateTrackBounce:true, webvisor:true }); </script> <noscript><div><img src="https://mc.yandex.ru/watch/53515717" style="position:absolute; left:-9999px;" alt="" /></div></noscript> <!-- /Yandex.Metrika counter -->
