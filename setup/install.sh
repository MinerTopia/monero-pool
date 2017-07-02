#!/usr/bin/env bash

echo "============================================================="
echo "===================================================  ========"
echo "===================================================  ========"
echo "==  ===============================================  ========"
echo "=    ===   ===  =   ====   ====   ===  =  ===   ===  ===   =="
echo "==  ===  =  ==    =  ==  =  ==  =  ==  =  ==  =  ==  ==  =  ="
echo "==  ===     ==  ==========  ==  ======    ==  =====  ==     ="
echo "==  ===  =====  ========    ==  ========  ==  =====  ==  ===="
echo "==  ===  =  ==  =======  =  ==  =  ==  =  ==  =  ==  ==  =  ="
echo "==   ===   ===  ========    ===   ====   ====   ===  ===   =="
echo "============================================================="
echo "==============================================v0.9.01========"
if [ "$EUID" = 0 ]
  then echo "Please do not run as root"
  exit
fi
CURUSER=$(whoami)
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt update && apt -y upgrade
sudo DEBIAN_FRONTEND=noninteractive apt -y install git curl ntp build-essential screen cmake pkg-config libboost-all-dev redis-server libevent-dev libunbound-dev libminiupnpc-dev libunwind8-dev liblzma-dev libldns-dev libexpat1-dev libgtest-dev lmdb-utils libzmq3-dev libssl-dev
cd ~
git clone https://github.com/teracycle/teracycle-pool.git 
echo "[compiling and installing monero]"
cd ~
sudo git clone https://github.com/monero-project/monero.git
cd monero
sudo git checkout v0.10.3.1
curl https://raw.githubusercontent.com/Snipa22/nodejs-pool/master/deployment/monero_daemon.patch | sudo git apply -v
sudo make -j$(nproc)
sudo cp ~/teracycle-pool/deployment/monero.service /lib/systemd/system/
sudo useradd -m monerodaemon -d /home/monerodaemon
BLOCKCHAIN_DOWNLOAD_DIR=$(sudo -u monerodaemon mktemp -d)
sudo -u monerodaemon wget --limit-rate=50m -O $BLOCKCHAIN_DOWNLOAD_DIR/blockchain.raw https://downloads.getmonero.org/blockchain.raw # not sure if i want this to be rate limited, but ill test it
sudo -u monerodaemon /usr/local/src/monero/build/release/bin/monero-blockchain-import --input-file $BLOCKCHAIN_DOWNLOAD_DIR/blockchain.raw --batch-size 20000 --database lmdb#fastest --verify off --data-dir /home/monerodaemon/.bitmonero
sudo -u monerodaemon rm -rf $BLOCKCHAIN_DOWNLOAD_DIR
sudo systemctl daemon-reload
sudo systemctl enable monero
sudo systemctl start monero
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
source ~/.nvm/nvm.sh
nvm install v0.10
cd ~/teracycle-pool
npm update
npm install -g forever
sudo systemctl daemon-reload
cd ~/teracycle-pool
forever init.js
