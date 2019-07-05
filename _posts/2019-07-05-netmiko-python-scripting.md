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
https://github.com/ya-zero/ya-zero.github.io/tree/master/uploads/generate_config_example

имея набор данных в формате yaml
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
мы подставляем в шаблон jinja2
 - базовый шаблон 
https://github.com/ya-zero/ya-zero.github.io/blob/master/uploads/generate_config_example/snr/snr_base.txt
 - создание vlan и description
 https://github.com/ya-zero/ya-zero.github.io/blob/master/uploads/generate_config_example/snr/snr_vlan_mgmt_ip.txt
 - radius авторизация (http по local password)
https://github.com/ya-zero/ya-zero.github.io/blob/master/uploads/generate_config_example/snr/snr_authen_radius.txt

на выходе получаем файл https://github.com/ya-zero/ya-zero.github.io/blob/master/uploads/generate_config_example/192.168.2.227.cfg
 
 
 ``
 {% for vlan, name in vlans.items() %}
vlan {{ vlan }}
   name {{ name }}
{% endfor %}
!
interface vlan2
 ip address {{ip_switch}} 255.255.255.0
!
ip default-gateway 192.168.2.254
``
