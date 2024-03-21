# IoMBian Mosquitto

Custom image to deploy a Mosquitto MQTT broker very easily on IoMBian devices.


## Build the image

To build the docker image, from the cloned repository, execute the docker build command in the same level as the Dockerfile:

```
docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} .
```

For example: ```docker build -t iombian-mosquitto:latest .```


## Launch de container

After building the image, execute it with docker run:

```
docker run --name ${CONTAINER_NAME} --rm -d -p 1883:1883 -p 8000:8000 -e USER1_USERNAME=test -e USER1_PASSWORD=password iombian-mosquitto:latest
```

- **--name** is used to define the name of the created container.
- **--rm** can be used to delete the container when it stops. This parameter is optional.
- **-d** is used to run the container detached. This way the container will run in the background. This parameter is optional.
- **-p** is used to map a port of the container on the host. 
- **-e** can be used to define the environment variables:
  - TCP_PORT: the port where Mosquitto will listen to client connections. Default value is 1883.
  - ALLOW_ANONYMOUS: defines if anonymous connections are allowed. Default value is false.
  - USER1_USERNAME: the username of the first user. No default value.
  - USER1_PASSWORD: the password of the first user. No default value.
  - USER1_USERNAME: the username of the second user. No default value.
  - USER1_PASSWORD: the password of the second user. No default value.
  - WEBSOCKETS_ENABLED: defines if websocket connections are allowed. Default value is true.
  - WEBSOCKETS_PORT: the port where Mosquitto will listen to websocket connections. Default value is 8000.

> [!CAUTION]
> If 'ALLOW_ANONYMOUS' is set to false, the username and password of user1 must be provided.

Otherwise, a ```docker-compose.yml``` file can also be used to launch the container:

```yaml
version: '3'

services:
  iombian-mosquitto:
    image: iombian-mosquitto:latest
    container_name: iombian-mosquitto
    restart: unless-stopped
    ports:
      - 1883:1883
      - 8000:8000
    environment:
      - USER1_USERNAME=test
      - USER1_PASSWORD=password
      - USER2_USERNAME=anothertest
      - USER2_PASSWORD=anotherpassword
      - LISTENER_PORT=1883
      - ALLOW_ANONYMOUS=false
      - WEBSOCKETS_ENABLED=true
      - WEBSOCKETS_PORT=8000
```

```
docker compose up -d
```

## Author

(c) 2024 [Aitor Iturrioz Rodríguez](https://github.com/bodiroga) ([Tknika](https://tknika.eus/))