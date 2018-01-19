FROM rapid7/rapid7-vm-installer:latest AS build

# Set up environment variable for varfile
ENV R7_VARFILE Rapid7Setup-Linux64.varfile

# Create directories for configuration
WORKDIR /work

# Copy varfile to tmp directory
COPY $R7_VARFILE /tmp/

# Launch console installation
RUN /tmp/$R7_VM_BIN -q -varfile=/tmp/$R7_VARFILE

# Copy configuration and startup scripts
COPY work/ .

# Multi-stage build, final section
FROM ubuntu:16.04
# Set environment variables for API
ENV API_USER nxadmin
ENV API_PASSWORD nxpassword
ENV CONSOLE_PORT 3780
WORKDIR /work
# Install curl necessary for activation and seeding
RUN apt-get update && apt-get install -y \
    curl \
    && rm -r /var/lib/apt/lists/*
# Copy product installation and work files
COPY --from=build /opt/rapid7 /opt/rapid7
COPY --from=build /work .
COPY --from=build VERSION .
# Expose Console Port for web/api interface
EXPOSE 3780
# Expose for Console Listener for pairing
EXPOSE 40815
# Start Nexpose Console and tail logs
CMD ["./run.sh"]
