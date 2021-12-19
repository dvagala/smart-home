#!/bin/bash






# Set Parameters
mqttserverip='homeassistant.local'
mqtttopic='home/sensors/presence/iphone'
messagefound='On'
messagenotfound='Off'




mac="5C:70:17:E3:DC:6F"

sudo hcitool cc $mac 2> /dev/null

is_iphone_nearby="no"

i=0
sumed_rssi=0
buffer_size=3
tresh=-28
last_mqtt_msg=""
try_to_connect_attempts=0

check_frequency_if_home=20 # seconds
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
    if [ "$bt" == "" ]; then
        try_to_connect_attempts=$(($try_to_connect_attempts + 1))

	    if [[ $try_to_connect_attempts -ge 10 ]]; then
	        echo "couldnt connect to phone, dominik must be gone"
            send_mqtt "no"
	    fi

        if [ "$last_mqtt_msg" == "yes" ]; then
            sleep $check_frequency_if_home
        else
            sleep $check_frequency_if_away
        fi

        echo "trying to connect..."
        sudo hcitool cc $mac  2> /dev/null
	    continue
    fi

    try_to_connect_attempts=0

    rssi=$(echo "$bt" | rev | cut -d ' ' -f 1 | rev)
    echo "got rssi $rssi"
    sumed_rssi=$(( $sumed_rssi + $rssi))

    if [[ $i -ge $buffer_size ]]; then
	    avg_rssi=$(( $sumed_rssi / $buffer_size ))
	    sumed_rssi=0
	    i=0
	    #echo "avg_rssi $avg_rssi"

	    if [[ $avg_rssi -gt $tresh ]]; then
	        send_mqtt "yes"
	    else
	        send_mqtt "no"
	    fi
    fi


    if [ "$last_mqtt_msg" == "yes" ]; then
        sleep $check_frequency_if_home
    else
        sleep $check_frequency_if_away
    fi


    i=$(($i + 1))
done
