#!/bin/bash

read -p "Введите имя домена который хотите удалить:> " string

sed -i "/$string/d" nginx.conf

rm -rf "$string"

nginx -s reload

echo "домен '$string' удалена из файла nginx.conf"

echo "папка с именем домена '$string' удалена"
