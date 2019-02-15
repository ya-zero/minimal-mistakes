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
nmap -sU -sV -p 53 --script dns-recursion   1.1.1.1/16
```
Результат
```bash
Nmap scan report for 1-1-1-1.reinfokom.ru (1.1.1.1)
Host is up (0.015s latency).
PORT   STATE SERVICE
53/udp open  domain
|_dns-recursion: Recursion appears to be enabled
```

Как распарсить , в удобочитаемом виде

grep -A 2 -B 2 "dns-rec" ./result 


источник https://unix.stackexchange.com/questions/82944/how-to-grep-for-text-in-a-file-and-display-the-paragraph-that-has-the-text




