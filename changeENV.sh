#!/bin/bash

main_directory="/var/www/domains"

for person_folder in "$main_directory"/*; do
    if [[ -d "$person_folder" && "$person_folder" =~ [Pp]ortal ]]; then
        env_file="$person_folder/site/.env"

        if [ -f "$env_file" ]; then
            sed -i 's/APP_DEBUG=false/APP_DEBUG=true/g' "$env_file"
            sed -i 's/SHOW_ERROR=false/SHOW_ERROR=true/g' "$env_file"
            echo "Значени в файде $env_file изменены"
        fi
    fi
done
