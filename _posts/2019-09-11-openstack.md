---
title: "Openstack наработки"
date: 2019-09-11 09:52:51 +0000
categories:
  - openstack
tags:
  - devops
---
 1) Установки на uduntu 16.04  xenial 
 https://ru.bmstu.wiki/OpenStack
 
 2) Необходимые ресурсы
 ![]({{ site.baseurl }}/uploads/hwreqs.png "требуемые ресурсы")


  проверка кластера elasticsearch 
  curl -XGET 'localhost:9200/_cluster/health?pretty'
