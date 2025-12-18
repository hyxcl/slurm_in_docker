FROM ubuntu:22.04
LABEL maintainer="Edison Liu <edisonl@nvidia.com>"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y \
    && apt install -y \
    build-essential \
    wget \
    curl \
    libmunge-dev \
    libmariadb-dev \
    libmariadbclient-dev-compat \
    libpam0g-dev \
    libdbus-1-dev \
    ruby-dev \
    libev-dev \
    libevent-dev \
    zlib1g \
    zlib1g-dev \
    pandoc \
    munge \
    git \
    bsdmainutils \
    vim \
    mariadb-server \
    iputils-ping

RUN apt install sudo -y \
#    && apt install python3.9 python3-pip -y \
    && apt install python3 python3-dev -y \
    && useradd -m admin -s /usr/bin/bash -d /home/admin \
    && echo "admin:admin" | chpasswd && adduser admin sudo \
    && echo "admin     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 

RUN apt update -y \
    && apt install pip libopenmpi-dev openmpi-bin -y \
    && pip3 install mpi4py 
RUN apt-get install -y bzip2 supervisor \
    libmunge2 lua5.3 lua5.3-dev \
    psmisc \
    software-properties-common \
    openssh-server openssh-client \
    automake autoconf unzip \ 
    libgtk2.0-dev libglib2.0-dev \
    libhdf5-dev \
    libcurl4-openssl-dev

RUN apt-get remove -y slurm slurm-wlm slurmctld slurmdbd slurmd 2>/dev/null || true \
    && apt-get remove -y pmix libpmix-dev libpmix5 2>/dev/null || true \
    && apt-get remove -y hwloc libhwloc-dev libhwloc5 2>/dev/null || true

# https://nvidia.github.io/libnvidia-container/
RUN distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
RUN sudo apt-get update
RUN apt install -y libnvidia-container1 libnvidia-container-tools nvidia-container-runtime


#install hwloc
RUN curl -fsL https://download.open-mpi.org/release/hwloc/v2.5/hwloc-2.5.0.tar.gz | tar xzf - -C /tmp/ \
    && cd /tmp/hwloc-2.5.0/ \
    && ./configure --prefix=/opt/hwloc --enable-static--disable-cairo --disable-libxml2 --enable-netloc --enable-plugins \
    && make -j 10 && make install \
    && cd / \
    && rm -rf /tmp/hwloc-2.5.0 \
    && echo "/opt/hwloc/lib" >> /etc/ld.so.conf.d/hwloc.conf \
    && ldconfig


# Enroot
# https://github.com/NVIDIA/enroot/blob/master/doc/installation.md
RUN arch=$(dpkg --print-architecture) \
    && curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v3.4.1/enroot_3.4.1-1_${arch}.deb \
    && curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v3.4.1/enroot+caps_3.4.1-1_${arch}.deb \
    && sudo apt install -y ./*.deb \
    && sudo rm -f ./*.deb

# RUN apt install slurmd slurm-client slurmctld libslurm-dev -y
# RUN rm -rf /var/lib/apt/lists/*


# OpenPMIx
RUN curl -fsL https://github.com/openpmix/openpmix/releases/download/v3.2.3/pmix-3.2.3.tar.bz2 | tar xfj - -C /tmp/ \
    && cd /tmp/pmix-3.2.3/ \
    && ./configure --prefix=/opt/pmix/v4 --with-hwloc=/opt/hwloc \
    && make -j 10 && make install \
    && cd / \
    && rm -rf /tmp/pmix* \
    && echo "/opt/pmix/v4/lib" >> /etc/ld.so.conf.d/pmix.conf \
    && ldconfig

# Download, compile and install SLURM
ENV SLURM_VER=23.02.8
RUN curl -fsL https://download.schedmd.com/slurm/slurm-${SLURM_VER}.tar.bz2 | tar xfj - -C /opt/ \
    && rm -rf slurm-${SLURM_VER}.tar.bz2 \
    && cd /opt/slurm-${SLURM_VER}/ \
    && ./configure --prefix=/usr/local --disable-dependency-tracking --disable-debug --disable-x11 --enable-really-no-cray --enable-salloc-kill-cmd --with-hdf5=no  --with-libcurl --sysconfdir=/etc/slurm --enable-pam --with-pam_dir="/lib/x86_64-linux-gnu/security" --with-shared-libslurm  --with-pmix=/opt/pmix/v4 --with-hwloc="/opt/hwloc" \
    && make -j && make -j contrib && make install && make install-contrib \
    && if [ -d "contribs/pam_slurm_adopt" ]; then \
        cd contribs/pam_slurm_adopt \
        && make -j$(nproc) >> ../../build.log 2>&1 \
        && make install >> ../../build.log 2>&1 \
        && cd ../..; \
    fi
RUN echo "/usr/local/lib" >> /etc/ld.so.conf.d/slurm.conf \
    && mkdir -p "/usr/local/lib/slurm" \
    && chmod 755 "/usr/local/lib/slurm" \
    && ldconfig


RUN useradd -m slurm -s /usr/bin/bash -d /home/slurm
RUN echo "slurm:slurm" | chpasswd && adduser slurm sudo \
    && echo "slurm     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    #RUN groupadd -r --gid=995 slurm \
    #    && useradd -r -g slurm --uid=995 slurm \
    && mkdir -p /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/run/slurmdbd \
        /var/lib/slurmd \
        /var/log/slurm \
        /data \
    && touch /var/lib/slurmd/node_state \
        /var/lib/slurmd/front_end_state \
        /var/lib/slurmd/job_state \
        /var/lib/slurmd/resv_state \
        /var/lib/slurmd/trigger_state \
        /var/lib/slurmd/assoc_mgr_state \
        /var/lib/slurmd/assoc_usage \
        /var/lib/slurmd/qos_usage \
        /var/lib/slurmd/fed_mgr_state \
    && chown -R slurm:slurm /var/*/slurm* \
    && chown -R slurm:slurm /var/spool

# install pyxis
RUN cd /opt/ \
    && wget https://github.com/NVIDIA/pyxis/archive/refs/tags/v0.11.1.tar.gz \
    && tar xzf v0.11.1.tar.gz \
    && cd pyxis-0.11.1 \
    && export CPPFLAGS="-I /usr/local/include/slurm" \
    && make install \
    && mkdir -p /etc/slurm/plugstack.conf.d \
    && ln -s /usr/local/share/pyxis/pyxis.conf /etc/slurm/plugstack.conf.d/pyxis.conf \
    && echo "include /etc/slurm/plugstack.conf.d/*.conf" > /etc/slurm/plugstack.conf \
    && chmod 644 /etc/slurm/plugstack.conf \
    && cd / \
    && rm -rf /opt/v0.11.1.tar.gz /opt/pyxis-0.11.1

RUN if [ -d /usr/share/enroot/hooks.d ]; then \
        mkdir -p /etc/enroot/hooks.d \
        && if [ -f /usr/share/enroot/hooks.d/50-slurm-pmi.sh ]; then \
            ln -sf /usr/share/enroot/hooks.d/50-slurm-pmi.sh /etc/enroot/hooks.d/50-slurm-pmi.sh; \
        fi \
        && if [ -f /usr/share/enroot/hooks.d/50-slurm-pytorch.sh ]; then \
            ln -sf /usr/share/enroot/hooks.d/50-slurm-pytorch.sh /etc/enroot/hooks.d/50-slurm-pytorch.sh; \
        fi; \
    fi

RUN echo "/dev/nvidia-caps-imex-channels" > /etc/enroot/mounts.d/imex.fstab

COPY 98-nvidia.sh /etc/enroot/hooks.d/
COPY slurm.conf /etc/slurm/
COPY gres.conf /etc/slurm/
COPY cgroup.conf /etc/slurm/
COPY docker-entrypoint.sh /etc/slurm/
COPY slurmctld* /etc/init.d/
COPY slurmd* /etc/init.d/
RUN rm -fr /lib/firmware

#EXPOSE 6817 6818 6819 3306 

WORKDIR /home/slurm

ENTRYPOINT ["/etc/slurm/docker-entrypoint.sh"]
