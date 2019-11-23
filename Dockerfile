FROM node:12.8.0-alpine
RUN apk update && \
    apk add --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/community \
        libstdc++ g++ gnu-libiconv make cmake git && \
        git clone https://github.com/DCMTK/dcmtk.git && \
#    cd dcmtk && \
#    ./configure && \
#    make all && \
#    make install && \
#    make distclean && \
# start build
    mkdir dcmtk-3.6.4-build && \
    cd dcmtk-3.6.4-build && \
    cmake ../dcmtk && \
    make -j8 && \
    make DESTDIR=../dcmtk-3.6.4-install install && \
# end build
    cd .. && \
    rm -r dcmtk && \
    apk del g++ make git && \
    rm /var/cache/apk/*

ENV DCMDICTPATH /dcmtk-3.6.4-install/usr/local/share/dcmtk/dicom.dic
