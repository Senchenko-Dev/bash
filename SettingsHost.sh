#!/bin/bash

mkdir /usr/share/ca-certificates/local_trust && cd /usr/share/ca-certificates/local_trust && curl -O http://10.7.88.6/share/certificates/espp_am.crt
sudo update-ca-trust

pkg=(
     gcc
     make
     zlib-devel
     libssl-devel
         libsqlite3-devel
         libffi-devel
)
for i in "${pkg[@]}"
do
  sudo apt-get install $i -y
done

mkdir ~/install_python
cd ~/install_python
curl -O http://10.7.88.6/share/python_autoinstall/python.tar.gz && tar -xvf python.tar.gz && rm -rf python.tar.gz
cd ~/install_python/python && tar -xvf Python-3.10.4.tgz
cd Python-3.10.4 && ./configure --enable-optimizations
make
sudo make install

packages_tar=(
       "PyYAML-5.3.1.tar.gz"
)

packages=(
        idna-2.5-py2.py3-none-any.whl
        semantic_version-2.6.0-py3-none-any.whl
        resolvelib-0.5.3-py2.py3-none-any.whl
        passlib-1.7.4-py2.py3-none-any.whl
        jsondiff-2.0.0-py3-none-any.whl
        websocket_client-1.8.0-py3-none-any.whl
        idna-2.5-py2.py3-none-any.whl
        urllib3-2.2.2-py3-none-any.whl
        certifi-2024.7.4-py3-none-any.whl
        charset_normalizer-2.0.0-py3-none-any.whl
        requests-2.32.3-py3-none-any.whl
        docker-5.0.3-py2.py3-none-any.whl
)

for package in "${packages_tar[@]}"
do
    cd ~/install_python/python/pip && tar -xvf $package
    package_dir=$(tar -tf $package | head -n 1 | cut -d '/' -f 1)
    cd $package_dir && python3.10 setup.py install
done


for package in "${packages[@]}"; do
  cd ~/install_python/python/pip
  pip3.10 install $package
done

echo "root:123qwe123" | chpasswd

sed -i '5i PermitRootLogin yes' /etc/ssh/sshd_config

systemctl restart sshd

sudo apt-get install -y docker-engine && sudo usermod -aG docker $USER
systemctl enable --now docker

cd /etc/docker && curl -O http://10.7.88.6/share/python_autoinstall/certs.d.tar.gz && tar -xvf certs.d.tar.gz && rm -rf certs.d.tar.gz

echo '194.1.156.16 repohub.ekassir.com' | sudo tee -a /etc/hosts > /dev/null

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

IP_NODE_MASTER=$(ip addr show enp1s0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)

docker swarm init --advertise-addr ${IP_NODE_MASTER}

docker login repohub.ekassir.com -u rshb_repository -p Gq#fOfV@
