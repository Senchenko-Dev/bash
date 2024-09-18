#!/bin/bash

SUDOERS_FILE="/etc/sudoers"
USER_FILE="users.txt"

while IFS= read -r user; do  #IFS= перед read позволяет считывать строки целиком, включая пробелы, без их разделения
    useradd -m -d /home/$user $user
    echo "Пользователь $user создан."
done < "$USER_FILE" #Этот оператор перенаправляет содержимое файла, указанного в переменной USER_FILE, в стандартный ввод команды read

while IFS= read -r pass; do
    echo "$pass:123qwe123" | sudo chpasswd
    echo "Пароль для пользователя $pass установлен."
done < "$USER_FILE"

while IFS= read -r user; do
    ROOT_LINE=$(sudo grep -n "^root" ${SUDOERS_FILE} | cut -d: -f1) #ищем в файле sudoers слово root
    
    if [ -n "$ROOT_LINE" ]; then #  # Проверяем, свободна ли следующая строка. оператор -n используется для проверки, является ли строка НЕПУСТОЙ
        NEXT_LINE=$((ROOT_LINE + 1)) 
        
        while true; do
            NEXT_CONTENT=$(sudo sed -n "${NEXT_LINE}p" ${SUDOERS_FILE})  # Получаем содержимое следующей строки

            if [ -z "$NEXT_CONTENT" ]; then # Если следующая тсрока пустая. оператор -z  используется для проверки, является ли строка ПУСТАЯ
                sudo sed -i "${NEXT_LINE}i $user ALL=(ALL:ALL) ALL" ${SUDOERS_FILE}
                echo "Пользователь $user добавлен в файл sudoers."
                break
            else
                NEXT_LINE=$((NEXT_LINE + 1))
            fi
        done
    else
        echo "Строка с 'root' не найдена в файле sudoers."
    fi
done < "$USER_FILE"
