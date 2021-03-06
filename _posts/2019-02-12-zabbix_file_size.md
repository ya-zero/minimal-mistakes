---
title: "Мониторинг создания и изменения конфигурационного файла  с сетевого оборудования в zabbix "
date: 2019-02-12 09:00:00 +0000
categories:
  - zabbix
tags:
  - zabbix cisco conf time size
---


Настройка создания резервной копии конфигурации коммутатора.

# Kron  cisco backup config
```bash
(config)#kron occurrence saveconfig at 6:20 recurring
(config-kron-occurrence)#policy-list SaveConfig
(config)#kron policy-list SaveConfig
(config-kron-policy)#cli show run | redirect tftp://172.20.103.206/core/cisco.cfg
(config-kron-policy)#cli copy cat4000_flash:vlan.dat  tftp://172.20.103.206/core/c4948vlan.dat

```
> За историей изменений следит git 


### Мониторинг успешного создания файла  и его изменения.

Настривает zabbix_agent на хост машине,  открывает доступ для zabbix server
/etc/zabbix/zabbix_agentd.conf
Server = 10.1.1.1 , 192.168.0.1

Добавляем хост в zabbix  и создаем элементы данных:
```bash
тип : Zabbix agent 
ключ : vfs.file.size[/srv/tftp/core/cisco.cfg]
Тип информации : числовой  (целое положительное)
```

```bash
тип : Zabbix agent 
ключ : vfs.file.time[/srv/tftp/core/cisco.cfg,modify]
Тип информации : числовой  (целое положительное)
Единица измерения : unixtime
```

Создаем тригеры   если размер меньше 1кб (у меня был косяк, что конфиг создавался не полностью,  в нормальном состоянии конфиг около 55кб)
```bash
{srv_CT_172.20.103.206_freeradius:vfs.file.size[/srv/tftp/core/cisco.cfg].last()}<10000
```
И дополнительный тригер на дату изменения, если конфиг не менялся больше чем сутки .
```bash
{srv_CT_172.20.103.206_freeradius:vfs.file.time[/srv/tftp/core/cisco.cfg,modify].now()}-{srv_CT_172.20.103.206_freeradius:vfs.file.time[/srv/tftp/core/cisco.cfg,modify].last()}>86400
```

P.S. как нам узнать сработает наш trigger alert или нет.   
Меням дату файла , и ждем alert.
```bash
touch -mad "2000-01-01 01:00:00" ./cisco.cfg
```


UPD.

 https://habr.com/en/sandbox/125682/
 
 https://www.linux.org.ru/forum/general/1825069
 <!-- Yandex.Metrika counter --> <script type="text/javascript" > (function(m,e,t,r,i,k,a){m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)}; m[i].l=1*new Date();k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)}) (window, document, "script", "https://mc.yandex.ru/metrika/tag.js", "ym"); ym(53515717, "init", { clickmap:true, trackLinks:true, accurateTrackBounce:true, webvisor:true }); </script> <noscript><div><img src="https://mc.yandex.ru/watch/53515717" style="position:absolute; left:-9999px;" alt="" /></div></noscript> <!-- /Yandex.Metrika counter -->
