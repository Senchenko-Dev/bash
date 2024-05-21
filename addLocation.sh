#!/bin/bash

find /var/www/domains/senchenkoPortal/conf/www -name "*.conf" | while read file; do
    awk '
    # Переменная для отслеживания, внутри ли мы блока location / { ... }
    inside_location_block {
        print
        if (/^\s*\}/) {
            inside_location_block=0
            print "    location /endpoint/ {"
            print "        proxy_pass https://gateway-proportal-test.apps.tpaas.trosbank.trus.tsocgen/;"
            print "    }"
        }
        next
    }

    # Условие, чтобы начать отслеживание блока location / { ... }
    /^\s*location \/ \{\s*$/ {
        inside_location_block=1
        print
        next
    }

    # По умолчанию просто печатать строки
    {print}
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

#find /var/www/domains/senchenkoPortal/conf/www -name "*.conf" | while read file; do
#echo "location /endpoint/ {" >> $file
#echo "        proxy_pass https://gateway-proportal-test.apps.tpaas.trosbank.trus.tsocgen/;
#" >> $file
#echo "}" >> $file
#done
