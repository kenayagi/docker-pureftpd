FROM debian:stretch

# Update
RUN export DEBIAN_FRONTEND=noninteractive && apt update && apt upgrade

# Install
RUN apt -y install pure-ftpd

