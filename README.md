# Detect Secrets Scanner Action

A GitHub Action that scans your codebase for hardcoded secrets using [detect-secrets](https://github.com/Yelp/detect-secrets), converts results to SARIF format, and optionally uploads findings to GitHub Code Scanning for security visibility.

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
| `scan-path` | Directory to scan for secrets | `./build` | No |
| `upload-sarif` | Upload results to GitHub Code Scanning | `true` | No |
| `exclude-files-regex` | Regex pattern for files to exclude | `""` | No |
| `fail-on-detection` | Fail workflow if secrets are found | `true` | No |

## Outputs

The action sets the following output:
- `secret_count`: Number of secrets detected

## What Gets Detected

This action detects hardcoded secrets including:

- **Cloud Providers**: AWS Access Keys, Azure Storage Keys, IBM Cloud IAM Keys
- **APIs & Services**: GitHub/GitLab tokens, OpenAI keys, Stripe keys, SendGrid keys
- **Communication**: Discord/Telegram bot tokens, Slack tokens
- **Package Managers**: NPM tokens, PyPI tokens
- **Authentication**: JWT tokens, Basic Auth credentials, Private keys
- **And many more...**

## Disabled Plugins

To reduce false positives, these plugins are disabled by default:
- `ArtifactoryDetector`
- `Base64HighEntropyString`
- `HexHighEntropyString` 
- `KeywordDetector`

## Permissions Required

For SARIF upload to work, your workflow needs:

```yaml
permissions:
  security-events: write  # Upload SARIF results
  contents: read         # Checkout code
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

This action uploads SARIF to GitHub Code Scanning (Security → Code scanning alerts). 
GitHub Secret Scanning is separate and does not ingest SARIF. 
If you want similar alerts under Secret Scanning, create custom patterns in 
Settings → Security & analysis → Secret scanning → Custom patterns.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with different configurations
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.