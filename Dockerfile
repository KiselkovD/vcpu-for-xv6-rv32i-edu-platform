FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        git \
        wget \
        curl \
        python3 \
        ninja-build \
        pkg-config \
        libglib2.0-dev \
        libpixman-1-dev \
        libfdt-dev \
        libslirp-dev \
        libcap-ng-dev \
        flex \
        bison \
        texinfo \
        gperf \
        autoconf \
        automake \
        libtool \
        libexpat1-dev \
        libmpc-dev \
        libmpfr-dev \
        gawk \
        help2man \
        make \
        device-tree-compiler \
        iverilog \
        vim \
        gdb \
        perl \
        tree \
        bsdmainutils \
        xxd \
    && apt-get clean

ENV RISCV32=/opt/riscv32
ENV PATH=$RISCV32/bin:$PATH

RUN mkdir -p $RISCV32 && \
    cd $RISCV32 && \
    wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2026.05.19/riscv32-elf-ubuntu-22.04-gcc.tar.xz && \
    tar -xf riscv32-elf-ubuntu-22.04-gcc.tar.xz --strip-components=1 && \
    rm riscv32-elf-ubuntu-22.04-gcc.tar.xz

RUN cd $RISCV32/bin && \
    for f in riscv32-elf-*; do \
        if [ -f "$f" ] && [ ! -e "${f/riscv32-elf/riscv32-unknown-elf}" ]; then \
            ln -s "$f" "${f/riscv32-elf/riscv32-unknown-elf}"; \
        fi \
    done

WORKDIR /tmp
RUN git clone https://gitlab.com/qemu-project/qemu.git --branch stable-5.0 --depth 1 && \
    cd qemu && \
    ./configure --target-list=riscv32-softmmu --prefix=/usr/local --disable-werror && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/qemu

RUN ln -s /usr/local/bin/qemu-system-riscv32 /usr/local/bin/qemu-system-riscv32-5

# Установка bash-completion и настройка автодополнения для make
RUN apt-get update && \
    apt-get install -y bash-completion && \
    apt-get clean

# Включить bash-completion в .bashrc для интерактивных оболочек
RUN echo "if [ -f /usr/share/bash-completion/bash_completion ]; then" >> /root/.bashrc && \
    echo "    . /usr/share/bash-completion/bash_completion" >> /root/.bashrc && \
    echo "fi" >> /root/.bashrc

RUN qemu-system-riscv32-5 --version && \
    riscv32-unknown-elf-gcc --version && \
    riscv32-unknown-elf-objcopy --version && \
    iverilog -V && \
    hexdump --version && \
    tree --version && \
    perl -v | head -2

WORKDIR /workspace
CMD ["/bin/bash"]