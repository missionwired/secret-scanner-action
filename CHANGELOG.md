# Changelog

## v1.1.0 - 2025-10-28
### Added
- Test harness (`test-transform.sh`) validating zero, single, and multiple secret scenarios.
- Local guidance in README for adding dummy secrets for testing.

### Changed
- Action now calculates `secret_count` using robust aggregation across all files (prevents under-count when multiple files have findings).
- Hardened `detect-secrets-to-sarif.jq` to tolerate missing keys, empty results; guarantees `rules` & `results` arrays.
- Improved SARIF diagnostics in debug mode (raw vs SARIF count cross-check).
- README updated: correct default `scan-path`, output semantics, disabled plugin rationale.

### Fixed
- Previous flawed counting pattern that only captured last file's findings.

### Notes
- Major tag `v1` should be force-updated to point to `v1.1.0` after creating the annotated tag.
- No breaking inputs; safe minor version bump.

## v1.0.1 - 2025-10-27
- Initial refinements after `v1` release.

## v1.0.0 - 2025-10-24
- Initial release.
