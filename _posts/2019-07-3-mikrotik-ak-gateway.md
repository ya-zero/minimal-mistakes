---
title: "Настройка абонентского комлекта в качестве роутера, с аторизацией оп PPPoE."
date: 2019-06-25 09:52:51 +0000
categories:
  - mikrotik
  - pppoe
  - nat
  sidebar:
  - title: "mikrotik cpe gateway"
---

### убираем ether порт из бриджа , из плюсов проблемы с ether портом  такие как заворот и наличие broadcast не будут распостроняться по сети.
/interface bridge port
add bridge=br_vl375 disabled=yes interface=ether1

##настройка dhcp на CPE

### вешаем адрес на интерфейс
/ip address
add address=172.16.0.1/24 interface=ether1 network=172.16.0.0

### создаем диапазон из которого брать адреса  для выдачи
/ip pool
add name=dhcp_pool0 ranges=172.16.0.2-172.16.0.254

### вешаем dhcp server на ether1 
/ip dhcp-server
add address-pool=dhcp_pool0 disabled=no interface=ether1 name=dhcp

###  указываем из какой сети выдавать
/ip dhcp-server network
add address=172.16.0.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=172.16.0.1

### создаем pppoe клиента  
/interface pppoe-client
add add-default-route=yes disabled=no interface=br_vl375 name=pppoe-out1 password=admin_test user=admin_test

### добавили правило для nat трансляции адресов
/ip firewall nat
add action=masquerade chain=srcnat out-interface=pppoe-out1 src-address=172.16.0.0/24

### вариант когда абоненту нужно выдать белый :
1) оставить pppoe
2)  сделать src-nat dst-nat , либо привязать клиента как make static , либо ограничить pool
/ip pool
add name=dhcp_pool0 ranges=172.16.0.254
/ip firewall nat
add action=dst-nat chain=dstnat dst-address=91.1.1.1 in-interface=pppoe-out1 to-addresses=172.16.0.254
add action=src-nat chain=srcnat out-interface=pppoe-out1 src-address=172.16.0.0/24 to-addresses=91.1.1.1.1


P.S. также можно настроить что dhcp запрос летит по сети до сектора, и выдавать адреса по opt 82.
