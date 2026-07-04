# TurboVNC

Build and run the container:

```sh
sudo apt-get update && sudo apt-get install -y pwgen
TURBOVNC_PASSWORD=$(pwgen 20 1)
docker build -t turbovnc . --build-arg TURBOVNC_PASSWORD="${TURBOVNC_PASSWORD}"
echo "TURBOVNC_PASSWORD: ${TURBOVNC_PASSWORD}"
docker run --name turbovnc --rm -it -p 5900:5900 turbovnc
```

Connect to port 5900 with [TurboVNC Viewer](https://turbovnc.org/).

Omit `TURBOVNC_PASSWORD` to run without VNC authentication.
