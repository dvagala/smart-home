from gpiozero import Button
from paho.mqtt import client as mqtt_client
import random
import time
from datetime import datetime
from threading import Timer
import sys

print('strating smart buttons')
if len(sys.argv) >= 2 and sys.argv[1] != "":
    broker = sys.argv[1]
else:
    broker = '192.168.1.101'

print('Argument List:', str(sys.argv))
print('mqqt broker IP: ', broker)

#broker = 'homeassistant.local'
port = 1883
topic = "bedroom/buttons-pressed/"
topic_long_press = "bedroom/buttons-long-pressed/"
client_id = f"python-mqtt-{random.randint(0, 1000)}"
username = 'mqttuser'
password = 'XX7eEKDDbVUAN4'

long_press_duration = 0.15


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

def publish(button_number, is_long_press = False):
    if is_long_press:
        full_topic = f"{topic_long_press}{str(button_number)}"
    else:
        full_topic = f"{topic}{str(button_number)}"
    result = client.publish(full_topic, "")
    status = result[0]
    if status == 0:
        print(f"succesfully send mqtt to {full_topic}", datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    else:
        print(f"failed send mqtt to {full_topic}", datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    time.sleep(0.3)



button1 = Button(2)
button2 = Button(3)
button3 = Button(4)
button4 = Button(5)
button5 = Button(6)
button6 = Button(7)
button7 = Button(8)
button8 = Button(9)
button9 = Button(10)


def send_mqtt_last_active():
    client.publish("bedroom/mqtt-buttons/last-active", datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    # print("sent mqtt last active")
    t = Timer(2.0, send_mqtt_last_active)
    t.start() 


client = connect_mqtt()
client.loop_start()
print('mqtt connected')

send_mqtt_last_active()


while True:
    if button1.is_pressed:
        publish(1, is_long_press=False)
        time.sleep(long_press_duration)
        if button1.is_pressed:
            publish(1, is_long_press=True)
    elif button2.is_pressed:
        publish(2, is_long_press=False)
        time.sleep(long_press_duration)
        if button2.is_pressed:
            publish(2, is_long_press=True)
    elif button3.is_pressed:
        publish(3, is_long_press=False)
        time.sleep(long_press_duration)
        if button3.is_pressed:
            publish(3, is_long_press=True)
    elif button4.is_pressed:
        publish(4, is_long_press=False)
        time.sleep(long_press_duration)
        if button4.is_pressed:
            publish(4, is_long_press=True)
    elif button5.is_pressed:
        publish(5, is_long_press=False)
        time.sleep(long_press_duration)
        if button5.is_pressed:
            publish(5, is_long_press=True)
    elif button6.is_pressed:
        publish(6, is_long_press=False)
        time.sleep(long_press_duration)
        if button6.is_pressed:
            publish(6, is_long_press=True)
    elif button7.is_pressed:
        publish(7, is_long_press=False)
        time.sleep(long_press_duration)
        if button7.is_pressed:
            publish(7, is_long_press=True)
    elif button8.is_pressed:
        publish(8, is_long_press=False)
        time.sleep(long_press_duration)
        if button8.is_pressed:
            publish(8, is_long_press=True)
    elif button9.is_pressed:
        publish(9, is_long_press=False)
        time.sleep(long_press_duration)
        if button9.is_pressed:
            publish(9, is_long_press=True)

    time.sleep(0.1)


