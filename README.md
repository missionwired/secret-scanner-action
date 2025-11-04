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
    use-baseline: 'true'                        # Use baseline file to track known secrets (default: false)
    baseline-file: '.secrets.baseline'          # Path to baseline file (default: .secrets.baseline)
```

### Input Notes
- `scan-all-files` defaults to `true` and scans **all files including `.git/` directory** to catch secrets in git history
- `use-baseline`: **Defaults to `false`** and is **recommended* for proper operation. The baseline file must exist in your repository before enabling this input.
- `baseline-file`: Path to your baseline file. Must be created manually and committed to your repository.
- To update the baseline: run `detect-secrets scan --all-files --baseline .secrets.baseline` locally, audit with `detect-secrets audit .secrets.baseline`, then commit changes
- Pin `detect-secrets-version` (e.g., `1.5.0`) for reproducibility
- `debug-mode`: Enable for troubleshooting issues with the action. Shows detailed scan commands, count diagnostics, and uploads SARIF as an artifact. Set to `'true'` when reporting bugs or investigating unexpected behavior.

## Outputs

- `secret_count`: Total number of findings detected

## Baseline Workflow (Recommended)

Using a baseline file is **strongly recommended** for production environments. A baseline tracks known secrets in your repository, allowing you to:
- Only alert on NEW secrets (not existing ones you've already addressed)
- Catch secrets in git history
- Maintain repository-specific false positive exclusions
- Enable each team to manage their own secret detection policies

### Initial Setup

1. **Create your baseline file:**
```bash
# Install detect-secrets locally
pip install detect-secrets

# Generate initial baseline
detect-secrets scan --all-files > .secrets.baseline

# Audit the baseline to mark false positives
detect-secrets audit .secrets.baseline
# (This opens an interactive prompt - mark findings as real or false positive)
```

2. **Commit the baseline to your repository:**
```bash
git add .secrets.baseline
git commit -m "Add detect-secrets baseline"
git push
```

3. **Configure your workflow to use baseline:**
```yaml
name: Secret Scanning with Baseline
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
        with:
          use-baseline: 'true'
          baseline-file: '.secrets.baseline'
          fail-on-detection: 'true'
```

### Updating the Baseline

When you need to accept new secrets into the baseline (e.g., after rreviewing and rotating the secret):

1. **Update the baseline locally:**
```bash
# Install detect-secrets if not already installed
pip install detect-secrets

# Update baseline with new findings
detect-secrets scan --all-files --baseline .secrets.baseline

# Audit the changes interactively
detect-secrets audit .secrets.baseline

# Commit the updated baseline
git add .secrets.baseline
git commit -m "chore: update secrets baseline - added false positive exceptions"
git push
```


### Best Practices

- **Never commit real secrets to baseline** - Always rotate credentials first, then add to baseline
- **Review baseline changes in PRs** - Treat baseline modifications as security-sensitive
- **Periodically re-audit baselines** - Detection rules improve over time
- **Document exclusions** - Add comments in commit messages explaining why secrets were added to baseline
- **Use with git history scanning** - Baseline mode automatically includes `.git/` to catch historical secrets

### Baseline Benefits

Using a baseline file provides:

| Benefit | Description |
|---------|-------------|
| **Git history coverage** | Scans `.git/` directory to catch removed-but-not-rotated secrets |
| **False positive management** | Per-secret audit decisions via interactive `detect-secrets audit` |
| **Alert fatigue reduction** | Only alerts on NEW secrets, not existing baselined ones |
| **Repository-specific config** | Each team manages their own exclusions and policies |
| **Rotation tracking** | Documents which secrets were found, rotated, and baselined |

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

## Security Considerations

### Baseline Security

When using baseline mode:
1. **Always rotate before excluding** - Never add live credentials to baseline
2. **Audit baseline PRs** - Review changes carefully as they affect security posture
3. **Limit baseline edit access** - Security Team should edit baseline file
4. **Track baseline changes** - Monitor who adds secrets to baseline and why

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
