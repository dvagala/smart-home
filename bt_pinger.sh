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
buffer_size=5
tresh=-24
last_mqtt_msg=""

while true
do
    bt=$(hcitool rssi $mac 2> /dev/null)
    if [ "$bt" == "" ]; then
        sudo hcitool cc $mac  2> /dev/null
	#echo "... connecting"
        #bt=$(hcitool rssi $mac 2> /dev/null)
	continue
    fi

    rssi=$(echo "$bt" | rev | cut -d ' ' -f 1 | rev)
    sumed_rssi=$(( $sumed_rssi + $rssi))

    if [[ $i -ge $buffer_size ]]; then
	    avg_rssi=$(( $sumed_rssi / $buffer_size ))
	    sumed_rssi=0
	    i=0
	    #echo "avg_rssi $avg_rssi"

	    if [[ $avg_rssi -gt $tresh ]]; then
		is_iphone_nearby="yes"
	    else
		is_iphone_nearby="no"
	    fi


	    append=""
	    if [ "$last_mqtt_msg" != $is_iphone_nearby ]; then
		last_mqtt_msg=$is_iphone_nearby
		mosquitto_pub -q 1 -h homeassistant.local -t "bedroom/dominik-iphone/present" -u mqttuser -P XX7eEKDDbVUAN4 -m $is_iphone_nearby
		mosquitto_pub -q 1 -h homeassistant.local -t "bedroom/mqtt-sensor/last-active" -u mqttuser -P XX7eEKDDbVUAN4 -m "$(date +"%d-%m-%Y %H:%M:%S")"
	        echo "$(date +"%d-%m-%Y %H:%M:%S") $avg_rssi - $is_iphone_nearby sending to mqtt"
		sleep 4
	    else
	        echo "$(date +"%d-%m-%Y %H:%M:%S") $avg_rssi - $is_iphone_nearby"
	    fi
    fi

    sleep .2

    i=$(($i + 1))
done
