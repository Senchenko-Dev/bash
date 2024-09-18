#!/bin/bash

START_LINE=92
SUDOERS_FILE="/etc/sudoers"
USER_FILE="users.txt"

while IFS= read -r user; do #IFS= перед read позволяет считывать строки целиком, включая пробелы, без их разделения
    useradd -m -d /home/$user $user
    echo "Пользователь $user создан."
done < "$USER_FILE" #Этот оператор перенаправляет содержимое файла, указанного в переменной USER_FILE, в стандартный ввод команды read

while IFS= read -r pass; do
    echo "$pass:123qwe123" | sudo chpasswd
    echo "Пароль для пользователя $pass установлен."
done < "$USER_FILE"

while IFS= read -r user; do
    while true; do
        if ! sudo sed -n "${START_LINE}p" ${SUDOERS_FILE} | grep -q .; then # Проверяем, есть ли текст в строке
            sudo sed -i "${START_LINE}i $user ALL=(ALL:ALL) ALL" ${SUDOERS_FILE}
            echo "Пользователь $user добавлен в файл sudoers."
            break
        else
            START_LINE=$((START_LINE + 1))
        fi
    done
done < "$USER_FILE"


