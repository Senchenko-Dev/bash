#!/bin/bash

links=(
       /cashier/eCashier7.deb
       /opstudio/operationstudio.deb
       /wine/wine-staging_7.13-0-astra-se17_amd64.deb
)

pkg=(
     dotnet-sdk-6.0
     openssl
     wine ia32-libs
     libc6-i386
     winetricks
)


for p in "${pkg[@]}"
do
 sudo apt install $p -y
done

sudo dotnet tool install --global dotnet-certificate-tool

touch wine_settings.reg

echo 'Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"UseXVidMode"="N" '| sudo tee ~/wine_settings.reg > /dev/null

wine regedit ~/wine_settings.reg

for link in "${links[@]}"
do
  curl -O http://10.7.88.6/dev_share/$link
done

for deb in "${links[@]}"
do
  sudo dpkg -i "${deb##*/}"  # Извлекаем имя файла из полного пути
done

sudo apt-get install -f

printf "\nфайлы находятся по пути /opt/eKassir:\n$(ls /opt/eKassir)\n"
