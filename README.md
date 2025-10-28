# Detect Secrets Scanner Action

A GitHub Action that scans your codebase for hardcoded secrets using [detect-secrets](https://github.com/Yelp/detect-secrets), converts results to SARIF, and optionally uploads findings to GitHub Code Scanning for visibility and triage.

## Features

-  **Comprehensive Secret Detection**: Uses detect-secrets to identify hardcoded secrets (API keys, tokens, passwords, etc.)
-  **SARIF Integration**: Converts results to SARIF format for GitHub Code Scanning
-  **Configurable**: Customize scan paths, exclusions, and failure behavior
-  **Smart Defaults**: Disables noisy plugins to reduce false positives
-  **Clear Reporting**: Provides detailed output with secret counts and actionable messages

## Usage

### Basic Usage

```yaml
name: Secret Scanning
on: [push, pull_request]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    permissions:
      security-events: write  # Required for SARIF upload
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: missionwired/secret-scanning-action@v1
```

### Advanced Configuration Example

```yaml
- uses: missionwired/secret-scanning-action@v1
  with:
    # Scan specific directory
    scan-path: './src'
    
    # Skip SARIF upload 
    upload-sarif: 'false'
    
    # Exclude test files and minified JavaScript
    exclude-files-regex: '.*/test/.*|.*\.min\.js'
    
    # Don't fail the build, just warn
    fail-on-detection: 'false'
```

## Inputs

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `scan-path` | Directory to scan (defaults repo root) | `.` | No |
| `upload-sarif` | Upload SARIF to Code Scanning | `true` | No |
| `exclude-files-regex` | Single regex for excluding files | `""` | No |
| `fail-on-detection` | Fail job when findings > 0 | `true` | No |
| `debug-mode` | Emit extra diagnostic output | `false` | No |
| `always-upload` | Upload SARIF even if 0 findings | `false` | No |
| `wait-for-processing` | Wait for SARIF ingestion to finish | `true` | No |
| `checkout-path` | Path repo was checked out to | `${{ github.workspace }}` | No |
| `detect-secrets-version` | Pin detect-secrets version (blank = latest) | `` | No |

## Outputs

Outputs:
- `secret_count`: Total number of findings (robustly summed across all files; empty = 0)

### Input Notes
- Prefer pinning `detect-secrets-version` (e.g. `1.5.0`) for reproducibility.
- Set `always-upload: 'true'` if you want a SARIF run recorded even with zero findings (useful for audit trail).
- `wait-for-processing: 'false'` speeds up workflows if you don't need immediate ingestion confirmation.

## What Gets Detected

This action detects hardcoded secrets including:

- **Cloud Providers**: AWS Access Keys, Azure Storage Keys, IBM Cloud IAM Keys
- **APIs & Services**: GitHub/GitLab tokens, OpenAI keys, Stripe keys, SendGrid keys
- **Communication**: Discord/Telegram bot tokens, Slack tokens
- **Package Managers**: NPM tokens, PyPI tokens
- **Authentication**: JWT tokens, Basic Auth credentials, Private keys
- **And many more...**

## Disabled Plugins (Noise Reduction)

To reduce false positives we disable very noisy detectors:
`ArtifactoryDetector`, `Base64HighEntropyString`, `HexHighEntropyString`, `KeywordDetector`.
You can re‑enable any by removing its `--disable-plugin` line in the composite action.

## Permissions Required

For SARIF upload to work, your workflow needs:

```yaml
permissions:
  security-events: write  # Upload SARIF results
  contents: read         # Checkout code
  actions: read
```

## Example Workflows

### CI/CD Pipeline Integration

```yaml
name: Security Scan
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      
      # Build your application first
      - name: Build
        run: npm run build
        
      # Scan the built artifacts
      - name: Scan for secrets
        uses: missionwired/secret-scanning-action@v1
        with:
          scan-path: './dist'
          exclude-files-regex: '.*\.map$'  # Skip source maps
```

### Scheduled Security Check

```yaml
name: Scheduled Security Check
on:
  workflow_dispatch:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  security-check:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: missionwired/secret-scanning-action@v1
        with:
          scan-path: './src'
          fail-on-detection: 'true' 
```

## Viewing Results

When secrets are detected and SARIF upload is enabled:

1. Go to your repository's **Security** tab
2. Click **Code scanning alerts**
3. Review the detected secrets with file locations and context
4. Each finding includes remediation guidance

### Where do results appear?

Uploaded SARIF findings show under Security → Code scanning alerts (category: `detect-secrets`).
GitHub Secret Scanning is a separate feature and does not ingest SARIF. For custom secret scanning alerts there, define patterns under Settings → Security & analysis → Secret scanning → Custom patterns.

### Testing Locally

Run the bundled script to validate the transform with zero / single / multi secrets:
```bash
bash test-transform.sh
```

### Adding Dummy Secrets (for testing only)
Add clearly fake tokens/keys in a throwaway branch (never real credentials):
```js
// examples
const AWS_ACCESS_KEY_ID = "AKIAFAKEFAKEFAKE123";
const GITHUB_TOKEN = "ghp_FAKE1234567890EXAMPLETOKEN";
const PRIVATE_KEY = "-----BEGIN PRIVATE KEY-----\nFAKEFAKEFAKEFAKE\n-----END PRIVATE KEY-----";
```
Commit, run the action, then remove them.

## Contributing

1. Fork
2. Branch
3. Update code / tests (`test-transform.sh`)
4. Run local validation
5. Open PR



## Versioning & Releases

We use semantic versioning. Minor bumps add functionality without breaking inputs.

To cut a new release (example v1.1.0):
```bash
git tag -a v1.1.0 -m "v1.1.0"
git push origin v1.1.0
# Update the major alias
git tag -f v1 v1.1.0
git push origin -f v1
```
Consumers referencing `@v1` automatically receive the latest compatible minor/patch.