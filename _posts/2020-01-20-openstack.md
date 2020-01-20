# Система автоматизированной подписи пакетов SailFish
# ver 0.1
* Windows VirtualBox:
Необходимо установить следующие пакеты:
- VirtualBox https://www.virtualbox.org/wiki/Downloads
- vagrant https://www.vagrantup.com/downloads.html
- git https://git-scm.com/downloads
```shell
c:\git clone --single-branch --branch windows git@gitlab.tools.russianpost.ru:private-cloud/gpg-sign.git
c:\cd gpg-sign
```
Для правильно работы скрипта необходимо создать директорию ./rpm  в тойже директории где лежит Vagrantfile, куда складываем
пакеты для подписания.

Запуск виртуальной машины.
```
c:\vagrant up
```
Подключение к виртуальной машине.

```
c:\vagrant ssh
```
Подключившись к VM запускаем скрипт:
```
./gen_opengpg.sh
```

Пакеты для подписи нужно расположить в поддиректории  *./rpm *, относительно *vagrantfile*, подписанные пакеты будут перемещены в поддиректорию *./signed*

Если запуск происходит в первый раз  необходимо запустить ./gen_opengpg.sh  и импортировать ключ с usbtoken.

  –  gen_key 
    На текущий момент для импорта , необходимо заполнить поля name и comment , поле email берется  c ключа (из поля object сертификата x.509)     
    Скрипт импортирует ключ в gpg базу, затем экспортирует его в rpm   базу и создаст на его основе ~./rpmmacros.
    В ./rpmmacros  заполняется поле ~./gpg_name  , где указывется индетификатор ключа (достаточно указать email)

 -  sign_rpm  
    Подпишет пакеты  rpmsign --addsign *.rpm   ключем который указал в ~./rpmmacros
    Команда может запросить ввести PIN.
    После выполения скрипта должны увидеть на подобие такого

   /mnt/12.rpm
    Header V4 RSA/SHA512 Signature, key ID b6ea8c0d: OK
   /mnt/librtpkcs11ecp-1.9.15.0-1.x86_64.rpm
    Header V4 RSA/SHA512 Signature, key ID b6ea8c0d: OK  



Если требуется экспортировать готовый ключ на Token , это выполняется скриптом ./export_key.sh .
Для его работы , нужно создать поддиректорию keys относительно vagrantfile.

 В поддиректории ./keys расположить два файла: 
  keys.der   - private rsa  ключ в формате DER   
  cert.der    - x.509 сертификат в формате DER




