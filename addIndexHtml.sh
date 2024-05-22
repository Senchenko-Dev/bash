#!/bin/bash

find /var/www/domains/alikhanov/conf/www -name "*.conf" | while read file; do

sed -i '5s/index.php;/index.php index.html;/' $file #5s/ - значит на 5 строчке файла

echo "добавление index.html в файл '$file' выполнено"

done
