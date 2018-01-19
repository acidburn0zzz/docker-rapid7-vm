FROM ubuntu:16.04

# Set environment variables
ENV R7_VM_VERSION 6.5.2
ENV R7_VM_BIN Rapid7Setup-Linux64.bin
ENV R7_VM_DOWNLOAD_MD5 384f41147a8cefab1230f6690764f255

ADD VERSION .

# Get Prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    && rm -r /var/lib/apt/lists/*

# Download InsightVM/Nexpose
RUN curl -Lo /tmp/$R7_VM_BIN http://download2.rapid7.com/download/InsightVM/ReleaseProduct-$R7_VM_VERSION/$R7_VM_BIN \
    && echo "$R7_VM_DOWNLOAD_MD5 /tmp/$R7_VM_BIN" | md5sum -c - \
    && chmod +x /tmp/$R7_VM_BIN
