# Build Troubleshooting Guide

## SSL Certificate Verification Issues in Docker Build

If you encounter SSL certificate verification errors during `docker build`, this is typically caused by:

1. **Corporate Proxy/SSL Inspection**: Your network may use SSL inspection
2. **Firewall**: Restrictive firewall rules blocking HTTPS
3. **Sandboxed Environment**: Limited network access in CI/CD or sandboxed environments

### Solutions

#### Option 1: Use Pre-built Image (Recommended for Production)

```bash
# Pull from Docker Hub (when available)
docker pull flaccidfacade/csr-generator:latest
docker run -d -p 5000:5000 flaccidfacade/csr-generator:latest
```

#### Option 2: Build with Host Network

```bash
docker build --network=host -t csr-generator .
```

#### Option 3: Configure Docker to Use HTTP Mirrors

Create or edit `/etc/docker/daemon.json`:

```json
{
  "registry-mirrors": ["http://mirror.gcr.io"]
}
```

Then restart Docker:

```bash
sudo systemctl restart docker
```

#### Option 4: Build in Stages

If pip fails to install Flask, you can pre-download the wheel:

```bash
# Download Flask wheel locally
pip download flask -d ./wheels/

# Update Dockerfile to copy and install from local wheels
# Add before RUN pip install:
# COPY wheels/ /tmp/wheels/
# RUN pip install --no-index --find-links=/tmp/wheels/ flask
```

#### Option 5: Use Alternative Base Image

Try using an alternative base image that may work better in your environment:

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openssl

RUN pip3 install flask
...
```

### Testing Without Docker

You can run the application directly without Docker:

```bash
# Install dependencies
pip3 install flask

# Run the application
cd app
python3 app.py

# Access at http://localhost:5000
```

### Verification

Once running, verify the application works:

```bash
# Test SSL version endpoint
curl http://localhost:5000/api/ssl-version

# Test CSR generation
curl -X POST http://localhost:5000/api/generate-csr \
  -H "Content-Type: application/json" \
  -d '{
    "commonName": "test.example.com",
    "organization": "Test Org",
    "country": "US",
    "keySize": "2048"
  }'
```

## Common Issues

### Issue: "Permission denied" when accessing Alpine repositories

**Cause**: SSL certificate verification failure in sandboxed environment

**Solution**: Use Debian-based image (python:3.11-slim) instead of Alpine

### Issue: pip cannot install packages

**Cause**: PyPI SSL certificate verification failure

**Solution**: 
- Use `--trusted-host` flag: `pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org flask`
- Or download wheels separately and install from local files

### Issue: Container exits immediately

**Cause**: Application error or missing dependencies

**Solution**: Check logs with `docker logs <container-id>`

## Testing

Run the included test script to verify functionality:

```bash
chmod +x test.sh
./test.sh
```

This will test:
- Python and OpenSSL availability
- Flask installation
- App imports
- SSL version detection
- CSR generation

## Support

If you continue to experience issues, please:
1. Check your network configuration
2. Verify Docker is properly configured
3. Try running without Docker first
4. Open an issue on GitHub with error details
