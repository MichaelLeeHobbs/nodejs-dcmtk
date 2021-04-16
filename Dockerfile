FROM node:14.15.1-alpine3.12
ARG DOCKER_TAG=3.6.6
ARG DCMTK_ENABLE_BUILTIN_DICTIONARY=ON

RUN apk update && \
    apk add --update-cache \
        # not sure why we add a repository
        --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/community \
        libstdc++ g++ gnu-libiconv make cmake git
RUN git clone https://github.com/DCMTK/dcmtk.git dcmtk-src \
    && cd dcmtk-src \
    && git checkout tags/DCMTK-$DOCKER_TAG \
    && cd .. \
    && mkdir dcmtk-install \
    && cd dcmtk-install \
    && cmake DCMTK_ENABLE_BUILTIN_DICTIONARY:BOOL=TRUE ../dcmtk-src \
    && make -j16
RUN pwd
RUN cd dcmtk-install && make install
# end build
RUN cd .. \
    && rm -r dcmtk-src \
    && apk del g++ make git \
    && rm /var/cache/apk/*

ENV DCMDICTPATH /usr/local/share/dcmtk/dicom.dic
