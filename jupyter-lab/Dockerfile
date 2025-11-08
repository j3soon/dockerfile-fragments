FROM ubuntu:22.04

# Use supervisor to manage services
RUN apt-get update && apt-get install -y \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install pip and Jupyter Lab
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install jupyterlab
# If using Ubuntu 24.04 as base image, use the following install instead:
# RUN pip3 install --break-system-packages jupyterlab
# Configure supervisor to manage the Jupyter Lab server
ARG JUPYTER_LAB_TOKEN
RUN cat <<EOF > /etc/supervisor/conf.d/jupyter-lab.conf
[program:jupyter-lab]
command=jupyter lab --allow-root --ip=0.0.0.0 --no-browser --notebook-dir=/ --NotebookApp.token="${JUPYTER_LAB_TOKEN}"
stderr_logfile=/var/log/jupyter-lab.err.log
stdout_logfile=/var/log/jupyter-lab.out.log
EOF
# We intentionally use `--NotebookApp.*` instead of `--ServerApp.*` to support older versions of Jupyter Lab
# Note: `--NotebookApp.password` may be used as an alternative, but it requires generating a hashed password which adds complexity
# Ref: https://stackoverflow.com/a/77117477
# Set default Jupyter Lab shell to bash
ENV SHELL=/bin/bash

CMD ["/usr/bin/supervisord", "-n"]
