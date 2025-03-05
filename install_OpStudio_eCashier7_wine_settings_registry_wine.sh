#!/bin/bash

DIR="$(dirname "$0")"

cd "${DIR}" || exit

base_dir="$HOME/.cache/winetricks"
ekassir_dir="/opt/eKassir"
file_path="/usr/bin/wine"
opstudio="$HOME/Desktop/OpStudio.desktop"
ecashier="$HOME/Desktop/eCashier.desktop"
new_ekassir_dir="$HOME/eKassir"

if [ -z "$1" ]; then
  echo "Использование: $0 имя_пользователя"
  exit 1
fi

USERNAME=$1

sudo astra-sudo-control disable

sudo -u "${USERNAME}" bash -c "
if [[ -f '${file_path}' ]]; then
    echo 'wine установлен';
else
    sudo apt install -y wine;
fi
"

sudo -u "${USERNAME}" bash -c "
    echo 'Устанавливаем eCashier7 и OperationStudio'
    for deb in *.deb; do
        sudo dpkg -i \"\${deb}\";
    done;
"

sudo -u "${USERNAME}" bash -c "
if [[ -d '${new_ekassir_dir}' ]]; then
   echo 'папка перемещена и установлены парва пользователя'
else
     echo 'перносим папку eKassir в ${HOME} пользователя ${USERNAME}'
     sudo chown -R "${USERNAME}:${USERNAME}" /opt/eKassir
     sudo mv /opt/eKassir "$HOME"
fi
"

sudo -u "${USERNAME}" bash -c "
if [[ -f '${opstudio}' ]]; then
    echo 'Ярлык OperationStudio создан';
else
    echo 'Создаем ярлык OperationStudio'
    echo '[Desktop Entry]
Name=OpStudio
Exec=wine \"${HOME}/eKassir/PaySystemStudio/studio.exe\"
Type=Application
Path=${HOME}/eKassir/PaySystemStudio/' | sudo tee '${opstudio}' > /dev/null;
fi
"

sudo -u "${USERNAME}" bash -c "
if [[ -f '${ecashier}' ]]; then
    echo 'удалил старый ярлык eCashier7';
    rm -rf '${ecashier}';
fi
"

sudo -u "${USERNAME}" bash -c "
if [[ ! -f '${ecashier}' ]]; then
    echo 'создаем новый ярлык eCashier7';
    echo '[Desktop Entry]
Name=eCashier7
Exec=wine \"${HOME}/eKassir/eCashier7/Starter.exe\"
Type=Application
Path=${HOME}/eKassir/eCashier7/
Icon=${HOME}/eKassir/eCashier7/logo/eCashier.ico' | sudo tee '${ecashier}' > /dev/null;
fi
"

sudo -u "${USERNAME}" bash -c "
if grep -q 'X11 Driver' ~/.wine/user.reg; then
    echo 'Реестр настроен';
else
   echo 'Настраиваем реестр wine'
   echo 'Windows Registry Editor Version 5.00

   [HKEY_CURRENT_USER\\Software\\Wine\\X11 Driver]
   \"UseXVidMode\"=\"N\"' | sudo tee wine_settings.reg > /dev/null;

   wine regedit wine_settings.reg;
fi
"

sudo -u "${USERNAME}" bash -c "
if [[ -d '${base_dir}' && -d '${base_dir}/corefonts' && -d '${base_dir}/tahoma' ]]; then
        echo 'Шрифты установлены';
else
        echo 'Устанавливаем Шрифты'
        sudo unzip fonts.zip && cd fonts;
        sudo mkdir -p ~/.cache/winetricks/corefonts && sudo mkdir -p ~/.cache/winetricks/tahoma;
        sudo mv arial32.exe arialb32.exe ~/.cache/winetricks/corefonts;
        sudo mv IELPKTH.zip ~/.cache/winetricks/tahoma;
        cd ~/.cache/winetricks/tahoma && sudo unzip IELPKTH.zip && sudo mv IELPKTH/* . && sudo rm -rf IELPKTH.zip IELPKTH;
fi
"

if [[ -d  "${HOME}/Desktop/auto_install" ]]; then
     echo "удаляем папку auto_install и zip архив"
     sudo rm -rf "${HOME}/Desktop/auto_install"
     sudo rm -rf "${HOME}/Desktop/auto_install.zip"
fi

if sudo grep -q "^${USERNAME} " /etc/sudoers; then
    echo "Забираем root парава у пользователя ${USERNAME}"
    sudo sed -i '/^'"${USERNAME}"' ALL=(ALL:ALL) ALL/d' /etc/sudoers
fi

#sudo astra-sudo-control enable

#sudo deluser "${USERNAME}" sudo
