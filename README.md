Build sirius-ms container for https://github.com/sirius-ms/sirius

## Building

Default build (uses version from `VERSION` file):
```bash
apptainer build sirius.sif sirius.def
```

Custom version / architecture:
```bash
apptainer build \
  --build-arg SIRIUS_VERSION=6.3.12 \
  --build-arg SIRIUS_ARCH=linux-x64 \
  sirius.sif sirius.def
```

## Automated builds

GitHub Actions builds the `.sif` image on every push to `main`, pull request, and version tag.
To trigger a release, push a tag following the pattern `v<version>` or `v<version>-<arch>`:

```bash
git tag v6.3.12          # uses default arch (linux-x64)
git tag v6.3.12-linux-x64
git push --tags
```

The workflow uploads the image and integrity files as a GitHub Release asset.

## Verifying a downloaded image

### SHA256 checksum

```bash
sha256sum -c sirius-6.3.12-linux-x64.sif.sha256
```

### Detached GPG signature (when available)

Import the project's public key, then verify:
```bash
gpg --import <public-key.asc>
gpg --verify sirius-6.3.12-linux-x64.sif.asc sirius-6.3.12-linux-x64.sif
```

### Embedded Apptainer signature (when available)

```bash
apptainer verify sirius-6.3.12-linux-x64.sif
```

## Signing setup (repository maintainers)

To enable GPG signing in CI, add the following repository secrets:

| Secret | Description |
|---|---|
| `GPG_PRIVATE_KEY` | ASCII-armored GPG private key (`gpg --export-secret-keys --armor <fingerprint>`) |
| `GPG_PASSPHRASE` | Passphrase protecting the key |

Both the detached `.asc` signature and the embedded Apptainer signature are produced only when
these secrets are present; the build succeeds without them.
