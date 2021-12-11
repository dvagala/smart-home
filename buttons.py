from gpiozero import Button
from paho.mqtt import client as mqtt_client
import random
import time
import sys
from datetime import datetime
from threading import Timer

broker = 'homeassistant.local'
port = 1883
topic = "bedroom/buttons-pressed/"
client_id = f"python-mqtt-{random.randint(0, 1000)}"
username = 'mqttuser'
password = 'XX7eEKDDbVUAN4'


def connect_mqtt():
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker!", datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
        else:
            print("Failed to connect, return code %d\n", rc, datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    client = mqtt_client.Client(client_id)
    client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.connect(broker, port)
    return client

def publish(button_number):
    full_topic = f"{topic}{str(button_number)}"
    result = client.publish(full_topic, "")
    status = result[0]
    if status == 0:
        print(f"succesfully send mqtt to {full_topic}", datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    else:
        print(f"failed send mqtt to {full_topic}", datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    time.sleep(0.4)



button1 = Button(2)
button2 = Button(3)
button3 = Button(4)
button4 = Button(5)
button5 = Button(6)
button6 = Button(7)


def send_mqtt_last_active():
    client.publish("bedroom/mqtt-buttons/last-active", datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    print("sent mqtt last active")
    t = Timer(600.0, send_mqtt_last_active)
    t.start()

client = connect_mqtt()
client.loop_start()

send_mqtt_last_active()


while True:
    if button1.is_pressed:
        publish(1)
    elif button2.is_pressed:
        publish(2)
    elif button3.is_pressed:
        publish(3)
    elif button4.is_pressed:
        publish(4)
    elif button5.is_pressed:
        publish(5)
    elif button6.is_pressed:
        publish(6)
    time.sleep(0.1)


