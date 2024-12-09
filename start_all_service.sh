#!/bin/bash

folders=("am"
         "verification"
         "discovery"
         "operhub"
         "awh"
         "haproxy"
         "esbv3conversion"
         "opmessagestosendsms"
         "savecustomerips"
         "atmtransactionverificationservicedocker"
         "sbpaymiddleware"
         "apcommon"
         "saf"
         "esb2amconversion"
         "aprecurrent"
)

for folder in "${folders[@]}"; do
    current_dir=$(pwd)
    cd "$folder" || continue
    for script in *.sh; do
      if [ -f "$script" ]; then
        echo "Запуск скрипта: $script в директории: $folder"
        bash "$script"
      fi
    done

    cd "$current_dir" || exit
done

for service in $(docker service ls | grep _migrate); do
    echo "Удаляем сервис: $service"
    docker service rm "$service"
done
