#!/bin/bash

SUBJECT="/C=CA/ST=Novosib/L=NB/O=Sber/CN=Sber"

openssl genrsa -out 00CA0001CUFSufssrusr.key 2048

openssl req -key 00CA0001CUFSufssrusr.key -subj "$SUBJECT" -new -out 00CA0001CUFSufssrusr.csr

openssl x509 -signkey 00CA0001CUFSufssrusr.key -in 00CA0001CUFSufssrusr.csr -req -days 365 -out 00CA0001CUFSufssrusr.cer

openssl x509 -in 00CA0001CUFSufssrusr.cer -out 00CA0001CUFSufssrusr.pem

cat 00CA0001CUFSufssrusr.pem >  chain.pem

printf '%s' "Генерим хранилище .p12 'Введите пароль':  "

openssl pkcs12 -export -in 00CA0001CUFSufssrusr.pem -inkey 00CA0001CUFSufssrusr.key -out 00CA0001CUFSufssrusr.p12 -name 00CA0001CUFSufssrusr -CAfile chain.pem -caname 00CA0001CUFSufssrusr.key

printf '%s' "Импортируем p.12 в .jks 'пароль должен быть такой же как введенный выше' "

keytool -importkeystore -destkeystore 00CA0001CUFSufssrusr.jks -srckeystore 00CA0001CUFSufssrusr.p12 -srcstoretype PKCS12 -alias 00CA0001CUFSufssrusr
