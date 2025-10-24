#!/bin/bash
# Test script for CSR Generator

set -e

echo "=== CSR Generator Test Script ==="
echo

# Check Python
echo "✓ Checking Python..."
python3 --version

# Check OpenSSL
echo "✓ Checking OpenSSL..."
openssl version

# Install dependencies
echo "✓ Installing dependencies..."
pip3 install -q flask

# Test Python app imports
echo "✓ Testing app imports..."
cd app
python3 -c "from app import app; print('App imports successfully')"

# Test SSL version function
echo "✓ Testing SSL version verification..."
python3 -c "from app import verify_latest_ssl_version; import json; print(json.dumps(verify_latest_ssl_version(), indent=2))"

# Test CSR generation
echo "✓ Testing CSR generation..."
python3 << 'PYEOF'
from app import app
import json

with app.test_client() as client:
    test_data = {
        'commonName': 'test.example.com',
        'organization': 'Test Co',
        'country': 'US',
        'keySize': '2048'
    }
    
    response = client.post('/api/generate-csr', 
                          data=json.dumps(test_data),
                          content_type='application/json')
    
    result = response.get_json()
    if result.get('success'):
        print("✅ CSR Generation Test: PASSED")
        print(f"   - CSR: {len(result.get('csr', ''))} bytes")
        print(f"   - Key: {len(result.get('private_key', ''))} bytes")
    else:
        print("❌ CSR Generation Test: FAILED")
        print(f"   Error: {result.get('error')}")
        exit(1)
PYEOF

cd ..

echo
echo "=== All Tests Passed! ==="
