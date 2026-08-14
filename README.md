# sirius-container

Container image for the [SIRIUS](https://github.com/sirius-ms/sirius) metabolomics
annotation CLI, published to GitHub Container Registry (ghcr.io) as a Docker image.
All images are signed with Cosign (Sigstore) and carry SLSA provenance attestations.

The `ubuntu:22.04` base (glibc 2.35) is chosen so the bundled CBC solver's native
libgfortran/liblapack (which require GLIBC_2.29) runs on hosts with glibc < 2.29,
e.g. CentOS/RHEL 8.

## Versioning

- The `VERSION` file is the default version for `main` builds (currently `6.3.12`).
- Release tags follow `v<version>` or `v<version>-<arch>`, e.g. `v6.3.12` or
  `v6.3.12-linux-x64`. Tags drive the `:latest` / `:<version>` image tags.

## Building locally

```bash
# Default version (from VERSION file)
docker build -t sirius:latest .

# Custom version / architecture
docker build --build-arg SIRIUS_VERSION=6.3.12 \
             --build-arg SIRIUS_ARCH=linux-x64 \
             -t sirius:6.3.12 .

docker run --rm sirius:latest --help
```

## Pulling from ghcr.io (recommended)

```bash
# Docker
docker pull ghcr.io/exfab/sirius-container/sirius:6.3.12

# Apptainer/Singularity on an HPC node (converts to a .sif on the fly)
apptainer pull sirius.sif docker://ghcr.io/exfab/sirius-container/sirius:6.3.12
apptainer run sirius.sif --help
```

Tags published by CI:

| Event            | Tags                                        |
|------------------|---------------------------------------------|
| push to `main`   | `:latest`, `:main`                          |
| tag `v<ver>`     | `:<version>-<arch>`, `:<version>`, `:latest` |

If this repository is forked, substitute `exfab/sirius-container` with the fork's
`owner/repo` (CI derives the path from `github.repository` automatically).

## Verifying an image

Images are signed with Cosign using GitHub's OIDC identity (no key management).

```bash
# Verify the signature against the GitHub OIDC issuer
cosign verify \
  ghcr.io/exfab/sirius-container/sirius:6.3.12 \
  --certificate-identity-regexp 'https://github.com/exfab/sirius-container/.github/workflows/build.yml' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com'

# Verify the SLSA provenance attestation
cosign verify-attestation --type slsaprovenance1 \
  ghcr.io/exfab/sirius-container/sirius:6.3.12
```

## Automated builds

GitHub Actions (`build.yml`) builds and pushes the image on every push to `main`,
every `v*` tag, and on manual `workflow_dispatch`. It then signs the image with
Cosign and attaches an SLSA provenance attestation. No repository secrets are
required — signing uses the workflow's OIDC token.
