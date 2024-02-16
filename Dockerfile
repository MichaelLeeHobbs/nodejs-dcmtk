ARG NODE_VER

FROM node:$NODE_VER AS builder

ARG DCMTK_VER

RUN apk update && \
    apk add --no-cache \
        libstdc++ g++ gnu-libiconv make cmake git rsync
WORKDIR /usr/src/app
RUN git clone https://github.com/DCMTK/dcmtk.git dcmtk-src  \
    && cd dcmtk-src \
    && git checkout tags/DCMTK-$DCMTK_VER \
    && cd .. \
    && mkdir dcmtk-install

#RUN cd dcmtk-install && cmake DCMTK_USE_DCMDICTPATH:BOOL=TRUE CMAKE_INSTALL_PREFIX:PATH=/out ../dcmtk-src  \
RUN cd dcmtk-install && cmake DCMTK_USE_DCMDICTPATH:BOOL=TRUE ../dcmtk-src  \
    && make -j16
RUN cd dcmtk-install && make install


RUN mkdir /out && rsync --files-from=dcmtk-install/install_manifest.txt / /out

FROM node:$NODE_VER
COPY --from=builder /out/ /

ENV DCMDICTPATH /usr/local/share/dcmtk/dicom.dic
