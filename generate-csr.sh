#!/bin/bash
# CSR Generator CLI Script
# This script generates CSR and private key files

set -e

# Default values
COMMON_NAME="${COMMON_NAME:-example.com}"
ORGANIZATION="${ORGANIZATION:-Example Corp}"
ORGANIZATIONAL_UNIT="${ORGANIZATIONAL_UNIT:-IT}"
CITY="${CITY:-San Francisco}"
STATE="${STATE:-California}"
COUNTRY="${COUNTRY:-US}"
EMAIL="${EMAIL:-admin@example.com}"
KEY_SIZE="${KEY_SIZE:-2048}"
OUTPUT_DIR="${OUTPUT_DIR:-/output}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate timestamp for unique filenames
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SAFE_CN=$(echo "$COMMON_NAME" | sed 's/\*/_wildcard/g' | sed 's/\./_/g')
BASE_FILENAME="${SAFE_CN}_${TIMESTAMP}"

KEY_FILE="$OUTPUT_DIR/${BASE_FILENAME}.key"
CSR_FILE="$OUTPUT_DIR/${BASE_FILENAME}.csr"

# Display OpenSSL version
echo "================================================"
echo "CSR Generator CLI"
echo "================================================"
echo ""
echo "OpenSSL Version:"
openssl version
echo ""
echo "Generating CSR with the following details:"
echo "  Common Name (CN): $COMMON_NAME"
echo "  Organization (O): $ORGANIZATION"
echo "  Organizational Unit (OU): $ORGANIZATIONAL_UNIT"
echo "  City (L): $CITY"
echo "  State (ST): $STATE"
echo "  Country (C): $COUNTRY"
echo "  Email: $EMAIL"
echo "  Key Size: $KEY_SIZE bits"
echo ""

# Build subject string
SUBJECT="/CN=$COMMON_NAME/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/emailAddress=$EMAIL"

# Generate private key
echo "Generating private key..."
openssl genrsa -out "$KEY_FILE" "$KEY_SIZE" 2>/dev/null

# Generate CSR
echo "Generating CSR..."
openssl req -new -key "$KEY_FILE" -out "$CSR_FILE" -subj "$SUBJECT"

# Verify CSR
echo ""
echo "Verifying CSR..."
openssl req -text -noout -verify -in "$CSR_FILE"

echo ""
echo "================================================"
echo "✅ CSR Generated Successfully!"
echo "================================================"
echo ""
echo "Files saved to:"
echo "  Private Key: ${BASE_FILENAME}.key"
echo "  CSR: ${BASE_FILENAME}.csr"
echo ""
echo "CSR Content:"
echo "================================================"
cat "$CSR_FILE"
echo "================================================"
echo ""
echo "⚠️  IMPORTANT: Keep your private key secure!"
echo "    Never share it publicly."
echo ""
