# All-in-one

Build and run the container:

```sh
sudo apt-get update && sudo apt-get install -y pwgen
ALL_PASSWORD=$(pwgen 20 1)
docker build -t all-in-one --build-arg SSH_PASSWORD="${ALL_PASSWORD}" --build-arg TIGERVNC_PASSWORD="${ALL_PASSWORD}" .
echo "ALL_PASSWORD: ${ALL_PASSWORD}"

docker run --name all-in-one --rm -it --gpus all \
  -p 2222:22 \
  -p 5900:5900 \
  -p 6080:6080 \
  all-in-one
```

## SSH

In another machine, run:

```sh
ssh -p 2222 root@localhost
# or the following to avoid key error
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 root@localhost
# and then enter the password
```

## VNC

Open <http://localhost:6080/vnc.html> in your browser and click "Connect".

Or you can specify the VNC server address: <http://localhost:6080/vnc.html?host=localhost&port=5900>.

This assumes you have a VNC server running on `localhost:5900`.

You can adjust the screen size using `Settings > Scaling Mode`. The `Clipboard` feature is also available when needed.
