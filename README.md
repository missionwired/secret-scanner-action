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
    scan-path: './src'                          # Directory to scan (default: .)
    upload-sarif: 'true'                        # Upload to Code Scanning (default: true)
    exclude-files-regex: '.*/test/.*|.*\.map$'  # Exclude files by regex (default: '')
    scan-all-files: 'true'                      # Scan all files including untracked (default: true)
    fail-on-detection: 'true'                   # Fail workflow if secrets found (default: true)
    debug-mode: 'false'                         # Enable verbose logging (default: false)
    always-upload: 'false'                      # Upload SARIF even with 0 findings (default: false)
    wait-for-processing: 'true'                 # Wait for SARIF ingestion (default: true)
    checkout-path: ${{ github.workspace }}      # Repository checkout path (default: workspace)
    detect-secrets-version: ''                  # Pin version, e.g., '1.5.0' (default: latest)
```

### Input Notes
- `scan-all-files` defaults to `true` and automatically excludes `.git/` to prevent scanning git history
- Pin `detect-secrets-version` (e.g., `1.5.0`) for reproducibility
- `debug-mode`: Enable for troubleshooting issues with the action. Shows detailed scan commands, count diagnostics, and uploads SARIF as an artifact. Set to `'true'` when reporting bugs or investigating unexpected behavior.

## Outputs

- `secret_count`: Total number of findings detected

## What Gets Detected

This action detects hardcoded secrets including:

- **Cloud Providers**: AWS Access Keys, Azure Storage Keys, IBM Cloud IAM Keys
- **APIs & Services**: GitHub/GitLab tokens, OpenAI keys, Stripe keys, SendGrid keys
- **Communication**: Discord/Telegram bot tokens, Slack tokens
- **Package Managers**: NPM tokens, PyPI tokens
- **Authentication**: JWT tokens, Basic Auth credentials, Private keys

**Disabled Plugins** (to reduce false positives): `ArtifactoryDetector`, `Base64HighEntropyString`, `HexHighEntropyString`, `KeywordDetector`

## Viewing Results

When secrets are detected, view them in your repository's **Security** tab → **Code scanning alerts** (category: `detect-secrets`).

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
