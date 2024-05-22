#!/bin/bash

find /var/www/domains/*/conf/www -name "*.conf" | while read file; do

sed -i '5s/,/ /' $file

echo "удаление запятой из файла $file выполнено"

done
