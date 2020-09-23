#tested with 20.04 adjust make cores according to system
FROM ubuntu:20.04
RUN apt-get update
ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ=Europe/Berlin
#gccgo related libraries
RUN apt-get install -qq -y apt-utils gcc git subversion make g++ flex libgmp-dev libmpfr-dev libmpc-dev curl
RUN apt-get install -qq -y dialog apt-utils wget vim
RUN apt-get install -qq -y bison binutils-dev libipt-dev libtool texinfo 
#git hash e109f6e438b72ef3e403162971068d28d09b82f5 gccgo (GCC) 11.0.0
RUN git clone --branch devel/gccgo git://gcc.gnu.org/git/gcc.git gccgo
WORKDIR /gccgo/
RUN ./contrib/download_prerequisites
#gold brings in optimizations for goroutines, we can try compiling binaries with this.
RUN git clone git://sourceware.org/git/binutils-gdb.git
RUN mkdir binutils-objdir
RUN cd binutils-objdir && ../binutils-gdb/configure --enable-gold=default --prefix=/opt/gold
RUN cd binutils-objdir && make -j4
RUN echo "binutils make status $?"
RUN cd binutils-objdir && make install -j4
RUN echo "binutils make install status $?"
#build gccgo
RUN mkdir objdir
RUN cd objdir && ../configure --prefix=/opt/gccgo --enable-languages=c,c++,go \
    --disable-libquadmath \
    --disable-libquadmath-support \
    --disable-werror \
    --disable-multilib
RUN cd objdir && make -j4
RUN echo "gccgo make status $?"
RUN cd objdir && make install -j4
RUN echo "gccgo make install status $?"
RUN echo export PATH=$PATH:/usr/local/go/bin:/opt/gccgo/bin >> /root/.profile
#gccgo lib location  add to LD as well
RUN echo export LIBDIR=/opt/gccgo/lib/../lib64 >> /root/.profile
RUN echo export LD_LIBRARY_PATH=/usr/local/lib64:/opt/gccgo/lib/../lib64 >> /root/.profile
