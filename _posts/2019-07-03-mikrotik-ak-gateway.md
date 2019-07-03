---
title: "Настройка абонентского комлекта в качестве роутера, с аторизацией оп PPPoE."
date: 2019-07-03 00:52:51 +0000
categories:
  - mikrotik
  - pppoe
  - nat
  sidebar:
   - title: "mikrotik cpe gateway"
---

Убираем ether порт из бриджа , из плюсов проблемы с ether портом  такие как заворот и наличие broadcast не будут распостроняться по сети.
```bash
/interface bridge port
add bridge=br_vl375 disabled=yes interface=ether1
```
Настройка dhcp на CPE

Вешаем адрес на интерфейс
```bash
/ip address
add address=172.16.0.1/24 interface=ether1 network=172.16.0.0
```

Создаем диапазон из которого брать адреса  для выдачи
```bash
/ip pool
add name=dhcp_pool0 ranges=172.16.0.2-172.16.0.254
```
Вешаем dhcp server на ether1 
```bash
/ip dhcp-server
add address-pool=dhcp_pool0 disabled=no interface=ether1 name=dhcp
```
Указываем из какой сети выдавать
```bash
/ip dhcp-server network
add address=172.16.0.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=172.16.0.1
```
Создаем pppoe клиента  
```bash
/interface pppoe-client
add add-default-route=yes disabled=no interface=br_vl375 name=pppoe-out1 password=admin_test user=admin_test
```
Добавили правило для nat трансляции адресов
```bash
/ip firewall nat
add action=masquerade chain=srcnat out-interface=pppoe-out1 src-address=172.16.0.0/24
```
Вариант когда абоненту нужно выдать белый :
1) оставить pppoe
2)  сделать src-nat dst-nat , либо привязать клиента как make static , либо ограничить pool
```bash
/ip pool
add name=dhcp_pool0 ranges=172.16.0.254
/ip firewall nat
add action=dst-nat chain=dstnat dst-address=91.1.1.1 in-interface=pppoe-out1 to-addresses=172.16.0.254
add action=src-nat chain=srcnat out-interface=pppoe-out1 src-address=172.16.0.0/24 to-addresses=91.1.1.1.1
```

P.S. также можно настроить что dhcp запрос летит по сети до сектора, и выдавать адреса по opt 82.