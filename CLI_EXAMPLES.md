# CSR Generator - CLI Usage Examples

## Basic Usage

Generate a CSR with default values:

```bash
docker build -f Dockerfile.cli -t csr-generator-cli .
docker run --rm -v $(pwd)/output:/output csr-generator-cli
```

## Custom Domain

Generate CSR for your domain:

```bash
docker run --rm -v $(pwd)/output:/output \
  -e COMMON_NAME="yourdomain.com" \
  csr-generator-cli
```

## Wildcard Certificate

Generate CSR for a wildcard certificate:

```bash
docker run --rm -v $(pwd)/output:/output \
  -e COMMON_NAME="*.yourdomain.com" \
  csr-generator-cli
```

## Full Example with All Fields

```bash
docker run --rm -v $(pwd)/output:/output \
  -e COMMON_NAME="secure.example.com" \
  -e ORGANIZATION="Example Inc" \
  -e ORGANIZATIONAL_UNIT="Security Team" \
  -e CITY="New York" \
  -e STATE="New York" \
  -e COUNTRY="US" \
  -e EMAIL="security@example.com" \
  -e KEY_SIZE="4096" \
  csr-generator-cli
```

## High Security (4096-bit Key)

```bash
docker run --rm -v $(pwd)/output:/output \
  -e COMMON_NAME="secure.bank.com" \
  -e KEY_SIZE="4096" \
  csr-generator-cli
```

## Multiple Domains

Generate CSR for multiple domains (run multiple times):

```bash
# Domain 1
docker run --rm -v $(pwd)/output:/output \
  -e COMMON_NAME="www.example.com" \
  csr-generator-cli

# Domain 2
docker run --rm -v $(pwd)/output:/output \
  -e COMMON_NAME="api.example.com" \
  csr-generator-cli
```

## Output

All generated files will be saved to `./output/` directory:
- `{domain}_{timestamp}.csr` - Certificate Signing Request
- `{domain}_{timestamp}.key` - Private Key (keep this secure!)

## Environment Variables Reference

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `COMMON_NAME` | Domain name (FQDN) | example.com | No |
| `ORGANIZATION` | Organization/Company name | Example Corp | No |
| `ORGANIZATIONAL_UNIT` | Department/Division | IT | No |
| `CITY` | City/Locality | San Francisco | No |
| `STATE` | State/Province | California | No |
| `COUNTRY` | Two-letter country code | US | No |
| `EMAIL` | Contact email address | admin@example.com | No |
| `KEY_SIZE` | RSA key size (2048, 3072, 4096) | 2048 | No |

## Tips

1. **Always backup your private key** - Store it securely and never share it
2. **Use 4096-bit keys for high security** - Recommended for production environments
3. **Verify your CSR** - The tool automatically verifies the CSR before output
4. **Check OpenSSL version** - The tool displays the OpenSSL version being used

## Troubleshooting

### Permission Issues

If you get permission errors with the output directory:

```bash
mkdir -p output
chmod 777 output
docker run --rm -v $(pwd)/output:/output csr-generator-cli
```

### Windows Users

Use PowerShell:

```powershell
docker run --rm -v ${PWD}/output:/output -e COMMON_NAME="example.com" csr-generator-cli
```

Or Command Prompt:

```cmd
docker run --rm -v %cd%/output:/output -e COMMON_NAME="example.com" csr-generator-cli
```
