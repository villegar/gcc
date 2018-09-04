FROM centos

LABEL name="GCC" \
    author="Roberto Villegas-Diaz" \
    maintainer="Roberto.VillegasDiaz@sdstate.edu"

RUN yum -y install git wget xz which && \
    yum -y install bzip2 bzip2-devel make file && \
    yum -y install zlib zlib-devel lzma lzma-devel && \
    yum -y install gcc gcc-c++ libgcc glibc-devel glibc-headers

ENV GCC_VER="5.5.0"

RUN mkdir -p /opt && \
    cd /opt && \
    rm -rf /opt/*
# --- Installing GCC ---
WORKDIR /opt
RUN wget --quiet -4 https://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.gz && \
    tar -xzf gcc-${GCC_VER}.tar.gz && \
    cd gcc-${GCC_VER} && \
    ./contrib/download_prerequisites && \
    mkdir build && \
    cd build && \
    ../configure \
        --prefix=/usr \
        --disable-multilib \
        --enable-languages=c,c++,fortran \
        --enable-libstdcxx-threads \
        --enable-libstdcxx-time \
        --enable-shared \
        --enable-__cxa_atexit \
        --disable-libunwind-exceptions \
        --disable-libada \
        --host x86_64-redhat-linux-gnu \
        --build x86_64-redhat-linux-gnu \
        --with-default-libstdcxx-abi=gcc4-compatible
RUN cd /opt/gcc-${GCC_VER}/build && make -j4
RUN cd /opt/gcc-${GCC_VER}/build && make install

# Register new libraries with `ldconfig`
RUN echo "/usr/local/lib64" > usrLocalLib64.conf && \
    mv usrLocalLib64.conf /etc/ld.so.conf.d/ && \
    ldconfig

# Clean out all the garbage
RUN rm -rf /opt
#RUN df -h && rm -rf /opt/gcc-${GCC_VER} && rm -rf *.tar.gz && df -h

