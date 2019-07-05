---
title: "Автоматизация выполнения задач на сетевом оборудовании CLI"
date: 2019-07-04 00:52:51 +0000
categories:
  - python
  - network
  - automation
  - cli
tags:
  - cisco,netmiko,python,snr,d-link,mikrotik,telnet,ssh,cli
---


Подборка скриптов для выполения автоматического конфигурирования оборудовнаия.

- очень понравилась система eNMS (https://github.com/afourmy/eNMS) осованный на pyNMS 
 - workflow - можно указать последовательсть выполнения задач
 - task - задачи котрые нужно выпонить на соборудовании
 - maps - карта сети. вообще бесплатных аналогов не встречал. 


Пример   генерации  конфига , который в дальнейшем можно отправить на обордование как комманды , 
может быть использован при подготовки оборудования перед установкой на сети.

[python examples code](https://github.com/ya-zero/ya-zero.github.io/tree/master/uploads/generate_config_example)


 Имея набор данных в формате yaml
```sh
zabbix: 192.168.0.20
radius_server: 172.20.103.206
radius_key: radius
ntp_server: 192.168.0.1
ip_switch: 192.168.2.227
intf_trunk: 9-10
vlan_trunk: 2;701
vlans:
 2: mgmt
701: sk_kanal
```
Мы подставляем в шаблон jinja2
  Базовый шаблон:

```
username admin privilege 15 password 0 rfm
!
clock timezone MSK add 3 0
!
logging {{zabbix}}
logging executed-commands enable
!
snmp-server enable
snmp-server security disable
snmp-server host {{zabbix}} v2c  public
snmp-server community ro 0 public
!
lldp enable
!
mtu 9000
!
loopback-detection interval-time 10 3
loopback-detection control-recovery timeout 600
loopback-detection trap enable
!
ntp enable
ntp server {{ntp_server}}
!
interface ethernet1/0/{{intf_trunk}}
switchport mode trunk
switchport trunk allowed vlan {{ vlan_trunk }}
loopback-detection specified-vlan 1-4094
loopback-detection control block
!
```
 Cоздание vlan и description:
```python
`{%` for vlan, name in vlans.items() `%}`
vlan <span>{</span>{ vlan }}
    name {{ name }}
`{%` endfor `%}`
!
interface vlan2
 ip address {{ip_switch}} 255.255.255.0
!
ip default-gateway 192.168.2.254
```

Radius авторизация (http по local password):
```
!
authentication line console login local
authentication line vty login radius local
authentication enable radius local
authorization line vty exec radius local
!
radius-server authentication host {{radius_server}} key 0 {{radius_key}}
aaa enable
!
```
На выходе получаем конфиг:

```
username admin privilege 15 password 0 rfm
!
clock timezone MSK add 3 0
!
logging 192.168.0.20
logging executed-commands enable
!
snmp-server enable
snmp-server security disable
snmp-server host 192.168.0.20 v2c  public
snmp-server community ro 0 public
!
lldp enable
!
mtu 9000
!
loopback-detection interval-time 10 3
loopback-detection control-recovery timeout 600
loopback-detection trap enable
!
ntp enable
ntp server
!
interface ethernet1/0/9-10
switchport mode trunk
switchport trunk allowed vlan 2;701
loopback-detection specified-vlan 1-4094
loopback-detection control block
!
vlan 2
   name mgmt
vlan 701
   name sgok_kanal
!
interface vlan2
 ip address 192.168.2.227 255.255.255.0
!
ip default-gateway  192.168.2.254
!
authentication line console login local
authentication line vty login radius local
authentication enable radius local
authorization line vty exec radius local
!
radius-server authentication host 172.20.103.206 key 0 radius
aaa enable
!
```
 
