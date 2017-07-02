#!/usr/bin/env bash
# always use the proper shebang


# set up our colors
NC='\e[1;30m' # No Color
PURPLE='\e[0;35m'
LPURP='\e[1;35m'
WHITE='\e[1;37m'

# logo

echo -e "${PURPLE}====${LPURP}TERACYCLE-POOL${PURPLE}==========================================="
echo -e "${PURPLE}===================================================  ========"
echo -e "${PURPLE}===================================================  ========"
echo -e "${PURPLE}==  ===============================================  ========"
echo -e "${PURPLE}=    ===   ===  =   ====   ====   ===  =  ===   ===  ===   =="
echo -e "${PURPLE}==  ===  =  ==    =  ==  =  ==  =  ==  =  ==  =  ==  ==  =  ="
echo -e "${PURPLE}==  ===     ==  ==========  ==  ======    ==  =====  ==     ="
echo -e "${PURPLE}==  ===  =====  ========    ==  ========  ==  =====  ==  ===="
echo -e "${PURPLE}==  ===  =  ==  =======  =  ==  =  ==  =  ==  =  ==  ==  =  ="
echo -e "${PURPLE}==   ===   ===  ========    ===   ====   ====   ===  ===   =="
echo -e "${PURPLE}============================================================="
echo -e "${PURPLE}=================================================${LPURP}v.0.9.01${PURPLE}====${NC}"

# make sure user isn't root
if [ "$EUID" = 0 ]
  then 
    
    echo -e "${RED}You shouldn't run this setup as root."
    
    echo -e "${NC}Press ${WHITE}[CTRL+C]${NC} now to exit, or I'll make a user for you in 15 seconds."
    sleep 15
    echo -e "${WHITE}Creating a non-root user with sudo privileges${NC}"
    useradd -m poolboy
    adduser poolboy sudo
    adduser poolboy www-data
  exit
fi

# load dependencies
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade
sudo DEBIAN_FRONTEND=noninteractive apt -y install git curl tmux htop gcc build-essential cmake pkg-config libboost-all-dev redis-server libevent-dev libunbound-dev libminiupnpc-dev libunwind8-dev liblzma-dev libldns-dev libexpat1-dev libgtest-dev lmdb-utils libzmq3-dev graphviz doxygen libssl-dev
cd ~
git clone https://github.com/teracycle/teracycle-pool.git 
cd teracycle-pool
mv ~/teracycle-pool/frontend /var/www/pool
cd setup
mv 000-default.conf /etc/apache2/sites-available/000-default.conf
cd /etc/apache2/sites-available
a2dissite 000-default.conf
service apache2 reload
a2ensite 000-default.conf
service apache2 reload
redis-server --daemonize yes
ps aux | grep redis-server

# monero daemon
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

# start API
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
source ~/.nvm/nvm.sh
nvm install v0.10
cd ~/teracycle-pool
npm update
npm install -g forever
sudo systemctl daemon-reload
forever init.js
#end tmux session with frontend + api
