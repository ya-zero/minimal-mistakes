#!/usr/bin/env bash

printf 'Экспорт ключей на Token: write\n'
printf 'Проверка: verify\n'
printf 'Инициализация ключа (удаление всей информации): erase\n'
printf ':'
read variable

case $variable in
 write)
 #копирование ключей на token
 if [[ -f /home/vagrant/vboxshare/keys/keys.der && -f /home/vagrant/vboxshare/keys/cert.der ]];
 then
 pkcs11-tool --module /usr/lib/librtpkcs11ecp.so -l -y privkey -w /home/vagrant/vboxshare/keys/keys.der --id 10 --label Rutoen1
 pkcs11-tool --module /usr/lib/librtpkcs11ecp.so -l -y cert -w /home/vagrant/vboxshare/keys/cert.der --id 10 --label Rutoken1;
 else
 echo -en "\033[37;1;41m Нет файлов для записи\033[0m\n"
 fi 

 ;;
 verify)
 # вывод содержимого ключа
 pkcs11-tool --module /usr/lib/librtpkcs11ecp.so -Ol

 ;;
 erase)
 # вводим Admin PIN (SO PIN) и User PIN 
 echo -en "\033[37;1;41m Вся информация будет удалена\033[0m\n"
 echo -en "\033[37;1;41m Введите новый административный PIN  - SO PIN (default 87654321)\033[0m\n"
 pkcs11-tool --module /usr/lib/librtpkcs11ecp.so --init-token --label mytoken
 echo -en "\033[37;1;41m Введите SO PIN для подверждения и новый PIN (default 12345678)\033[0m\n"
 pkcs11-tool --module /usr/lib/librtpkcs11ecp.so --init-pin --login
 ;;
esac
