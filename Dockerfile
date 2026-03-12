# Global build arguments (declared before any FROM)
ARG NODE_VER
ARG DCMTK_VER

# ============ Builder stage ============
FROM alpine:3.18 AS builder

# Re-declare build args for this stage
ARG DCMTK_VER

WORKDIR /usr/src/app

# Install dev packages so we can compile with XML/zlib/PNG/TIFF support
RUN apk update && \
    apk add --no-cache \
        g++ \
        make \
        cmake \
        git \
        rsync \
        # XML support
        libxml2-dev \
        # zlib support
        zlib-dev \
        # PNG support
        libpng-dev \
        # TIFF support
        tiff-dev

# Get DCMTK source
RUN git clone https://github.com/DCMTK/dcmtk.git dcmtk-src \
    && cd dcmtk-src \
    && git checkout tags/DCMTK-$DCMTK_VER \
    && cd .. \
    && mkdir dcmtk-install

# Configure & build DCMTK with libxml2 (xml), zlib, PNG, TIFF, and codec support
RUN cd dcmtk-install \
    && cmake \
       -DDCMTK_WITH_XML=ON \
       -DDCMTK_WITH_ZLIB=ON \
       -DDCMTK_WITH_PNG=ON \
       -DDCMTK_WITH_TIFF=ON \
       -DDCMTK_WITH_IJG8=ON \
       -DDCMTK_WITH_IJG12=ON \
       -DDCMTK_WITH_IJG16=ON \
       -DDCMTK_WITH_CHARLS=ON \
       -DDCMTK_USE_DCMDICTPATH=ON \
       ../dcmtk-src \
    && make -j"$(nproc)" \
    && make install

# Collect the resulting DCMTK files into /out
RUN mkdir /out \
    && rsync --files-from=dcmtk-install/install_manifest.txt / /out

# ============ Final stage ============
FROM node:$NODE_VER

# Re-declare build args for this stage
ARG NODE_VER
ARG DCMTK_VER

# For Alpine-based 'node' images, ensure libxml2, zlib, libpng & libtiff are installed at runtime:
# (If the base node image is Debian/Ubuntu, you'd do apt-get install libxml2 zlib1g, etc.)
RUN apk update && \
    apk add --no-cache \
        libxml2 \
        zlib \
        libpng \
        tiff

# Clean up any caches (for Alpine):
RUN rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Copy DCMTK artifacts from the builder
COPY --from=builder /out/ /

# Create a versioned symlink to the installed dictionary location
RUN ln -s /usr/local/share/dcmtk-$DCMTK_VER /usr/local/share/dcmtk

# Set DCMDICTPATH so that DCMTK tools can find dicom.dic
ENV DCMDICTPATH=/usr/local/share/dcmtk/dicom.dic

# set an entrypoint or CMD here
# CMD ["sh"]
