#!/bin/bash

START_LINE=92
SUDOERS_FILE="/etc/sudoers"

users=(
	hasanov 
	ruchkin
	kashbullin
	dima
	ochirov
	ahmetov
	ankudinov
	aletdinov
)

for user in "${users[@]}"; do
    useradd -m -d /home/$user $user
    echo "Пользователь $user создан."
done

for pass in "${users[@]}"; do
    echo "$pass:123qwe123" | sudo chpasswd
    echo "Пароль для пользователя $pass установлен."
done

for permission in "${users[@]}"; do
    while true; do
        if ! sed -n "${START_LINE}p" ${SUDOERS_FILE} | grep -q .; then  # Проверяем, есть ли текст в строке
             sed -i "${START_LINE}i $permission ALL=(ALL:ALL) ALL" ${SUDOERS_FILE}
             echo "Пользователь $permission добавлен в файл sudoers."
             break
        else
            START_LINE=$((START_LINE + 1))
        fi
    done
done

