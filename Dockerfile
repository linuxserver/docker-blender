FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BLENDER_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# app title
ENV TITLE=Blender

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    ocl-icd-libopencl1 \
    xz-utils && \
  ln -s libOpenCL.so.1 /usr/lib/x86_64-linux-gnu/libOpenCL.so && \
  echo "**** install blender ****" && \
  mkdir /blender && \
  if [ -z ${BLENDER_VERSION+x} ]; then \
    BLENDER_VERSION=$(curl -sL https://mirror.clarkson.edu/blender/release/ | \
    awk -F'"|/"' '/Blender[0-9].[0-9]/ && !/alpha/ && !/beta/ {print $2}' | \
    awk '!/[a-c]/ && !/-/' | \
    tail -1); \
  fi && \
  FILENAME=$(curl -sL https://mirror.clarkson.edu/blender/release/${BLENDER_VERSION}/ | \
  awk -F'"|"' '/linux-x64/ {print $2}') && \
  curl -o \
  /tmp/${FILENAME} -L \
    "https://mirror.clarkson.edu/blender/release/${BLENDER_VERSION}/${FILENAME}" && \
  tar xf \
    /tmp/${FILENAME} -C \
    /blender/ --strip-components=1 && \
  ln -s \
    /blender/blender \
    /usr/bin/blender && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
