ARG NODE_VER

FROM alpine:3.18 AS builder

ARG DCMTK_VER

WORKDIR /usr/src/app

# Install necessary packages
RUN apk update && \
    apk add --no-cache \
        libstdc++ g++ gnu-libiconv make cmake git rsync

# Clone the DCMTK repository and checkout the specified version
RUN git clone https://github.com/DCMTK/dcmtk.git dcmtk-src \
    && cd dcmtk-src \
    && git checkout tags/DCMTK-$DCMTK_VER \
    && cd .. \
    && mkdir dcmtk-install

# Configure and build DCMTK
RUN cd dcmtk-install \
    && cmake DCMTK_USE_DCMDICTPATH:BOOL=TRUE ../dcmtk-src \
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

# Copy the built DCMTK files from the builder stage
COPY --from=builder /out/ /

# Create the directory for the symbolic link if it doesn't exist
RUN mkdir -p /usr/local/share/dcmtk

# Create the symbolic link in the final stage
RUN ln -s /usr/local/share/$DCMTK_VER/dicom.dic /usr/local/share/dcmtk/dicom.dic

# Set the DCMDICTPATH environment variable to the symlink
ENV DCMDICTPATH /usr/local/share/dcmtk/dicom.dic
