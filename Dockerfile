# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BLENDER_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# app title
ENV TITLE=Blender

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/blender-icon.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    ocl-icd-libopencl1 \
    xz-utils && \
  ln -s libOpenCL.so.1 /usr/lib/x86_64-linux-gnu/libOpenCL.so && \
  echo "**** install blender ****" && \
  mkdir /blender && \
  if [ -z ${BLENDER_VERSION+x} ]; then \
    BLENDER_VERSION=$(curl -s https://projects.blender.org/api/v1/repos/blender/blender/tags \
      | jq -r '.[] | select(.name | contains("-rc") | not) | .name' \
      | sed 's|^v||g' | sort -rV | head -1); \
  fi && \
  BLENDER_FOLDER=$(echo "Blender${BLENDER_VERSION}" | sed -r 's|(Blender[0-9]*\.[0-9]*)\.[0-9]*|\1|') && \
  curl -o \
    /tmp/blender.tar.xz -fL \
    "https://mirror.clarkson.edu/blender/release/${BLENDER_FOLDER}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" || \
    curl -o \
      /tmp/blender.tar.xz -fL \
      "https://mirrors.iu13.net/blender/release/${BLENDER_FOLDER}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" && \
  tar xf \
    /tmp/blender.tar.xz -C \
    /blender/ --strip-components=1 && \
  ln -s \
    /blender/blender \
    /usr/bin/blender && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001

VOLUME /config
