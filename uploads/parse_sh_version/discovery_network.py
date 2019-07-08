# -*- coding: utf-8 -*-
# опросить устройства в 192.168.0.0/24
# опросить устройство и сохранить информацию о оборудовании
#"Device Type","Mac","IP Address","Vlan","Boot ver","firmware ver"
#"SNR-S2965-24T","f8:f0:82:75:07:7c","7.0.3.5(R0241.0124)","7.2.25","192.168.0.195"
import ipaddress
import subprocess
import netmiko
import sys
import textfsm
from pprint import pprint
from tabulate import tabulate
#
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
# если ввели argv не то, но выводим хелп.
# по -h /? --help.
try:
  template=sys.argv[1]
  command=' '.join(sys.argv[2:])
  print ('template:',template,'\ncommand:',command)
except:
 print('''неверные аргументы
- первый аргумент template 1. sh_switch_dlink.template 2.  sh_version_snr.template
- второй аргумент 'sh version' / 'sh switch'
- сеть для сканирования указана в коде
''')
subnet=ipaddress.ip_network('192.168.0.10/32')
default_param={'device_type':'cisco_ios_telnet','username':'admin','password':'admin','verbose':True}
commands=['sh switch','sh version']

for host in subnet:
    if check_device(host)==0:
      default_param.update({'ip':str(host)})
      result=connection_to_dev(default_param,command)
      print(host,parse_output(result,template))
      
