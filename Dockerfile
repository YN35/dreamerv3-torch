# 1. Test setup:
# docker run -it --rm --gpus all pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime nvidia-smi
#
# If the above does not work, try adding the --privileged flag
# and changing the command to `sh -c 'ldconfig -v && nvidia-smi'`.
#
# 2. Start training:
# docker build -f  Dockerfile -t img . && \
# docker run -it --rm --gpus all -v $PWD:/workspace -u $(id -u):$(id -g) img \
#   sh xvfb_run.sh python3 dreamer.py \
#   --configs dmc_vision --task dmc_walker_walk \
#   --logdir "./logdir/dmc_walker_walk"
#
# 3. See results:
# tensorboard --logdir ~/logdir

# System
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime
USER root

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/San_Francisco
ENV PYTHONUNBUFFERED 1
ENV PIP_DISABLE_PIP_VERSION_CHECK 1
ENV PIP_NO_CACHE_DIR 1
RUN apt-get update && apt-get install -y \
    git vim libglew2.1 libgl1-mesa-glx libosmesa6 \
    wget unrar cmake g++ libgl1-mesa-dev \
    libx11-6 openjdk-8-jdk x11-xserver-utils xvfb \
    && apt-get clean
RUN pip install pip==24.0 setuptools==59.5.0 wheel==0.34.2

# Envs
ENV NUMBA_CACHE_DIR=/tmp

# dmc setup
RUN pip3 install tensorboard
RUN pip3 install gym==0.19.0
RUN pip3 install mujoco==2.3.5
RUN pip3 install dm_control==1.0.9
RUN pip3 install moviepy

# crafter setup
RUN pip3 install crafter==1.8.0

# atari setup
RUN pip install opencv-python==4.6.0.66
RUN pip3 install gym[atari]==0.19.0
RUN pip3 install atari-py==0.2.9
RUN mkdir roms && cd roms
RUN wget -L -nv http://www.atarimania.com/roms/Roms.rar
RUN unrar x -o+ Roms.rar
RUN python3 -m atari_py.import_roms ROMS
RUN cd .. && rm -rf roms

# memorymaze setup
RUN pip3 install memory_maze==1.0.3

# minecraft setup
RUN pip3 install git+https://github.com/minerllabs/minerl
RUN pip3 install numpy==1.21.0

# upgrade pip
RUN pip3 install --upgrade pip