FROM ghcr.io/sdr-enthusiasts/docker-baseimage:base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,SC2086,SC2039,SC2068
RUN --mount=type=bind,source=patches,target=/patches \
    set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    # Required for downloading stuff & readsb database updates
    TEMP_PACKAGES+=(git) && \
    # Required for building
    TEMP_PACKAGES+=(build-essential) && \
    # Dependencies for beast-splitter: the distribution's default Boost. Runtime
    # libraries are resolved after apt-get update (runtime_pkg below).
    TEMP_PACKAGES+=(libboost-dev) && \
    TEMP_PACKAGES+=(libboost-regex-dev) && \
    TEMP_PACKAGES+=(libboost-program-options-dev) && \
    # Dependencies for viewadsb
    TEMP_PACKAGES+=(protobuf-c-compiler) && \
    TEMP_PACKAGES+=(libncurses-dev) && \
    TEMP_PACKAGES+=(librrd-dev) && \
    TEMP_PACKAGES+=(libprotobuf-c-dev) && \
    KEPT_PACKAGES+=(libprotobuf-c1) && \
    KEPT_PACKAGES+=(libncurses6) && \
    # Install packages
    apt-get update && \
    # Runtime library packages are renamed with Debian releases (soname bumps), so
    # resolve the one each -dev package depends on instead of naming a version.
    runtime_pkg() { \
    p="$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances "$1" | sed -nE "s/^ *Depends: ($2)\$/\1/p" | head -n1)"; \
    if [ -z "$p" ]; then echo "no runtime package matching $2 for $1" >&2; return 1; fi; \
    echo "$p"; \
    } && \
    KEPT_PACKAGES+=("$(runtime_pkg libboost-regex-dev 'libboost-regex[0-9.]+')") && \
    KEPT_PACKAGES+=("$(runtime_pkg libboost-program-options-dev 'libboost-program-options[0-9.]+')") && \
    # Boost.System is header-only since Boost 1.69 and its stub library is gone in
    # 1.89+. Unpatched beast-splitter links it, so install it where it still exists.
    if apt-cache show libboost-system-dev >/dev/null 2>&1; then \
    TEMP_PACKAGES+=(libboost-system-dev) && \
    KEPT_PACKAGES+=("$(runtime_pkg libboost-system-dev 'libboost-system[0-9.]+')"); \
    fi && \
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
    # Boost 1.87 removed asio::io_service and friends, which beast-splitter v11.1
    # still uses. Port it only where needed: when the source still uses io_service
    # and the installed Boost no longer has it. Stable (Boost 1.83) builds upstream
    # unchanged, and the patch is skipped once an upstream release is fixed.
    if grep -q "boost/asio/io_service.hpp" beast_input.h && [ ! -e /usr/include/boost/asio/io_service.hpp ]; then \
    git apply --verbose /patches/beast-splitter-boost-1.87.patch; \
    fi && \
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
