---
title: "nmap dns-recursion"
date: 2019-02-15 09:00:00 +0000
categories:
  - dns recursion
tags:
  - dns recursion
---
Запрос.
```bash
nmap -sU -sV -p 53 --script dns-recursion   91.197.76.0/16
```
Результат
```bash
Nmap scan report for 187-79-197-91.reinfokom.ru (91.197.79.187)
Host is up (0.028s latency).
PORT   STATE SERVICE
53/udp open  domain
|_dns-recursion: Recursion appears to be enabled

Nmap scan report for 188-79-197-91.reinfokom.ru (91.197.79.188)
Host is up (0.053s latency).
PORT   STATE         SERVICE
53/udp open|filtered domain

Nmap scan report for 189-79-197-91.reinfokom.ru (91.197.79.189)
Host is up (0.0048s latency).
PORT   STATE         SERVICE
53/udp open|filtered domain

Nmap scan report for 191-79-197-91.reinfokom.ru (91.197.79.191)
Host is up (0.015s latency).
PORT   STATE SERVICE
53/udp open  domain
|_dns-recursion: Recursion appears to be enabled
```

Как распарсить , в удобочитаемом виде

 - grep -A 2 -B 2 "dns-rec" ./result 
 или
 - grep -B 4 "dns-rec" ./result 
```bash
 --
 PORT   STATE SERVICE
 53/udp open  domain
 |_dns-recursion: Recursion appears to be enabled

 Nmap scan report for 1-1-1-1.reinfokom.ru (1.1.1.1)
 --
 PORT   STATE SERVICE
 53/udp open  domain
 |_dns-recursion: Recursion appears to be enabled

 Nmap scan report for 2.1.1.1.reinfokom.ru (1.1.1.2)
 --
```


источник https://unix.stackexchange.com/questions/82944/how-to-grep-for-text-in-a-file-and-display-the-paragraph-that-has-the-text




