# =============================================================================
# SIRIUS metabolomics annotation CLI (https://github.com/sirius-ms/sirius)
#
# Build (defaults read from VERSION file / linux-x64 arch):
#   docker build --build-arg SIRIUS_VERSION=$(cat VERSION) -t sirius:latest .
#
# Build a specific version / architecture:
#   docker build --build-arg SIRIUS_VERSION=6.3.12 \
#                --build-arg SIRIUS_ARCH=linux-x64 \
#                -t sirius:6.3.12 .
#
# Run:
#   docker run --rm sirius:latest --help
#
# Run on an HPC node with Apptainer/Singularity (converts on the fly):
#   apptainer pull sirius.sif docker://ghcr.io/exfab/sirius-container/sirius:6.3.12
#   apptainer run  sirius.sif --help
# =============================================================================

ARG SIRIUS_VERSION=6.3.12
ARG SIRIUS_ARCH=linux-x64

# ubuntu:22.04 base (glibc 2.35) so the bundled CBC solver's native
# libgfortran/liblapack (which require GLIBC_2.29) runs on hosts with
# glibc < 2.29, e.g. CentOS/RHEL 8.
FROM ubuntu:22.04

ARG SIRIUS_VERSION
ARG SIRIUS_ARCH

LABEL org.opencontainers.image.title="SIRIUS"
LABEL org.opencontainers.image.description="SIRIUS metabolomics annotation CLI"
LABEL org.opencontainers.image.url="https://github.com/sirius-ms/sirius"
LABEL org.opencontainers.image.source="https://github.com/exfab/sirius-container"
LABEL org.opencontainers.image.licenses="AGPL-3.0"

ENV SIRIUS_VERSION=${SIRIUS_VERSION} \
    SIRIUS_ARCH=${SIRIUS_ARCH}

# System dependencies needed by the bundled native solver (BLAS/LAPACK).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        unzip \
        liblapack3 \
        libblas3 && \
    rm -rf /var/lib/apt/lists/*

# Download the unmodified upstream release and install under /opt/sirius.
RUN SIRIUS_ZIP="sirius-${SIRIUS_VERSION}-${SIRIUS_ARCH}.zip" \
 && SIRIUS_URL="https://github.com/sirius-ms/sirius/releases/download/v${SIRIUS_VERSION}/${SIRIUS_ZIP}" \
 && mkdir -p /opt/sirius \
 && wget -q -O "/tmp/${SIRIUS_ZIP}" "${SIRIUS_URL}" \
 && unzip -q "/tmp/${SIRIUS_ZIP}" -d /tmp/sirius_extract \
 && (mv /tmp/sirius_extract/sirius/* /opt/sirius/ 2>/dev/null || mv /tmp/sirius_extract/*/* /opt/sirius/) \
 && rm -rf "/tmp/${SIRIUS_ZIP}" /tmp/sirius_extract

ENV PATH="/opt/sirius/bin:${PATH}"

WORKDIR /data
ENTRYPOINT ["/opt/sirius/bin/sirius"]
