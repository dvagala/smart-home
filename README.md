## Requirements


sudo apt-get install docker
sudo apt-get install docker-compose

sudo groupadd docker
sudo usermod -aG docker ${USER}
# now restart



## Steps

./build_bt_pinger.sh
./build_rpi_buttons.sh

./start_docker_compose.sh   # this will keep the containers running even after reboot
