ARG PYTORCH="1.6.0"
ARG CUDA="10.1"
ARG CUDNN="7"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list

RUN apt-get update && apt-get install -y ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /SWIN
COPY requirements.txt requirements.txt
COPY requirements requirements
RUN pip install -r requirements/build.txt

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

ENV FORCE_CUDA="1"

# Install MMCV
RUN pip install mmcv-full==1.4.0 -f https://download.openmmlab.com/mmcv/dist/cu101/torch1.6.0/index.html
RUN pip install timm

# Install MMDetection
# RUN conda clean --all
# RUN git clone https://github.com/open-mmlab/mmdetection.git /mmdetection
COPY README.md README.md
COPY setup.py setup.py
COPY mmdet mmdet
RUN pip install --no-cache-dir -e .
