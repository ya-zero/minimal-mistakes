---
title: "Автоматизация выполнения задач на сетевом оборудовании CLI .Парсим вывод информации о свитче."
date: 2019-07-08 00:52:51 +0000
categories:
  - python
  - network
  - automation
  - cli
tags:
  - cisco,netmiko,python,snr,d-link,mikrotik,telnet,ssh,cli
---

Пример кода который позволяет распарсить cli вывод   с коммутора комманды sh version/sh switch.
[source](https://github.com/ya-zero/ya-zero.github.io/tree/master/uploads/parse_sh_version)


```console
$ python ./discovery_network.py ./templates/sh_version_snr.template  sh version
template: ./templates/sh_version_snr.template 
command: sh version
>>>connect to host 192.168.0.10
192.168.0.10 [['SNR-S2985G-8T', 'f8:f0:82:77:d5:e2', '7.0.3.5(R0241.0279)', '7.2.33', '1.1.2', 'SW070911I105000560']]
```


```python
# -*- coding: utf-8 -*-
# готовим  два файла для template
#  template -- snr
#  template -- dlink
import ipaddress
import subprocess
import netmiko
import sys
import textfsm
from pprint import pprint
from tabulate import tabulate

#проверка доступности хоста
def check_device (host):
      result=subprocess.run(['ping',str(host),'-c','1','-W','1'],stdout=subprocess.DEVNULL).returncode
      # returncode == 0  ping good
      return result
#подключение к устройству
def connection_to_dev(device,command):
   try:
     with netmiko.ConnectHandler(**device) as ssh:
          print ('>>>connect to host',device['ip'])
          result=ssh.send_command(command)
          if 'Incomplete' in result:
              print ('Error in command')
     return result
   except:
     print ('>>>netmiko_return_error',device[ip])

#textfsm  парсинг вывода с коммутатора sh version/sh switch
def parse_output(output,template = './templates/sh_version_snr.template'):
 try:
  with open(template) as f:
    re_table = textfsm.TextFSM(f)
    result = re_table.ParseText(output)
    return result
 except:
    print ('>>>no open file:',template)
# как узнать вендора.
# сканируем сеть два раза.
# но в начале должен быть везде ssh.
# либо запуск по параметрам.
# если ввели argv не то, но выводим хелп, также хелп доступен.
# по -h /? --help.
try:
  template=sys.argv[1]
  command=' '.join(sys.argv[2:])
  print ('template:',template,'\ncommand:',command)
except:
 print('''неверные аргументы
- первый аргумент template
- второй аргумент 'sh version' / 'sh switch'
''')
subnet=ipaddress.ip_network('192.168.0.100/32')
default_param={'device_type':'cisco_ios_telnet','username':'admin','password':'rfm','verbose':True}
commands=['sh switch','sh version']

for host in subnet:
    if check_device(host)==0:
      default_param.update({'ip':str(host)})
      result=connection_to_dev(default_param,command)
      print(host,parse_output(result,template))
```


Шаблон TextFSM для SNR
```
#SNR-S2965-24T
Value Model (\S+)
Value Mac (\S+)
Value Software (\S+)
Value Boot (\S+)
Value Hardware (\S+)
Value Serial (\S+)

Start
  ^.{2}${Model} Device.*
  ^.*Vlan \S+ ${Mac}
  ^.*SoftWare \S+ ${Software}
  ^.*BootRom \S+ ${Boot}
  ^.*HardWare \S+ ${Hardware}
  ^.*Serial.*:${Serial} -> Record


# SNR-S2965-24T Device, Compiled on Sep 30 09:40:44 2016
#  sysLocation Building 57/2,Predelnaya st, Ekaterinburg, Russia
#  CPU Mac f8:f0:82:75:07:7d
#  Vlan MAC f8:f0:82:75:07:7c
#  SoftWare Version 7.0.3.5(R0241.0124)
#  BootRom Version 7.2.25
#  HardWare Version 1.0.2
#  CPLD Version N/A
#  Serial No.:SW052910FA15000909
#  Copyright (C) 2016 NAG LLC
#  All rights reserved
#  Last reboot is cold reset.
#  Uptime is 26 weeks, 6 days, 1 hours, 30 minutes
```

Шаблон для коммутаторов D-Link
```
#DES-3010G
#DES-1210
Value Model (\S+)
Value Mac (\S+)
Value Boot (\S+)
Value Software (\S+)
Value Serial (\S+)
Value Hardware (\S+)

Start
  ^.*Device.*: ${Model}
  ^.*MAC.*: ${Mac}
  ^.*Boot.*:( \S+ | )${Boot}
  ^.*Firmware.*:( \S+ | )${Software}
  ^.*Hardware.*: ${Hardware}
  ^.*Serial.*: ${Serial} -> Record
#
#Device Type        : DES-3010G Fast Ethernet Switch
#MAC Address        : 00-22-B0-63-43-30
#IP Address         : 192.168.0.10 (Manual)
#Boot PROM Version  : Build 1.01.009
#Firmware Version   : Build 4.20.B27
#Hardware Version   : A3
#
#DES-1210
#Value Model (\S+)
#Value Mac (\S+)
#Value Required Boot (\S+)
#Value Software (\S+)
#Value Serial (\S+)
#Value Hardware (\S+)
#
#Start
#  ^.*Device.*: ${Model}
#  ^.*MAC.*: ${Mac}
#  ^.*Boot.*: ${Boot}
#  ^.*Firmware.*: ${Software}
#  ^.*Hardware.*: ${Hardware}
#  ^.*Serial.*: ${Serial} -> Record
#
#System Hardware Version           : B2
#System Serial Number              : QBM51DA004240
#важна очередность Start 1 2 3 5 4 -Resocrd !!!!!!!!!!!!!!!
```


Результат выполнения
Dlink :
```console
- Boot: 1.00.B01
  Hardware: A1
  Ip: 192.168.0.62
  Mac: 1C-AF-F7-6F-4A-BB
  Model: DES-1228/ME
  Software: 1.60.B02
- Boot: 4.00.002
  Hardware: C1
  Ip: 192.168.0.64
  Mac: E8-CC-18-D4-8E-40
  Model: DES-3200-28
  Software: 4.42.B010
SNR :
- Boot: 7.1.24
  Hardware: 1.0.3
  Ip: 192.168.0.141
  Mac: f8:f0:82:75:8f:67
  Model: SNR-S2990G-24TX
  Serial: SW041310G402000044
  Software: 7.0.3.5(R0102.0185)
- Boot: 7.2.33
  Hardware: 1.1.2
  Ip: 192.168.0.157
  Mac: f8:f0:82:77:a2:26
  Model: SNR-S2985G-8T
  Serial: SW070911H528001886
  Software: 7.0.3.5(R0241.0215)
```
