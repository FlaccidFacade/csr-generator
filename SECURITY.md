# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please send an email to the repository owner. Please do not open a public issue.

## Security Measures

This application implements several security measures:

### Input Validation and Sanitization

1. **Key Size Validation**: Only allows specific key sizes (2048, 3072, 4096 bits)
2. **Input Sanitization**: All user inputs are sanitized to prevent injection attacks
   - Removes special characters that could be used for command injection
   - Validates and limits input lengths
   - Country codes are validated to be exactly 2 characters
3. **Path Traversal Prevention**: File paths are validated to prevent directory traversal attacks
4. **CSR Format Validation**: Verifies CSR content before processing

### Error Handling

- Generic error messages are returned to users to avoid leaking sensitive system information
- Detailed error messages are not exposed to prevent information disclosure

### OpenSSL Command Execution

The application uses `subprocess.run()` to execute OpenSSL commands with:
- Fixed command structure (no user input in command names)
- Sanitized and validated parameters
- Separate arguments (list format) to prevent shell injection

### GitHub Actions Security

- Minimal GITHUB_TOKEN permissions set for all workflows
- Dependabot configured for automated dependency updates
- Security scanning with Trivy

## CodeQL Findings

### Command-Line Injection Warnings (False Positives)

CodeQL reports command-line injection warnings for the OpenSSL command execution. These are **false positives** because:

1. **Key Size**: Validated to be one of three specific integer values (2048, 3072, 4096)
2. **File Paths**: Generated internally with sanitized inputs and validated to be within the output directory
3. **Subject DN**: Built from sanitized inputs that only allow safe characters
4. **Command Structure**: Uses list format for subprocess.run() which prevents shell injection

The application does NOT:
- Execute user-provided command names
- Use shell=True in subprocess calls
- Allow arbitrary command parameters
- Expose file system paths to users

### Input Sanitization Details

All user inputs go through `sanitize_input()` function which:
- Strips all characters except: alphanumeric, spaces, dots, dashes, underscores, asterisks, and @ symbols
- Limits string lengths
- Additional validation for specific fields (e.g., country code must be 2 letters)

Example sanitization:
```python
# Only allows safe characters
sanitized = re.sub(r'[^a-zA-Z0-9\s.\-_*@]', '', value)

# Additional filename safety
safe_cn = re.sub(r'[^a-zA-Z0-9_-]', '_', safe_cn)
```

## Best Practices for Users

1. **Private Key Security**: Keep your private keys secure. Never share them or commit them to version control.
2. **Network Security**: Use HTTPS when deploying to production
3. **Access Control**: Implement authentication if deploying to a public network
4. **Regular Updates**: Keep the Docker image updated with the latest security patches

## Dependency Management

- Dependabot monitors dependencies weekly
- Python packages are pinned to specific versions
- Docker base image uses Python official slim images with security updates

## Known Limitations

1. The application is designed for internal/trusted network use
2. No built-in authentication or rate limiting
3. Generated files are stored on the server (should be cleaned periodically)

## Security Scan Results

The application undergoes regular security scanning:
- Static analysis with CodeQL
- Container scanning with Trivy
- GitHub Security Advisories monitoring

## Updates

Security patches will be applied as soon as possible after disclosure. Check the repository for updates.
