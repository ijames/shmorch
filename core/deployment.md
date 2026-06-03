# Deployment Manifest Sync

↑ [core/](index.md) · referenced from: `shmorch-core.md` Safety Rules

---

## The Rule

**The dev environment and the deployment bundle are separate artifacts.** Adding a package to a project definition file does NOT automatically update the file that the deployment system reads.

After any dependency change, sync all deployment manifests before committing.

| Project type | Definition file | Deployment manifest | Sync command |
|---|---|---|---|
| Python + uv + SAM/Lambda | `pyproject.toml` | `requirements.txt` | `uv export --no-hashes --no-dev -o requirements.txt` |
| Python + pip | `requirements.in` | `requirements.txt` | `pip-compile requirements.in` |
| Node | `package.json` | `package-lock.json` / `pnpm-lock.yaml` | `npm install` / `pnpm install` (auto) |
| Docker | `Dockerfile` | image layers | rebuild and test the image |

**Verification step:** After syncing, confirm the new package appears in the manifest before committing:
```bash
grep newpackage requirements.txt
```

---

## Cross-Platform Wheel Constraint

A package that installs locally (x86_64 macOS) may have no binary wheel for the deployment target (arm64 Lambda, aarch64 container).

When adding a dependency that runs in a different architecture:
1. Check the deployment build output — a missing wheel fails the build with a clear error
2. If a wheel is missing for the target platform, pin to the latest version that does have one
3. Check transitive dependencies too — version bumps can silently drop platform support

**Common Lambda arm64 gotcha:** SAM builds with `--platform manylinux2014_aarch64`. A package may be on PyPI but not have that wheel. Check by attempting `sam build` — the error names the package. Pin with `==<last-working-version>` in `pyproject.toml`, then re-export.
