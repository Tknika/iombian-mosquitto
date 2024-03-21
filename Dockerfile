FROM eclipse-mosquitto:2.0.18

ENV TCP_PORT=1883
ENV ALLOW_ANONYMOUS=false
ENV WEBSOCKETS_ENABLED=true
ENV WEBSOCKETS_PORT=8000

COPY mosquitto.conf /mosquitto/config/mosquitto.conf
COPY env-vars-entrypoint.sh /

ENTRYPOINT ["sh", "/env-vars-entrypoint.sh"]

CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]