# Use Python slim for a lightweight image with Python pre-installed
FROM python:3.11-slim

# Install OpenSSL (usually pre-installed in Debian, but explicitly ensure it)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt /app/

# Install Flask
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app/ /app/

# Expose port for web interface
EXPOSE 5000

# Create output directory for CSR files
RUN mkdir -p /app/output

# Set environment variable for output directory
ENV OUTPUT_DIR=/app/output

# Run the Flask application
CMD ["python", "app.py"]
