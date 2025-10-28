#!/usr/bin/env jq -f

# Define a version for the detect-secrets tool if it's not provided in the input
def tool_version: "1.5.0";

# Define an information URI for detect-secrets
def tool_info_uri: "https://github.com/Yelp/detect-secrets";

def default_rules: {
  "AWS Access Key": {
    "id": "DS0001",
    "name": "AwsAccessKey",
    "shortDescription": { "text": "AWS Access Key detected" },
    "fullDescription": { "text": "Detects AWS Access Keys in your source code" },
    "help": {
      "text": "AWS Access Keys should not be hardcoded in source code. Store them securely in environment variables, AWS Secrets Manager, or similar secure storage."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Artifactory Credentials": {
    "id": "DS0002",
    "name": "ArtifactoryCredentials",
    "shortDescription": { "text": "Artifactory credentials detected" },
    "fullDescription": { "text": "Detects Artifactory credentials in your source code" },
    "help": {
      "text": "Artifactory credentials should not be hardcoded in source code. Use secrets management solutions instead."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Azure Storage Account access key": {
    "id": "DS0003",
    "name": "AzureStorageKey",
    "shortDescription": { "text": "Azure Storage Account access key detected" },
    "fullDescription": { "text": "Detects Azure Storage Account access keys in your source code" },
    "help": {
      "text": "Azure Storage Account access keys should be stored in Azure Key Vault or other secure storage mechanisms, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Base64 High Entropy String": {
    "id": "DS0004",
    "name": "Base64HighEntropyString",
    "shortDescription": { "text": "High entropy Base64 string detected" },
    "fullDescription": { "text": "Detects high entropy Base64 strings in your source code" },
    "help": {
      "text": "High entropy Base64 strings may represent sensitive data. Ensure this is not a password, token, or other secret."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Basic Auth Credentials": {
    "id": "DS0005",
    "name": "BasicAuthCredentials",
    "shortDescription": { "text": "Basic Auth Credentials detected" },
    "fullDescription": { "text": "Detects Basic Auth Credentials in your source code" },
    "help": {
      "text": "Basic Auth credentials should not be hardcoded. Use secure credential management practices."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Cloudant Credentials": {
    "id": "DS0006",
    "name": "CloudantCredentials",
    "shortDescription": { "text": "Cloudant credentials detected" },
    "fullDescription": { "text": "Detects Cloudant credentials in your source code" },
    "help": {
      "text": "Cloudant credentials should be stored in a secure credentials manager, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Discord Bot Token": {
    "id": "DS0007",
    "name": "DiscordBotToken",
    "shortDescription": { "text": "Discord Bot Token detected" },
    "fullDescription": { "text": "Detects Discord bot tokens in your source code" },
    "help": {
      "text": "Discord bot tokens should be stored in environment variables or a secure secrets manager, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "GitHub Token": {
    "id": "DS0008",
    "name": "GitHubToken",
    "shortDescription": { "text": "GitHub Token detected" },
    "fullDescription": { "text": "Detects GitHub tokens in your source code" },
    "help": {
      "text": "GitHub tokens should not be hardcoded in source code. Use GitHub Actions secrets or other secure storage."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "GitLab Token": {
    "id": "DS0009",
    "name": "GitLabToken",
    "shortDescription": { "text": "GitLab Token detected" },
    "fullDescription": { "text": "Detects GitLab tokens in your source code" },
    "help": {
      "text": "GitLab tokens should not be hardcoded in source code. Use GitLab CI/CD variables or other secure storage."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Hex High Entropy String": {
    "id": "DS0010",
    "name": "HexHighEntropyString",
    "shortDescription": { "text": "High entropy Hex string detected" },
    "fullDescription": { "text": "Detects high entropy Hex strings in your source code" },
    "help": {
      "text": "High entropy Hex strings may represent sensitive data. Ensure this is not a password, token, or other secret."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "IBM COS HMAC Credentials": {
    "id": "DS0011",
    "name": "IbmCosHmacCredentials",
    "shortDescription": { "text": "IBM COS HMAC credentials detected" },
    "fullDescription": { "text": "Detects IBM COS HMAC credentials in your source code" },
    "help": {
      "text": "IBM COS HMAC credentials should be stored securely in a credential manager or environment variables, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "IBM Cloud IAM Key": {
    "id": "DS0012",
    "name": "IbmCloudIamKey",
    "shortDescription": { "text": "IBM Cloud IAM Key detected" },
    "fullDescription": { "text": "Detects IBM Cloud IAM Keys in your source code" },
    "help": {
      "text": "IBM Cloud IAM Keys should be stored in IBM Secret Manager or other secure storage, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "JSON Web Token": {
    "id": "DS0013",
    "name": "JsonWebToken",
    "shortDescription": { "text": "JSON Web Token detected" },
    "fullDescription": { "text": "Detects JSON Web Tokens in your source code" },
    "help": {
      "text": "JSON Web Tokens should not be hardcoded in source code. Generate them dynamically and store securely."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Mailchimp Access Key": {
    "id": "DS0014",
    "name": "MailchimpAccessKey",
    "shortDescription": { "text": "Mailchimp Access Key detected" },
    "fullDescription": { "text": "Detects Mailchimp Access Keys in your source code" },
    "help": {
      "text": "Mailchimp Access Keys should be stored in environment variables or secure storage, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "NPM tokens": {
    "id": "DS0015",
    "name": "NpmToken",
    "shortDescription": { "text": "NPM token detected" },
    "fullDescription": { "text": "Detects NPM tokens in your source code" },
    "help": {
      "text": "NPM tokens should be stored in encrypted environment variables or secrets management tools, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "OpenAI Token": {
    "id": "DS0016",
    "name": "OpenAiToken",
    "shortDescription": { "text": "OpenAI API Key detected" },
    "fullDescription": { "text": "Detects OpenAI API Keys in your source code" },
    "help": {
      "text": "OpenAI API Keys should be stored securely in environment variables or a secrets manager, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Private Key": {
    "id": "DS0017",
    "name": "PrivateKey",
    "shortDescription": { "text": "Private Key detected" },
    "fullDescription": { "text": "Detects private keys in your source code" },
    "help": {
      "text": "Private keys should never be stored in source code. Use a secure key management system instead."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Public IP (ipv4)": {
    "id": "DS0018",
    "name": "PublicIpV4",
    "shortDescription": { "text": "Public IP address detected" },
    "fullDescription": { "text": "Detects public IP addresses in your source code" },
    "help": {
      "text": "Hardcoded public IP addresses can be a security risk and may indicate sensitive information. Use configuration files instead."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "PyPI Token": {
    "id": "DS0019",
    "name": "PyPiToken",
    "shortDescription": { "text": "PyPI token detected" },
    "fullDescription": { "text": "Detects PyPI tokens in your source code" },
    "help": {
      "text": "PyPI tokens should be stored in environment variables or secure credential storage, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Secret Keyword": {
    "id": "DS0020",
    "name": "SecretKeyword",
    "shortDescription": { "text": "Sensitive keyword detected" },
    "fullDescription": { "text": "Detects sensitive keywords in your source code" },
    "help": {
      "text": "Keywords suggesting secrets or credentials have been detected. Review this code for potential hardcoded secrets."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "SendGrid API Key": {
    "id": "DS0021",
    "name": "SendGridApiKey",
    "shortDescription": { "text": "SendGrid API Key detected" },
    "fullDescription": { "text": "Detects SendGrid API Keys in your source code" },
    "help": {
      "text": "SendGrid API Keys should be stored in environment variables or secure storage, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Slack Token": {
    "id": "DS0022",
    "name": "SlackToken",
    "shortDescription": { "text": "Slack Token detected" },
    "fullDescription": { "text": "Detects Slack tokens in your source code" },
    "help": {
      "text": "Slack tokens should be stored securely in environment variables or secrets management, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "SoftLayer Credentials": {
    "id": "DS0023",
    "name": "SoftLayerCredentials",
    "shortDescription": { "text": "SoftLayer credentials detected" },
    "fullDescription": { "text": "Detects SoftLayer credentials in your source code" },
    "help": {
      "text": "SoftLayer credentials should be stored in a secure credentials manager, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Square OAuth Secret": {
    "id": "DS0024",
    "name": "SquareOAuthSecret",
    "shortDescription": { "text": "Square OAuth Secret detected" },
    "fullDescription": { "text": "Detects Square OAuth Secrets in your source code" },
    "help": {
      "text": "Square OAuth Secrets should be stored in environment variables or secure storage, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Stripe Access Key": {
    "id": "DS0025",
    "name": "StripeAccessKey",
    "shortDescription": { "text": "Stripe Access Key detected" },
    "fullDescription": { "text": "Detects Stripe Access Keys in your source code" },
    "help": {
      "text": "Stripe Access Keys should be stored in environment variables or a secure secrets manager, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Telegram Bot Token": {
    "id": "DS0026",
    "name": "TelegramBotToken",
    "shortDescription": { "text": "Telegram Bot Token detected" },
    "fullDescription": { "text": "Detects Telegram bot tokens in your source code" },
    "help": {
      "text": "Telegram bot tokens should be stored in environment variables or secure storage, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Twilio API Key": {
    "id": "DS0027",
    "name": "TwilioApiKey",
    "shortDescription": { "text": "Twilio API Key detected" },
    "fullDescription": { "text": "Detects Twilio API Keys in your source code" },
    "help": {
      "text": "Twilio API Keys should be stored in environment variables or a secure secrets manager, not in source code."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  },
  "Default": {
    "id": "DS0000",
    "name": "GenericSecret",
    "shortDescription": { "text": "Secret detected" },
    "fullDescription": { "text": "Detects generic secrets in your source code" },
    "help": {
      "text": "Avoid storing any kind of secrets or credentials in source code. Use environment variables or a secrets manager instead."
    },
    "helpUri": "https://github.com/Yelp/detect-secrets/blob/master/docs/plugins.md"
  }
};

# Helper function to create a hash for fingerprinting (ensures String type)
def create_hash(input):
  (input | split("") | reduce .[] as $c (0; . + ($c | ascii_downcase | tonumber? // 0))) | tostring;

# Helper function to generate code snippet context
def get_snippet(text; line):
  # This is a placeholder - in reality, you'd need access to file content
  # which detect-secrets doesn't provide in its JSON output
  "// Code snippet not available from detect-secrets\n// Line \(line)";

{
  "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "detect-secrets",
          "version": tool_version,
          "informationUri": tool_info_uri,
          "rules": (
            [ (.results? // {} | keys_unsorted[]? ) as $file
              | (.results[$file][]? | .type)? ]
            | map(select(. != null))
            | unique
            | map( (default_rules[.] // default_rules["Default"]) )
          )
        }
      },
      "versionControlProvenance": [
        {
          "repositoryUri": "REPOSITORY_URI_PLACEHOLDER",
          "revisionId": "REVISION_ID_PLACEHOLDER",
          "branch": "BRANCH_PLACEHOLDER",
          "mappedTo": { "uriBaseId": "SRCROOT" }
        }
      ],
      "originalUriBaseIds": {
        "SRCROOT": { "uri": "REPOSITORY_URI_PLACEHOLDER" }
      },
      "results": [
        (.results? // {} | keys_unsorted[]? ) as $file
        | (.results[$file][]?) as $finding
        | {
            "ruleId": ( if $finding.type and default_rules[$finding.type] then default_rules[$finding.type].id else default_rules["Default"].id end ),
            "message": { "text": "\(($finding.type // "Secret")) detected in \($file) at line \(($finding.line_number // 0))" },
            "locations": [
              { "physicalLocation": {
                  "artifactLocation": { "uri": $file, "uriBaseId": "SRCROOT" },
                  "region": {
                    "startLine": ($finding.line_number // 0),
                    "snippet": { "text": get_snippet($file; ($finding.line_number // 0)) }
                  },
                  "contextRegion": {
                    "startLine": (($finding.line_number // 0) - 3 | if . < 1 then 1 else . end),
                    "endLine": (($finding.line_number // 0) + 3),
                    "snippet": { "text": get_snippet($file; (($finding.line_number // 0) - 3 | if . < 1 then 1 else . end)) }
                  }
                }
              }
            ],
            "partialFingerprints": {
              "secretHash": ($finding.hashed_secret // "UNKNOWN"),
              "secretHash/v1": ($finding.hashed_secret // "UNKNOWN"),
              "fileHash/v1": create_hash($file),
              "typeHash/v1": create_hash($finding.type // "UnknownType")
            },
            "properties": { "is_verified": ($finding.is_verified // false) }
          }
      ],
      "conversion": {
        "tool": { "driver": { "name": "detect-secrets-to-sarif", "informationUri": "https://iomergent.com" } }
      },
      "properties": { "detectSecretsVersion": tool_version, "conversionDate": (now | todate) }
    }
  ]
}
