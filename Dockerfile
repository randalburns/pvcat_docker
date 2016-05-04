from centos:latest

ENV http_proxy 'http://proxyout.lanl.gov:8080'
ENV https_proxy 'http://proxyout.lanl.gov:8080'
ENV no_proxy 'localhost,127.0.0.1'

RUN yum -y update

RUN yum install -y \
  autoconf\
  cmake\
  gcc\
  gcc-gfortran\
  gcc-c++\
  git\
  libtool\
  make\
  mpich\
  mpich-devel\
  openssh-server\
  python-devel\
  python-pip\
  wget


RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -ivh epel-release-latest-7.noarch.rpm
RUN yum update

RUN yum install -y \
  libva\
  pkg-config\
  python-pip \
  xutils-dev

## needed by mesa
RUN pip install mako

# build mesa
WORKDIR /usr/local
# this link will expire as mesa gets older and then become stable in an old release
# download, unpack, and remove tar file...keeps image smaller and reduces number of layers
RUN wget https://mesa.freedesktop.org/archive/11.2.1/mesa-11.2.1.tar.gz && tar xvzf mesa-11.2.1.tar.gz && rm mesa-11.2.1.tar.gz
#
WORKDIR /usr/local/mesa-11.2.1

RUN autoreconf -fi
RUN ./configure \
    --enable-osmesa\
    --disable-glx \
    --disable-driglx-direct\ 
    --disable-dri\ 
    --disable-egl \
    --with-gallium-drivers=swrast 
#    --enable-gallium-osmesa \
#    --enable-gallium-llvm=yes \
#    --with-llvm-shared-libs \
#    CXXFLAGS="-O2 -g -DDEFAULT_SOFTWARE_DEPTH_BITS=31" \
#    CFLAGS="-O2 -g -DDEFAULT_SOFTWARE_DEPTH_BITS=31" \
#    --disable-xvmc \
#    --disable-dri \
#    --with-dri-drivers="" \
#    --with-gallium-drivers="swrast" \
#    --enable-texture-float \
#    --disable-shared-glapi \
#    --with-egl-platforms="" \
#    --prefix=/work/apps/mesa/9.2.2/llvmpipe

RUN make; make install

#RUN ln -s /usr/local/mesa-11.2.1/lib/gallium/libOSMesa.so /usr/local/lib

## build glu
ENV C_INCLUDE_PATH '/usr/local/mesa-11.2.1/include'
ENV CPLUS_INCLUDE_PATH '/usr/local/mesa-11.2.1/include'
WORKDIR /usr/local
RUN git clone http://anongit.freedesktop.org/git/mesa/glu.git

WORKDIR /usr/local/glu
RUN ./autogen.sh --enable-osmesa
RUN ./configure --enable-osmesa
RUN make
RUN make install


# checkout paraview
WORKDIR /usr/local

RUN git clone https://gitlab.kitware.com/paraview/paraview.git
WORKDIR /usr/local/paraview

RUN git checkout v5.0.1

RUN git submodule init
RUN git submodule update

RUN mkdir /usr/local/paraview.bin

# build paraview
WORKDIR /usr/local/paraview.bin
RUN cmake \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DPARAVIEW_ENABLE_CATALYST=ON  \
  -DPARAVIEW_ENABLE_PYTHON=ON \
  -DPARAVIEW_BUILD_QT_GUI=OFF \
  -DVTK_USE_X=OFF \
  -DOPENGL_INCLUDE_DIR=/usr/local/mesa-11.2.1/include \
  -DOPENGL_gl_LIBRARY=/usr/local/mesa-11.2.1/lib/libOSMesa.so \
  -DVTK_OPENGL_HAS_OSMESA=ON \
  -DOSMESA_INCLUDE_DIR=/usr/local/mesa-11.2.1/include \
  -DOSMESA_LIBRARY=/usr/local/mesa-11.2.1/lib/libOSMesa.so \
  -DPARAVIEW_USE_MPI=ON \
  /usr/local/paraview
 
#RUN make -j16
#RUN make -j16 install
#
#
#

