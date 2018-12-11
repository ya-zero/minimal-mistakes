---
title: " ч2.Конфигурирование. Уровень доступа "
date: 2018-12-11 09:00:00 +0000
categories:
  - network
tags:
  - access
sidebar:
  - title: "Сеть оператора"
    text: "Уровень доступа"
---

 Устройство к которому мы подключаем абонента может быть как switch (dlink,snr,eltex,cisco,mt) так и абонентская точка доступа.


 Способ организации доступа абонента в сеть провайдера (не веcь список)(коснемся вскольз, может быть опишу позже) 
- pppoe  
- ip static
- dhcp 
- sip

 Как довести канал до самого коммутатора и обеспечить его безопасность, об этом опишу подробнее.
- vlan per home
- vlan per user
- vlan menagment
- q-in-q
- voip vlan

 **Одна из классических схем**  настройки уровня доступа  это изолирование  управление коммутатора с помощью vlan  ,а отдельно vlans для  абонентов, каналов, voip.
  ![]({{ site.baseurl }}/uploads/simple_network_access_2.png "уровень доступа")
  
 Настроим вариант с 10 портовым коммутатором  когда :
  - управление в vlan id 10 name  mgmt 
  - абоненты в vlan 100 name home_10 c  1 по 8  порты.
  - на портах в сторону коммутатора агрегации/распределения мы прописываем vlan типа trunk  id 10, id 100
  - на портах в сторону абонента приписываем  только один vlan id  100 типа untagged (иногда называется access)
 
```bash 
config vlan default delete 1-10
create vlan mgmt tag 10
config vlan mgmt add tagged 9-10
create vlan home_10 tag 100
config vlan home_10 add untagged 1-8
create vlan home_10 tag 100
config vlan home_100 add tagged 9-10
```

После того как настроили vlan mgmt , назначим vlan управления для коммутатора и настроим ip 
```bash
config ipif System vlan mgmt ipaddress 192.168.0.10/24 state enable 
```
Укажим default route если мы будем заходить из другой подсети.
```bash
create iproute default 192.168.0.254 1
```

P.S здесь пока не хватает :
 - ограничение по mac на порту абонента
 - изоляции портов между абонентами
 - правил доступа на абонентских портах
 - нет синхронизаци по вермени
 - нет сервера логов
 - нет авторизации  по radius/tacascass
 

