#!/usr/bin/env bash

printf 'Сгенерировать ключ: gen_key\n'
printf 'Подписать ключем сгенерированным ранее: sign_rpm\n'
printf 'Списки ключей: list_keys\n'
printf 'Списки ключей: list_key_active\n'
printf ':'
read variable

case $variable in
 gen_key)
echo "Ключ должен быть вставлен, введите данные для создания opengpg ключа"
echo "Введите Name-Real:"
read namer
echo "Введите Name-Comment:"
read namec
#echo "Введите Name-Email:"
namee=$(pkcs11-tool --module /usr/lib/librtpkcs11ecp.so -O | grep subject |  awk -F= '{print $NF}')
#read namee
export namee=$namee
echo "Введите PIN:"
read namep
#create  gpg: /root/.gnupg/trustdb.gpg
if ! test /root/.gnupg/trustdb.gpg
then gpg --list-keys
else echo "проверка: /root/.gnupg/trustdb.gpg создан"
fi
#запрос к карте , почему-то без этого пока не работает
gpg --card-status
keyid=$(gpg-connect-agent  'SCD LEARN' /bye | grep KEY-FRIEDNLY  | awk '{print $3}')
echo "создание файла параметров для генерации ключа"
touch ~/gpg_batch
echo "%echo Generating a OpenPGP key" > ~/gpg_batch
echo "Key-Type: 1" >> ~/gpg_batch
echo "Key-Grip:" $keyid >> ~/gpg_batch
echo "Key-usage: sign,cert" >> ~/gpg_batch
echo "Name-Real:" $namer >> ~/gpg_batch
echo "Name-Comment:" $namec >> ~/gpg_batch
echo "Name-Email:" $namee >> ~/gpg_batch
echo "%commit" >> ~/gpg_batch
echo "%done" >> ~/gpg_batch
echo "Генерация ключа"
gpg --batch --expert --full-generate-key  --passphrase $namep --pinentry-mode loopback  ~/gpg_batch

touch /root/.rpmmacros
echo "%_gpg_name" $namee  > /root/.rpmmacros


gpg --export -a $namee > ~/RPM-GPG-KEY
rpm --import ~/RPM-GPG-KEY
;;
sign_rpm)
echo "Добавление подписи /home/vagrant/vboxshare/rpm/*.rpm "

mv /home/vagrant/vboxshare/rpm/*.rpm /mnt
rpmsign --addsign /mnt/*.rpm

echo "Проверка /home/vagrant/vboxshare/signed/*.rpm"
if ! [ -d /home/vagrant/vboxshare/signed ]; then
mkdir /home/vagrant/vboxshare/signed
fi

for pkg in /mnt/*.rpm
do
 echo $pkg
 if rpm -v --checksig $pkg | grep Signature | grep Header
 then mv $pkg /home/vagrant/vboxshare/signed
 else mv $pkg /home/vagrant/vboxshare/rpm
 fi
done
# инфа по ключам импортированных в rpm
# rpm -qa gpg-pubkey* 
# rpm -qi gpg-pubkey-fddb0531-5d94c7c9
#rpm -q gpg-pubkey --qf '%{summary}\n'
# Summary     : gpg(123213 (123213) <123123@2323232>)
;;
list_keys)
#если нет еще ключей то ошибка, нужно писать исключение
rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'
;;
list_key_active)
echo 'source key write in /root/.rpmmacros\n'
keys=$(cat /root/.rpmmacros | awk {'print $2'} )
rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'  | grep $keys --color=auto
;;
esac
