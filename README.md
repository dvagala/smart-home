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


# Optional
if you want to disable status led on rpi zero, put thison /etc/rc.local

echo none | sudo tee /sys/class/leds/led0/trigger # LED lit
