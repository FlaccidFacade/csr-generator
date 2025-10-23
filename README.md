# CSR Generator 🔐

A Docker-based web application for generating Certificate Signing Requests (CSR) and private keys using the latest OpenSSL library. Generate SSL certificates with just a click!

[![CI](https://github.com/FlaccidFacade/csr-generator/actions/workflows/ci.yml/badge.svg)](https://github.com/FlaccidFacade/csr-generator/actions/workflows/ci.yml)

## Features

- 🚀 **One-Click CSR Generation** - Easy-to-use web interface
- 🔒 **Latest OpenSSL** - Always uses the most up-to-date OpenSSL library
- 📊 **SSL Version Verification** - Displays and verifies current OpenSSL version
- 🔍 **CSR Verification** - Built-in CSR validation tool
- 🐳 **Docker-based** - Containerized for easy deployment
- 🤖 **Automated Updates** - Dependabot integration for Docker image updates
- ✅ **CI/CD Pipeline** - Automated testing with GitHub Actions
- 💾 **Download Support** - Download generated CSR and private keys
- 📋 **Copy to Clipboard** - Quick copy functionality for all outputs

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/FlaccidFacade/csr-generator.git
cd csr-generator

# Start the application
docker-compose up -d

# Access the web interface
open http://localhost:5000
```

### Using Docker

```bash
# Build the image
docker build -t csr-generator .

# Run the container
docker run -d -p 5000:5000 -v $(pwd)/output:/app/output csr-generator

# Access the web interface
open http://localhost:5000
```

## Usage

1. **Open your browser** and navigate to `http://localhost:5000`
2. **Fill in the form** with your certificate details:
   - Common Name (CN) - Required (e.g., example.com or *.example.com)
   - Organization (O)
   - Organizational Unit (OU)
   - City/Locality (L)
   - State/Province (ST)
   - Country Code (C) - Two-letter ISO code
   - Email Address
   - Key Size - Choose between 2048, 3072, or 4096 bits
3. **Click "Generate CSR"** button
4. **Copy or download** your CSR and private key
5. **Keep your private key secure!** Never share it publicly

## SSL Version Verification

The application automatically displays the OpenSSL version being used. You can click the "Refresh SSL Info" button to verify the current version at any time.

## Architecture

```
csr-generator/
├── app/
│   ├── app.py              # Flask backend
│   ├── templates/
│   │   └── index.html      # Web interface
│   └── static/
│       ├── css/
│       │   └── style.css   # Styling
│       └── js/
│           └── main.js     # Frontend logic
├── output/                 # Generated CSR and key files
├── Dockerfile             # Docker image definition
├── docker-compose.yml     # Docker Compose configuration
└── .github/
    ├── workflows/
    │   └── ci.yml         # GitHub Actions CI pipeline
    └── dependabot.yml     # Dependabot configuration
```

## API Endpoints

### GET `/`
Main web interface

### GET `/api/ssl-version`
Returns current OpenSSL version information
```json
{
  "version": "3.1.4",
  "full_version": "OpenSSL 3.1.4 24 Oct 2023",
  "status": "installed"
}
```

### POST `/api/generate-csr`
Generate a new CSR and private key
```json
{
  "commonName": "example.com",
  "organization": "My Company",
  "city": "San Francisco",
  "state": "California",
  "country": "US",
  "keySize": "2048"
}
```

### POST `/api/verify-csr`
Verify an existing CSR
```json
{
  "csr": "-----BEGIN CERTIFICATE REQUEST-----\n..."
}
```

## CI/CD Pipeline

The project includes a comprehensive CI/CD pipeline that:

- ✅ Builds the Docker image on every push and PR
- ✅ Tests the application endpoints
- ✅ Verifies OpenSSL version
- ✅ Tests CSR generation functionality
- ✅ Performs security scanning with Trivy
- ✅ Uploads security scan results to GitHub Security

## Dependabot Integration

Dependabot is configured to automatically:

- 🔄 Check for Docker base image updates weekly
- 🔄 Check for GitHub Actions updates weekly
- 📬 Create pull requests for available updates
- 🏷️ Label PRs appropriately

This ensures the OpenSSL library and all dependencies stay up to date!

## Security

- 🔐 Private keys are generated securely using OpenSSL
- 🗂️ Generated files are stored in a dedicated output directory
- ⚠️ The application displays warnings about keeping private keys secure
- 🛡️ Regular security scanning via Trivy
- 📊 Security scan results uploaded to GitHub Security tab

## Development

### Local Development

```bash
# Install Python dependencies
pip install flask

# Run locally (without Docker)
cd app
python3 app.py

# Access at http://localhost:5000
```

### Testing

```bash
# Run CI tests locally
docker build -t csr-generator:test .
docker run -d --name csr-test -p 5000:5000 csr-generator:test

# Test endpoints
curl http://localhost:5000/api/ssl-version
curl http://localhost:5000/

# Cleanup
docker stop csr-test && docker rm csr-test
```

## Key Sizes

- **2048 bits** - Standard security, widely supported
- **3072 bits** - High security, recommended for sensitive data
- **4096 bits** - Maximum security, may have performance impact

## Requirements

- Docker 20.10+
- Docker Compose 2.0+ (optional, for docker-compose usage)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/FlaccidFacade/csr-generator/issues).
