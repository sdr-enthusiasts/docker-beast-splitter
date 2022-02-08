FROM ghcr.io/sdr-enthusiasts/docker-baseimage:base

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
    make -j $(nproc) && \
    popd && \
    cp -v /src/beast-splitter/beast-splitter /usr/local/bin/beast-splitter && \
    # Clean up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/*