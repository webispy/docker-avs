FROM ubuntu:bionic as builder

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C \
    LANG=C \
    LANGUAGE=C \
    SHELL=/bin/bash

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        libasound2-dev \
        libgstreamer1.0-0 \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        libnghttp2-dev \
        libssl-dev \
        libsqlite3-dev \
        openssl \
        pkg-config \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# curl
# - install directory: /usr/local/
RUN wget https://curl.haxx.se/download/curl-7.79.1.tar.xz \
    && tar xvf curl-7.79.1.tar.xz && rm curl-7.79.1.tar.xz \
    && cd curl-7.79.1 \
    && ./configure --prefix=/usr/local --with-nghttp2 --with-ssl --disable-debug \
    && make -j6 install

# portaudio
# - install directory: /usr/local/
RUN wget -c http://www.portaudio.com/archives/pa_stable_v190600_20161030.tgz \
    && tar xvf pa_stable_v190600_20161030.tgz && rm pa_stable_v190600_20161030.tgz \
    && cd portaudio \
    && ./configure --without-jack --prefix=/usr/local \
    && make -j6 install

# alexa-device-sdk
# - source: /SRC
# - build: /BUILD
# - install directory: /usr/local/
RUN wget https://github.com/alexa/avs-device-sdk/archive/refs/tags/v1.26.0.tar.gz \
    && tar xvf v1.26.0.tar.gz && rm v1.26.0.tar.gz \
    && mv avs-device-sdk-1.26.0 /SRC

RUN mkdir /BUILD && cd /BUILD \
    && cmake /SRC \
        -DGSTREAMER_MEDIA_PLAYER=ON  \
        -DPKCS11=OFF \
        -DCMAKE_BUILD_TYPE=DEBUG \
        -DPORTAUDIO=ON \
            -DPORTAUDIO_INCLUDE_DIR=/usr/local/include \
            -DPORTAUDIO_LIB_PATH=/usr/local/lib/libportaudio.so \
    && make SampleApp -j6 install

# -----------------------------------------------------------------------------

FROM ubuntu:bionic

LABEL maintainer="webispy@gmail.com" \
      version="0.1" \
      description="avs-device-sdk sample app"

COPY --from=builder /BUILD/SampleApp/src/SampleApp /opt/avs/
COPY --from=builder /SRC/tools/Install /opt/tools
COPY --from=builder /SRC/Integration /opt/src/Integration
COPY --from=builder /usr/local /usr/local

COPY config.json /opt/

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav \
        gstreamer1.0-tools \
        libasound2-plugins \
        libgstreamer1.0-0 \
        nghttp2 \
        libssl1.1 \
        libsqlite3-0 \
        openssl \
        pkg-config \
        pulseaudio \
        python \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/avs/Integration/database

COPY startup.sh /usr/bin/
ENTRYPOINT ["/usr/bin/startup.sh"]
CMD ["/bin/bash"]