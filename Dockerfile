FROM ubuntu:22.04

# Install all build prerequisites + zstd
RUN apt-get update && apt-get install -y \
    build-essential gcc g++ make libc6-dev \
    gawk unzip file python3 python3-distutils python3-venv \
    perl rsync wget tar xz-utils ca-certificates jq zstd \
 && apt-get clean

WORKDIR /build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]