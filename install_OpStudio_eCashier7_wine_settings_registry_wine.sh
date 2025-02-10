#!/bin/bash

DIR="$(dirname "$0")"

cd ${DIR} || exit

base_dir="$HOME/.cache/winetricks"

ekassir_dir="/opt/eKassir"

file_path="/usr/bin/wine"

user_home="$HOME/Desktop/OpStudio.desktop"

if [[ -f "${file_path}" ]]; then
        echo "wine установлен"
else
    sudo apt install -y wine
fi

if [[ -d "${ekassir_dir}" ]]; then
    echo "eCashier7 и OperationStudio установлены"
else
   for deb in *.deb
   do
     sudo dpkg -i "${deb}"
   done

   printf "файлы находятся по пути /opt/eKassir:\n$(ls -la /opt/eKassir)\n"
fi


if [[ -f "${user_home}" ]]; then
  echo "Ярлык создан"
else
  echo '[Desktop Entry]
  Name=OpStudio.desktop
  Exec=wine '/opt/eKassir/PaySystemStudio/studio.exe'
  Type=Application
  Path=opt/eKassir/PaySystemStudio/' | sudo tee "${user_home}"
fi


if grep -q "X11 Driver" ~/.wine/user.reg; then
    echo "Реестр настроен"
else
   echo 'Windows Registry Editor Version 5.00

   [HKEY_CURRENT_USER\Software\Wine\X11 Driver]
   "UseXVidMode"="N"' | sudo tee wine_settings.reg > /dev/null

   wine regedit wine_settings.reg
fi


if [[ -d "$base_dir" && -d "$base_dir/corefonts" && -d "$base_dir/tahoma" ]]; then

        echo "Шрифты установлены"
else
        sudo unzip fonts.zip && cd fonts
        sudo mkdir -p ~/.cache/winetricks/corefonts && sudo mkdir -p ~/.cache/winetricks/tahoma
        sudo mv arial32.exe arialb32.exe ~/.cache/winetricks/corefonts
        sudo mv IELPKTH.zip  ~/.cache/winetricks/tahoma
        cd  ~/.cache/winetricks/tahoma && sudo unzip IELPKTH.zip && sudo mv IELPKTH/* . && sudo rm -rf IELPKTH.zip IELPKTH
fi
