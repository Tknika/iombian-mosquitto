#!/bin/ash

set -e

chown --no-dereference --recursive mosquitto /mosquitto/log
chown --no-dereference --recursive mosquitto /mosquitto/data

mkdir -p /var/run/mosquitto \
  && chown --no-dereference --recursive mosquitto /var/run/mosquitto

if [[ -z "${USER1_USERNAME}" && -z "${USER1_PASSWORD}" && "${ALLOW_ANONYMOUS}" = false ]]; then
    echo "Invalid configuration. You must set USER1_USERNAME and USER1_PASSWORD or set ALLOW_ANONYMOUS to true."
    exit 1
fi

if [[ -n "${TCP_PORT}" ]]; then
    sed -i "s/listener [0-9]* #tcp-port/listener ${TCP_PORT} #tcp-port/g" /mosquitto/config/mosquitto.conf
fi

if [[ "${WEBSOCKETS_ENABLED}" = true ]]; then
    sed -i "s/^#listener [0-9]* #websockets-port/listener ${WEBSOCKETS_PORT} #websockets-port/g" /mosquitto/config/mosquitto.conf
    sed -i "s/^listener [0-9]* #websockets-port/listener ${WEBSOCKETS_PORT} #websockets-port/g" /mosquitto/config/mosquitto.conf
    sed -i "s/^#protocol websockets/protocol websockets/g" /mosquitto/config/mosquitto.conf
    sed -i "s/^#socket_domain ipv4/socket_domain ipv4/g" /mosquitto/config/mosquitto.conf
else
    sed -i "s/^listener [0-9]* #websockets-port/#listener ${WEBSOCKETS_PORT} #websockets-port/g" /mosquitto/config/mosquitto.conf
    sed -i "s/^protocol websockets/#protocol websockets/g" /mosquitto/config/mosquitto.conf
    sed -i "s/^socket_domain ipv4/#socket_domain ipv4/g" /mosquitto/config/mosquitto.conf
fi

if [[ "${ALLOW_ANONYMOUS}" = true ]]; then
    sed -i "s/allow_anonymous false/allow_anonymous true/g" /mosquitto/config/mosquitto.conf
else
    sed -i "s/allow_anonymous true/allow_anonymous false/g" /mosquitto/config/mosquitto.conf
fi

if [[ -f /mosquitto/config/passwd ]]; then
    rm /mosquitto/config/passwd
fi

if [[ -n "${USER1_USERNAME}" && -n "${USER1_PASSWORD}" ]]; then
    sed -i "s:^#password_file /mosquitto/config/passwd:password_file /mosquitto/config/passwd:g" /mosquitto/config/mosquitto.conf
    touch /mosquitto/config/passwd
    chown --no-dereference --recursive mosquitto:mosquitto /mosquitto/config/passwd
    chmod 0700 /mosquitto/config/passwd
    if [[ "${USER1_PASSWORD}" == \$7\$* ]]; then
        echo "${USER1_USERNAME}:${USER1_PASSWORD}" >> /mosquitto/config/passwd
    else
        mosquitto_passwd -b /mosquitto/config/passwd ${USER1_USERNAME} ${USER1_PASSWORD}
    fi
else
    sed -i "s:^password_file /mosquitto/config/passwd:#password_file /mosquitto/config/passwd:g" /mosquitto/config/mosquitto.conf
fi

if [[ -n "${USER2_USERNAME}" && -n "${USER2_PASSWORD}" ]]; then
    if [[ "${USER2_PASSWORD}" == \$7\$* ]]; then
        echo "${USER2_USERNAME}:${USER2_PASSWORD}" >> /mosquitto/config/passwd
    else
        mosquitto_passwd -b /mosquitto/config/passwd ${USER2_USERNAME} ${USER2_PASSWORD}
    fi
fi

exec "$@"