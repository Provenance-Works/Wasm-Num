# Environment Variables

> **Audience**: Users, Operators

Environment variables that affect wasm-num builds and development.

## Lake / Lean Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LAKE_HOME` | `~/.elan/lake` | Lake cache / packages directory |
| `LEAN_PATH` | (auto) | Lean module search path. Managed by Lake; rarely set manually. |
| `ELAN_HOME` | `~/.elan` | elan toolchain manager installation directory |
| `ELAN_TOOLCHAIN` | (from `lean-toolchain`) | Override toolchain. Not recommended. |
| `MATHLIB_CACHE_URL` | (default Mathlib CDN) | Custom URL for pre-built Mathlib oleans |

## Build Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LAKE_WORKERS` | CPU count | Number of parallel Lake build workers |

## CI Variables

These are set by CI environments, not by users:

| Variable | Context | Description |
|----------|---------|-------------|
| `CI` | GitHub Actions / GitLab CI | Indicates CI environment |
| `GITHUB_TOKEN` | GitHub Actions | Authentication for GitHub API |
| `GITLAB_CI` | GitLab CI | Indicates GitLab CI environment |

## See Also

- [Configuration Reference](configuration.md) — file-based configuration
- [Installation](../getting-started/installation.md) — setup instructions
- [Troubleshooting](../guides/troubleshooting.md) — common environment issues
