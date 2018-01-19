FROM rapid7/rapid7-vm-installer:latest AS build

# Set environment variable for varfile
ENV R7_VARFILE Rapid7Setup-Linux64.varfile

WORKDIR /work

COPY $R7_VARFILE /tmp/

# Download and install Nexpose Engine
RUN /tmp/$R7_VM_BIN -q -varfile=/tmp/$R7_VARFILE  | grep -v 'Do not leave the Address field blank.'

# Copy configuration and startup scripts
COPY work/ .

# Multi-stage build, final section
FROM ubuntu:16.04
WORKDIR /work
# Copy product installation and work files
COPY --from=build /opt/rapid7 /opt/rapid7
COPY --from=build /work .
COPY --from=build VERSION .
# Expose Console Port for Console -> Engine communication
EXPOSE 40814
# Start Nexpose Engine and tail logs
CMD ["./run.sh"]
