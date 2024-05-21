#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

mainDomain='testproportal.trosbank.trus.tsocgen';

read -p "Выберите систему (P - Portal, L - Lumen, A - Agents, X - Laravel PEP, L2 - Lumen207): " system

if [ $system != "p" -a $system != "P" -a $system != "l" -a $system != "L" -a $system != "a" -a $system != "A" -a $system != "x" -a $system != "X" -a $system != "L2" -a $system != "l2" ]
then
    echo "Системы выбрана некорректно"
    exit
fi

read -p "Введите имя домена: " domain

if [ -d "$domain" ];
then
    echo "[FAIL] Домен уже существует."
    echo "Для очистки: sudo rm -rf $domain"
    echo "Затем убрать домен из конфига: sudo vi nginx.conf"
else
    printf "Введите логин разработчика (trbXXXXXX): "
    read username
    echo "Создаем домен: $domain.$mainDomain"

    mkdir -p "$domain/conf/www"
    mkdir -p "$domain/conf/logs"
    mkdir -p "$domain/site"

    echo "Берем свежую версию из мастера"
    if [ $system == "p" -o $system == "P" ]
    then
        cp nginx.conf.template "$domain/conf/www/$domain.conf"

        git clone ssh://git@gitlab.rosbank.rus.socgen:7999/proport/proportal.git /var/www/domains/$domain/site

        echo "Копируем конфиги..."

        cp /var/www/proportal/prod/.env /var/www/domains/$domain/site/.env
        cp /var/www/domains/favicon.png /var/www/domains/$domain/site/public/favicon.png
        cp /var/www/domains/favicon.ico /var/www/domains/$domain/site/public/favicon.ico
    elif [ $system == "l" -o $system == "L" ]
    then
        cp nginx.conf.lumen.template "$domain/conf/www/$domain.conf"

        git clone --depth=1 ssh://git@gitlab.rosbank.rus.socgen:7999/proport/lumen.git /var/www/domains/$domain/site

        echo "Копируем конфиги..."

        cp /var/www/lumen/prod/.env /var/www/domains/$domain/site/.env
        cp /var/www/domains/favicon.lumen.png /var/www/domains/$domain/site/public/favicon.png
        cp /var/www/domains/favicon.lumen.ico /var/www/domains/$domain/site/public/favicon.ico
    elif [ $system == "a" -o $system == "A" ]
    then
        cp nginx.conf.agents.template "$domain/conf/www/$domain.conf"

        git clone --depth=1 ssh://git@gitlab.rosbank.rus.socgen:7999/proport/proagents.git /var/www/domains/$domain/site

        echo "Копируем конфиги..."

        cp /var/www/domains/env.agents.template /var/www/domains/$domain/site/.env
        cp /var/www/domains/favicon.agents.png /var/www/domains/$domain/site/public/favicon.png
        cp /var/www/domains/favicon.agents.ico /var/www/domains/$domain/site/public/favicon.ico
    elif [ $system == "x" -o $system == "X" ]
    then
        cp nginx.conf.laravel.template "$domain/conf/www/$domain.conf"

        git clone --depth=1 ssh://git@gitlab.rosbank.rus.socgen:7999/proport/laravel.git /var/www/domains/$domain/site

        echo "Копируем конфиги..."

        cp /var/www/domains/env.laravel.template /var/www/domains/$domain/site/.env
        cp /var/www/domains/favicon.laravel.png /var/www/domains/$domain/site/public/favicon.png
        cp /var/www/domains/favicon.laravel.ico /var/www/domains/$domain/site/public/favicon.ico
    elif [ $system == "l2" -o $system == "L2" ]
    then
        cp nginx.conf.laravel.template "$domain/conf/www/$domain.conf"

        git clone --depth=1 ssh://git@gitlab.rosbank.rus.socgen:7999/proport/lumen207.git /var/www/domains/$domain/site

        echo "Копируем конфиги..."

        cp /var/www/domains/env.laravel.template /var/www/domains/$domain/site/.env
        cp /var/www/domains/favicon.laravel.png /var/www/domains/$domain/site/public/favicon.png
        cp /var/www/domains/favicon.laravel.ico /var/www/domains/$domain/site/public/favicon.ico

    fi

    echo "Настраиваем доступы... chown -r nginx:nginx"
    chown -R nginx:nginx "$domain/conf/www"

    echo "Настраиваем доступы... chmod -R 444"
    chmod -R 644 "$domain/conf/www"

    echo "sed...";
    sed -i -e "s/{%domain%}/$domain.$mainDomain/g" "$domain/conf/www/$domain.conf"
    sed -i -e "s/{%domainname%}/$domain/g" "$domain/conf/www/$domain.conf"
    sed -i -e "s/{%root%}/\/var\/www\/domains\/$domain\/site/g" "$domain/conf/www/$domain.conf"

    if [ $system == "p" -o $system == "P" ]
    then
        echo "Symbolic links..";
        php74 /var/www/domains/$domain/site/bin/console make:symlink

        echo "Generate cache..."
        php74 /var/www/domains/$domain/site/bin/console cache:warmup --no-debug

        echo "Downloading latest vue..."
        php74 /var/www/domains/$domain/site/bin/console get:vue

        echo "Настраиваем доступы chmod -R 777"
        chmod -R 777 "$domain/site/cache"
        chmod -R 777 "$domain/site/var"

        chmod o+w /var/www/domains/$domain/site/public/static/documentation
    elif [ $system == "l" -o $system == "L" ]
    then
        echo "Настраиваем доступы chmod -R 777"

        chmod -R 777 "$domain/site/storage/logs"
        chmod -R 777 "$domain/site/storage/framework"
        chmod -R 777 "$domain/site/public/assets"
    elif [ $system == "a" -o $system == "A" ]
    then
        echo "Настраиваем доступы chmod -R 777"

        chmod -R 777 "$domain/site/storage/logs"
        chmod -R 777 "$domain/site/storage/framework"
        chmod -R 777 "$domain/site/bootstrap/cache"
    elif [ $system == "x" -o $system == "X" ]
    then
        echo "Настраиваем доступы chmod -R 777"

        chmod -R 777 "$domain/site/storage/logs"
        chmod -R 777 "$domain/site/storage/framework"
        chmod -R 777 "$domain/site/bootstrap/cache"
    elif [ $system == "l2" -o $system == "L2" ]
    then
        echo "Настраиваем доступы chmod -R 777"

        chmod -R 777 "$domain/site/storage/logs"
        chmod -R 777 "$domain/site/storage/framework"
        chmod -R 777 "$domain/site/bootstrap/cache"

    fi

    echo "chown -R $username@trosbank.trus.tsocgen:759800513 /var/www/domains/$domain/site"
    chown -R "$username@trosbank.trus.tsocgen":759800513 "/var/www/domains/$domain/site"

    echo "chmod -R g+w /var/www/domains/$domain/site"
    chmod -R g+w "/var/www/domains/$domain/site"

    echo "Настраиваем nginx..."

    echo "include /var/www/domains/$domain/conf/www/$domain.conf;" >> nginx.conf

    if [ $system == "p" -o $system == "P" ]
    then
        cp npmrc.template "/home/trosbank.trus.tsocgen/$username/.npmrc"
        chown "$username@trosbank.trus.tsocgen":"$username@trosbank.trus.tsocgen" "/home/trosbank.trus.tsocgen/$username/.npmrc"
    fi

    echo > "$domain/conf/logs/access.log"
    echo > "$domain/conf/logs/error.log"
    chown -R "$username@trosbank.trus.tsocgen":nginx "$domain/conf/logs"

    cat logrotate.template >> /etc/logrotate.d/nginx
    sed -i -e "s/{%domainname%}/$domain/g" /etc/logrotate.d/nginx
    sed -i -e "s/{%username%}/$username@trosbank.trus.tsocgen/g" /etc/logrotate.d/nginx

    echo "Перезапуск nginx..."

    service nginx reload
    echo "[SUCCESS] Домен $domain.$mainDomain успешно создан. Проверка:"

    echo "https://$domain.$mainDomain/whoami.php"
fi

