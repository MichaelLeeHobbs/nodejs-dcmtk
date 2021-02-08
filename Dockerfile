FROM node:14.15.1-alpine3.12
RUN apk update && \
    apk add --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/community \
        libstdc++ g++ gnu-libiconv make cmake git && \
        git clone https://github.com/DCMTK/dcmtk.git dcmtk-src && \
        cd dcmtk-src && \
        git checkout tags/DCMTK-3.6.4 && \
        cd .. && \
#    cd dcmtk && \
#    ./configure && \
#    make all && \
#    make install && \
#    make distclean && \
# start build
    mkdir dcmtk-build && \
    cd dcmtk-build && \
    cmake ../dcmtk-src && \
    make -j8 && \
    make DESTDIR=../dcmtk install && \
# end build
    cd .. && \
    rm -r dcmtk-src && \
    apk del g++ make git && \
    rm /var/cache/apk/*

ENV DCMDICTPATH /dcmtk/usr/local/share/dcmtk/dicom.dic
