ARG NODE_VER

FROM alpine:3.18 AS builder

ARG DCMTK_VER

WORKDIR /usr/src/app

# Install necessary packages including libxml2 and its development files
RUN apk update && \
    apk add --no-cache \
        libstdc++ \
        g++ \
        gnu-libiconv \
        make \
        cmake \
        git \
        rsync \
        libxml2 \
        libxml2-dev

# Clone the DCMTK repository and checkout the specified version
RUN git clone https://github.com/DCMTK/dcmtk.git dcmtk-src \
    && cd dcmtk-src \
    && git checkout tags/DCMTK-$DCMTK_VER \
    && cd .. \
    && mkdir dcmtk-install

# Configure and build DCMTK with libxml support
RUN cd dcmtk-install \
    && cmake -DDCMTK_USE_DCMDICTPATH:BOOL=TRUE -DDCMTK_WITH_LIBXML2:BOOL=ON ../dcmtk-src \
    && make -j$(nproc)

# Install DCMTK
RUN cd dcmtk-install \
    && make install

# Prepare the output directory
RUN mkdir /out \
    && rsync --files-from=dcmtk-install/install_manifest.txt / /out

# Final stage
FROM node:$NODE_VER

# Define build arguments for the final stage
ARG DCMTK_VER

# Remove old cache files from the base image
RUN apk cache clean \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /root/.npm \
    && rm -rf /root/.cache \
    && find / -type f -name "*.log" -delete

# Copy the built DCMTK files from the builder stage
COPY --from=builder /out/ /

# (Optional) If you want to use a symbolic link for the DICOM dictionary,
# you can uncomment and adjust the following commands:
# RUN mkdir -p /usr/local/share/dcmtk
# RUN ln -s /usr/local/share/dcmtk-$DCMTK_VER/dicom.dic /usr/local/share/dcmtk/dicom.dic

# Set the DCMDICTPATH environment variable
ENV DCMDICTPATH /usr/local/share/dcmtk-$DCMTK_VER/dicom.dic
