#!/bin/bash

echo '194.1.156.16 repohub.ekassir.com' | sudo tee -a /etc/hosts > /dev/null

sudo apt-get install -y docker-engine 
systemctl enable --now docker

cd /etc/docker && curl -O http://10.7.88.6/share/python_autoinstall/certs.d.tar.gz && tar -xvf certs.d.tar.gz && rm -rf certs.d.tar.gz

echo '{
  "log-level": "warn",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  },
  "dns": ["10.4.111.155", "10.4.111.156", "8.8.8.8", "8.8.4.4"]
}' | sudo tee /etc/docker/daemon.json > /dev/null

systemctl restart docker

docker login repohub.ekassir.com -u rshb_repository -p Gq#fOfV@

echo -n "Вставьте токен от Manager Node: "
read input

if [[ -z "$input" ]]; then
    echo "Ошибка: токен не может быть пустым."
    exit 1
fi

echo "Присоединение к Docker Swarm с токеном: $input"
docker swarm join --token "$input" || {
    echo "Ошибка: не удалось присоединиться к Docker Swarm."
    exit 1
}

echo "Успешно присоединились к Docker Swarm."
