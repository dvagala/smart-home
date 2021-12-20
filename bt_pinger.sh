#!/bin/bash






# Set Parameters
mqttserverip='homeassistant.local'
mqtttopic='home/sensors/presence/iphone'
messagefound='On'
messagenotfound='Off'




mac="5C:70:17:E3:DC:6F"

sudo hcitool cc $mac 2> /dev/null

is_iphone_nearby="no"

tresh=-28
last_mqtt_msg=""
try_to_connect_attempts=0

check_frequency_if_home=30 # seconds
check_frequency_if_away=1 # seconds



send_mqtt () {
    is_iphone_nearby="$1"
    if [ "$last_mqtt_msg" != $is_iphone_nearby ]; then
        last_mqtt_msg=$is_iphone_nearby
        mosquitto_pub -q 1 -h homeassistant.local -t "bedroom/dominik-iphone/present" -u mqttuser -P XX7eEKDDbVUAN4 -m $is_iphone_nearby
        mosquitto_pub -q 1 -h homeassistant.local -t "bedroom/mqtt-sensor/last-active" -u mqttuser -P XX7eEKDDbVUAN4 -m "$(date +"%d-%m-%Y %H:%M:%S")"
        echo "$(date +"%d-%m-%Y %H:%M:%S") $avg_rssi - $is_iphone_nearby sending to mqtt"
        sleep 4
    else
        echo "$(date +"%d-%m-%Y %H:%M:%S") $avg_rssi - $is_iphone_nearby still same value, thus not sending mqtt"
    fi
}



while true
do
    bt=$(hcitool rssi $mac 2> /dev/null)
    rssi=$(echo "$bt" | rev | cut -d ' ' -f 1 | rev)
    echo "got rssi $rssi"

    if [ "$rssi" == "" ] || [[ "$rssi" -lt $tresh ]]; then
        try_to_connect_attempts=$(($try_to_connect_attempts + 1))

	    if [[ $try_to_connect_attempts -ge 3 ]]; then
	        echo "couldnt connect to phone with rssi > $rssi, dominik must be gone"
            send_mqtt "no"
	    fi
    else
        try_to_connect_attempts=0
        send_mqtt "yes"
    fi


    if [ "$last_mqtt_msg" == "yes" ]; then
        sleep $check_frequency_if_home
    else
        sleep $check_frequency_if_away
    fi


    if [ "$bt" == "" ]; then
        echo "trying to connect..."
        sudo hcitool cc $mac  2> /dev/null
    fi
done
