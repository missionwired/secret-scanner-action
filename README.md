# Detect Secrets Scanner Action

A GitHub Action that scans your codebase for hardcoded secrets using [detect-secrets](https://github.com/Yelp/detect-secrets) and uploads findings to GitHub Code Scanning.

## Quick Start

```yaml
name: Secret Scanning
on: [push, pull_request]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
      actions: read
    steps:
      - uses: actions/checkout@v4
      - uses: missionwired/secret-scanning-action@main
```

## Configuration

```yaml
- uses: missionwired/secret-scanning-action@main
  with:
    scan-path: '.'                      # Directory to scan (default: .)
    upload-sarif: 'false'               # Upload to Code Scanning (default: false)
    fail-on-detection: 'true'           # Fail workflow if secrets found (default: true)
    debug-mode: 'false'                 # Enable verbose logging (default: false)
```

### Input Notes
- `scan-path`: Directory to scan (default: `.` - entire repository)
- `upload-sarif`: Upload results to GitHub Code Scanning (default: `false`)
- `fail-on-detection`: Fail workflow if verified secrets found (default: `true`)
- `debug-mode`: Enable verbose logging and SARIF artifact upload (default: `false`)

## Outputs

- `verified_count`: Number of verified secrets detected

## What Gets Detected

This action scans for **verified secrets only** - live credentials that can be validated through network calls. Only actively valid secrets trigger alerts.

## Viewing Results

When `upload-sarif: 'true'` is set and secrets are detected, view them in your repository's **Security** tab → **Code scanning alerts** (category: `detect-secrets`).

## Permissions Required

```yaml
permissions:
  security-events: write  # Required for SARIF upload
  contents: read
  actions: read
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Open a pull request

## Versioning

We use semantic versioning. Reference `@main` for the latest version or pin to a specific tag for stability.
