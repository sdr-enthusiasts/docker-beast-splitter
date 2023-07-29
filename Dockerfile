FROM ghcr.io/sdr-enthusiasts/docker-baseimage:base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    # Required for downloading stuff & readsb database updates
    TEMP_PACKAGES+=(git) && \
    # Required for building
    TEMP_PACKAGES+=(build-essential) && \
    # Dependencies for beast-splitter
    TEMP_PACKAGES+=(libboost1.74-dev) && \
    KEPT_PACKAGES+=(libboost-system1.74.0) && \
    TEMP_PACKAGES+=(libboost-system1.74-dev) && \
    KEPT_PACKAGES+=(libboost-regex1.74.0) && \
    TEMP_PACKAGES+=(libboost-regex1.74-dev) && \
    KEPT_PACKAGES+=(libboost-program-options1.74.0) && \
    TEMP_PACKAGES+=(libboost-program-options1.74-dev) && \
    # Dependencies for viewadsb
    TEMP_PACKAGES+=(protobuf-c-compiler) && \
    TEMP_PACKAGES+=(libncurses-dev) && \
    TEMP_PACKAGES+=(librrd-dev) && \
    TEMP_PACKAGES+=(libprotobuf-c-dev) && \
    KEPT_PACKAGES+=(libprotobuf-c1) && \
    KEPT_PACKAGES+=(libncurses6) && \
    # Install packages
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ${KEPT_PACKAGES[@]} \
    ${TEMP_PACKAGES[@]} \
    && \
    # beast-splitter: get latest release tag without cloning repo
    BRANCH_BEAST_SPLITTER=$( \
    git \
    -c 'versionsort.suffix=-' \
    ls-remote \
    --tags \
    --sort='v:refname' \
    'https://github.com/flightaware/beast-splitter.git' \
    | grep -v '\^' \
    | cut -d '/' -f 3 \
    | grep '^v.*' \
    | tail -1) \
    && \
    # beast-splitter: fetch, build & install
    git clone \
    --branch "$BRANCH_BEAST_SPLITTER" \
    --depth 1 \
    --single-branch \
    https://github.com/flightaware/beast-splitter.git \
    /src/beast-splitter \
    && \
    pushd /src/beast-splitter && \
    make -j "$(nproc)" && \
    popd && \
    cp -v /src/beast-splitter/beast-splitter /usr/local/bin/beast-splitter && \
    # viewadsb: get latest release tag without cloning repo
    # get simply the latest committed version from the dev (=default) branch rather than the latest tag
    # this is because Mictronic doesn't update their labels very often, and important bug fixes are needlessly delayed
    BRANCH_READSB="dev" && \
    # viewadsb: clone repo
    git clone \
    --branch "$BRANCH_READSB" \
    --depth 1 \
    --single-branch \
    'https://github.com/Mictronics/readsb-protobuf.git' \
    /src/readsb-protobuf \
    && \
    # viewadsb: build & install (note, -j seems to have issues, so not using...)
    pushd /src/readsb-protobuf && \
    make viewadsb && \
    popd && \
    cp -v /src/readsb-protobuf/viewadsb /usr/local/bin/viewadsb && \
    # Clean up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
    # Write container version
    echo "$BRANCH_BEAST_SPLITTER" > /CONTAINER_VERSION && \
    cat /CONTAINER_VERSION

COPY rootfs/ /
