ARG CUDA_VERSION=11.8.0
ARG COLABFOLD_VERSION=1.5.5
FROM nvidia/cuda:${CUDA_VERSION}-base-ubuntu22.04


RUN apt-get update && apt-get install -y wget git cmake make g++ parallel cuda-nvcc-$(echo $CUDA_VERSION | cut -d'.' -f1,2 | tr '.' '-') --no-install-recommends --no-install-suggests && rm -rf /var/lib/apt/lists/* && \
    wget -qnc https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh && \
    bash Mambaforge-Linux-x86_64.sh -bfp /usr/local && \
    conda config --set auto_update_conda false && \
    rm -f Mambaforge-Linux-x86_64.sh && \
    conda config --add channels https://conda.anaconda.org/ntnn && conda config --show channels && \
    CONDA_OVERRIDE_CUDA=$(echo $CUDA_VERSION | cut -d'.' -f1,2) mamba create -y -n colabfold -c ntnn -c conda-forge -c bioconda ntnn::colabfold jaxlib==*=cuda* && \
    mamba clean -afy


# Ensure the hh-suite is installed
RUN /bin/bash -c "source /usr/local/etc/profile.d/conda.sh && \
    conda activate colabfold && \
    mamba install -y -c bioconda hhsuite && \
    cd /opt && git clone https://github.com/soedinglab/hh-suite.git && \
    cd hh-suite && mkdir build && cd build && \
    cmake -DHAVE_AVX2=1 .. && make && make install"

ENV PATH /usr/local/envs/colabfold/bin:$PATH
ENV MPLBACKEND Agg

VOLUME cache
ENV MPLCONFIGDIR /cache
ENV XDG_CACHE_HOME /cache
