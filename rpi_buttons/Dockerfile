FROM python:3.9

WORKDIR /app
COPY . .
RUN chmod +x rpi_buttons.py
RUN pip3 install -r requirements.txt

ENTRYPOINT python3 rpi_buttons.py "$HA_IP"
