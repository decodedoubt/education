FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG VIPS_VERSION=8.10.1

ARG VIPS_URL=https://github.com/libvips/libvips/releases/download

# libvips installs to /usr/local by default .. /usr/local/bin is on the
# default path in ubuntu, but /usr/local/lib is not
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# expand
ENV PATH=$PATH:/usr/local/bin
ENV MANPATH=$MANPATH:/usr/local/man

# basic build tools
RUN apt-get update \
  && apt-get install -y \
  build-essential \
  autoconf \
  automake \
  libtool \
  nasm \
  wget \
  pkg-config \
  curl \
  gtk-doc-tools \
  swig \
  gobject-introspection

# we must not use any packages which depend directly or indirectly on libjpeg,
# since we want to use our own mozjpeg build
RUN apt-get install -y \
  libxml2-dev \
  libfftw3-dev \
  libmagickwand-dev \
  libopenexr-dev \
  libgsf-1-dev \
  liborc-0.4-0 \
  liborc-dev \
  libglib2.0-dev \
  libexpat-dev \
  libpng-dev \
  libgif-dev \
  libwebp-dev \
  libheif-dev \
  libexif-dev \
  liblcms2-dev \
  libimagequant-dev

RUN cd /usr/local/src \
  && wget ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz \
  && tar xzf vips-${VIPS_VERSION}.tar.gz

RUN cd /usr/local/src/vips-${VIPS_VERSION} \
  && ./autogen.sh \
  && make \
  && make install

# nodejs
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN mkdir -p /usr/local/src/image-actions
WORKDIR /usr/local/src/image-actions

COPY package.json package-lock.json /usr/local/src/image-actions/
RUN npm install

# copy in src
COPY LICENSE README.md entrypoint.js tsconfig.json .jest.env.js /usr/local/src/image-actions/
COPY markdown-templates/ /usr/local/src/image-actions/markdown-templates/
COPY src/ /usr/local/src/image-actions/src/
RUN npm run build
COPY __tests__/ /usr/local/src/image-actions/__tests__/

ENTRYPOINT ["/usr/local/src/image-actions/entrypoint.js"]
