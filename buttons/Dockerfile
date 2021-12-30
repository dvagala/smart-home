FROM alpine:3.15
RUN apk add bluez-deprecated=5.62-r0
RUN apk add mosquitto-clients=2.0.14-r0

WORKDIR /app
COPY . .
RUN chmod +x bt_pinger.sh

ENTRYPOINT ["sh", "bt_pinger.sh"]
