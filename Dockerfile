FROM node:14.15.1-alpine3.12
ARG DCMTK_VER=3.6.6

RUN apk update && \
    apk add --no-cache \
        # not sure why we add a repository
        # --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/community \
        libstdc++ g++ gnu-libiconv make cmake git \
    && git clone https://github.com/DCMTK/dcmtk.git dcmtk-src \
    && cd dcmtk-src \
    && git checkout tags/DCMTK-$DCMTK_VER \
    && cd .. \
    && mkdir dcmtk-install \
    && cd dcmtk-install \
    && cmake DCMTK_ENABLE_BUILTIN_DICTIONARY:BOOL=TRUE ../dcmtk-src \
    && make -j16 \
    # && cd dcmtk-install \
    && make install \
# end build
    && cd .. \
    && rm -r dcmtk-src \
    && apk del g++ make git \
    && rm /var/cache/apk/*

ENV DCMDICTPATH /usr/local/share/dcmtk/dicom.dic
