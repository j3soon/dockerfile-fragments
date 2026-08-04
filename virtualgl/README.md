# VirtualGL

Build the container:

```sh
docker build -t virtualgl .
```

In a container with NVIDIA GPU access and an existing X11 or VNC display, run:

```sh
DISPLAY=:0 vglrun -d egl glxinfo -B
DISPLAY=:0 vglrun -d egl glxgears
```

References:

- [VirtualGL documentation](https://virtualgl.org/Documentation/Documentation)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/)
