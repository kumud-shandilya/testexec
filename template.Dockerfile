# syntax=docker/dockerfile-upstream:1.4.0
# This is a template Dockerfile for the bundle's invocation image
# You can customize it to use different base images, install tools and copy configuration files.
#
# Porter will use it as a template and append lines to it for the mixins
# and to set the CMD appropriately for the CNAB specification.
#
# Add the following line to porter.yaml to instruct Porter to use this template
# dockerfile: template.Dockerfile

# You can control where the mixin's Dockerfile lines are inserted into this file by moving the "# PORTER_*" tokens
# another location in this file. If you remove a token, its content is appended to the end of the Dockerfile.

# Porter targets linux/amd64 by default. Change the --platform flag to target a different platform
FROM --platform=linux/amd64 debian:stable-slim
WORKDIR /app
# COPY  --link --chmod=0755 /bin/release/net7.0/ /app
# COPY  --link --chmod=0755 /action.yaml /app
# RUN echo $PATH
# ENV PATH="$PATH:/app/bin/ubuntu.16.04-x64"
# RUN echo $PATH
# PORTER_INIT

# RUN chmod +x /bin/release/net7.0/

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y ca-certificates
RUN apt-get update && apt-get install wget -y
RUN apt-get update && apt-get install -y gpg
RUN wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o microsoft.asc.gpg
RUN mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
RUN wget https://packages.microsoft.com/config/debian/11/prod.list
RUN mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
RUN chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN chown root:root /etc/apt/sources.list.d/microsoft-prod.list
RUN apt-get update && \
    apt-get install -y dotnet-sdk-7.0

# PORTER_MIXINS

# Use the BUNDLE_DIR build argument to copy files into the bundle's working directory
COPY --link . ${BUNDLE_DIR}
