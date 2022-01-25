FROM ubuntu:focal

# Install dependencies
RUN apt-get update \
    && apt-get -y install --no-install-recommends sudo ca-certificates curl

# Copy installation scripts
COPY scripts/* /var/devsetup/

WORKDIR /var/devsetup/

RUN chmod +x /var/devsetup/*.sh \
    && /var/devsetup/install-nvim.sh 

WORKDIR /
