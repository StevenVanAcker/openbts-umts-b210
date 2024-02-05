#!/bin/sh -e

echo "Installing from source"

export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y install git vim sudo tzdata iptables iproute2 net-tools tcpdump sqlite3

mkdir -p /opt/
cd /opt/
git clone https://github.com/PentHertz/OpenBTS-UMTS
cd OpenBTS-UMTS

# https://github.com/PentHertz/OpenBTS-UMTS/wiki
sed -i 's:/bin/bash:/bin/bash -e:' install_dependences.sh
sed -i 's:apt install:apt install -y:' install_dependences.sh

./install_dependences.sh # install all dependencies without caring
./autogen.sh
./configure
make -j$(nproc)
make install

# try 3 times in case there are network issues
uhd_images_downloader || uhd_images_downloader || uhd_images_downloader

mkdir /var/log/OpenBTS-UMTS
sqlite3 /etc/OpenBTS/OpenBTS-UMTS.db ".read /etc/OpenBTS/OpenBTS-UMTS.example.sql"

#sed -i 's:build.sh:build.sh || true:' preinstall.sh
#
#./preinstall.sh
#./autogen.sh
#./configure --with-uhd
#make -j$(nproc)
#make install
#ldconfig
#
#sed -i 's:socket.send(request):socket.send(request.encode("ascii")):' /opt/OpenBTS/NodeManager/nmcli.py
#sed -i 's:+ response):+ response.decode()):' /opt/OpenBTS/NodeManager/nmcli.py
#
