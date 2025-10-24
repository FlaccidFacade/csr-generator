# CSR Generator 🔐

A Docker-based tool for generating Certificate Signing Requests (CSR) and private keys using the latest OpenSSL library. Available as both a CLI tool and web interface!

[![CI](https://github.com/FlaccidFacade/csr-generator/actions/workflows/ci.yml/badge.svg)](https://github.com/FlaccidFacade/csr-generator/actions/workflows/ci.yml)

## Features

- 🚀 **CLI & Web Interface** - Choose your preferred method
- 🔒 **Latest OpenSSL** - Always uses the most up-to-date OpenSSL library
- 📊 **SSL Version Verification** - Displays and verifies current OpenSSL version
- 🔍 **CSR Verification** - Built-in CSR validation tool
- 🐳 **Docker-based** - Containerized for easy deployment
- ⚡ **One-Command Setup** - Generate CSR with a single Docker command
- 🤖 **Automated Updates** - Dependabot integration for Docker image updates
- ✅ **CI/CD Pipeline** - Automated testing with GitHub Actions
- 💾 **Download Support** - Download generated CSR and private keys
- 📋 **Copy to Clipboard** - Quick copy functionality for all outputs

## Quick Start

### 🎯 CLI Version (Recommended for Quick CSR Generation)

Generate CSR files with a **single Docker command** - no setup required:

```bash
docker run --rm -v $(pwd)/output:/output \
  -e COMMON_NAME="example.com" \
  -e ORGANIZATION="Example Corp" \
  -e CITY="San Francisco" \
  -e STATE="California" \
  -e COUNTRY="US" \
  ghcr.io/flaccidfacade/csr-generator:cli
```

Or build and run locally:

```bash
# Clone the repository
git clone https://github.com/FlaccidFacade/csr-generator.git
cd csr-generator

# Build and run
docker build -f Dockerfile.cli -t csr-generator-cli .
docker run --rm -v $(pwd)/output:/output \
  -e COMMON_NAME="example.com" \
  csr-generator-cli
```

**Output:** CSR and private key files will be saved to `./output/` directory.

**Environment Variables:**
- `COMMON_NAME` - Domain name (default: example.com)
- `ORGANIZATION` - Organization name (default: Example Corp)
- `ORGANIZATIONAL_UNIT` - Department (default: IT)
- `CITY` - City (default: San Francisco)
- `STATE` - State/Province (default: California)
- `COUNTRY` - 2-letter country code (default: US)
- `EMAIL` - Email address (default: admin@example.com)
- `KEY_SIZE` - Key size in bits: 2048, 3072, or 4096 (default: 2048)

---

### 🌐 Web Interface Version

**Just clone and run:**

```bash
git clone https://github.com/FlaccidFacade/csr-generator.git
cd csr-generator
./run.sh
```

This single command:
- ✅ Checks Docker installation
- ✅ Builds the image automatically
- ✅ Creates output directory
- ✅ Starts the container
- ✅ Shows access URL and helpful commands

**Access:** http://localhost:5000

---

### Alternative Options

<details>
<summary><strong>Using Make</strong> (if you have make installed)</summary>

```bash
git clone https://github.com/FlaccidFacade/csr-generator.git
cd csr-generator
make run       # Build and run in one command

# Additional commands:
make logs      # View logs
make stop      # Stop container
make start     # Start container
make restart   # Restart container
make clean     # Remove everything
make help      # Show all commands
```
</details>

<details>
<summary><strong>Using Docker Compose</strong></summary>

```bash
git clone https://github.com/FlaccidFacade/csr-generator.git
cd csr-generator
docker-compose up -d
```

Access at http://localhost:5000

Stop with: `docker-compose down`
</details>

<details>
<summary><strong>Using Docker Directly</strong></summary>

```bash
# Build
docker build -t csr-generator .

# Run
docker run -d -p 5000:5000 -v $(pwd)/output:/app/output --name csr-generator csr-generator
```

Access at http://localhost:5000
</details>

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
