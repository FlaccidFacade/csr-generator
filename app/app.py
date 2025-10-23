from flask import Flask, render_template, request, jsonify, send_file
import subprocess
import os
import json
import re
from datetime import datetime

app = Flask(__name__)

# Create output directory if it doesn't exist
# Use relative path for local testing, absolute path in Docker
OUTPUT_DIR = os.environ.get('OUTPUT_DIR', './output')
os.makedirs(OUTPUT_DIR, exist_ok=True)

def get_openssl_version():
    """Get the OpenSSL version installed"""
    try:
        result = subprocess.run(
            ['openssl', 'version'],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except Exception:
        # Security fix: Don't expose detailed error messages
        return "Error retrieving OpenSSL version"

def verify_latest_ssl_version():
    """Check if OpenSSL version is up to date"""
    try:
        result = subprocess.run(
            ['openssl', 'version'],
            capture_output=True,
            text=True,
            check=True
        )
        version_str = result.stdout.strip()
        
        # Extract version number (e.g., "OpenSSL 3.1.4")
        parts = version_str.split()
        if len(parts) >= 2:
            version = parts[1]
            return {
                'version': version,
                'full_version': version_str,
                'status': 'installed'
            }
        return {
            'version': 'unknown',
            'full_version': version_str,
            'status': 'installed'
        }
    except Exception:
        # Security fix: Don't expose detailed error messages
        return {
            'version': 'error',
            'full_version': 'Unable to retrieve OpenSSL version',
            'status': 'error'
        }

@app.route('/')
def index():
    """Render the main page"""
    ssl_info = verify_latest_ssl_version()
    return render_template('index.html', ssl_info=ssl_info)

@app.route('/api/ssl-version', methods=['GET'])
def ssl_version():
    """API endpoint to get SSL version"""
    return jsonify(verify_latest_ssl_version())

@app.route('/api/generate-csr', methods=['POST'])
def generate_csr():
    """Generate CSR and private key"""
    try:
        data = request.json
        
        # Extract form data
        common_name = data.get('commonName', '')
        organization = data.get('organization', '')
        organizational_unit = data.get('organizationalUnit', '')
        city = data.get('city', '')
        state = data.get('state', '')
        country = data.get('country', '')
        email = data.get('email', '')
        key_size = data.get('keySize', '2048')
        
        # Validate required fields
        if not common_name:
            return jsonify({'error': 'Common Name (CN) is required'}), 400
        
        # Sanitize and validate key_size (security fix: prevent command injection)
        try:
            key_size_int = int(key_size)
            if key_size_int not in [2048, 3072, 4096]:
                return jsonify({'error': 'Invalid key size. Must be 2048, 3072, or 4096'}), 400
            key_size = str(key_size_int)
        except ValueError:
            return jsonify({'error': 'Invalid key size format'}), 400
        
        # Sanitize inputs to prevent injection attacks
        def sanitize_input(value, max_length=64):
            """Sanitize input to prevent injection attacks"""
            if not value:
                return ''
            # Remove any characters that could be used for command injection
            # Allow only alphanumeric, spaces, dots, dashes, underscores, and asterisk (for wildcard)
            sanitized = re.sub(r'[^a-zA-Z0-9\s.\-_*@]', '', value)
            return sanitized[:max_length]
        
        common_name = sanitize_input(common_name, 253)  # Max domain length
        organization = sanitize_input(organization)
        organizational_unit = sanitize_input(organizational_unit)
        city = sanitize_input(city)
        state = sanitize_input(state)
        country = sanitize_input(country, 2).upper()
        email = sanitize_input(email, 254)  # Max email length
        
        # Additional validation for country code
        if country and len(country) != 2:
            country = ''
        
        # Generate unique filename based on timestamp and CN (security fix: prevent path traversal)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        safe_cn = common_name.replace('*', 'wildcard').replace('.', '_').replace('/', '_').replace('\\', '_')
        # Ensure filename is safe
        safe_cn = re.sub(r'[^a-zA-Z0-9_-]', '_', safe_cn)
        base_filename = f"{safe_cn}_{timestamp}"
        key_file = os.path.join(OUTPUT_DIR, f"{base_filename}.key")
        csr_file = os.path.join(OUTPUT_DIR, f"{base_filename}.csr")
        
        # Ensure the files are within OUTPUT_DIR (prevent path traversal)
        key_file = os.path.abspath(key_file)
        csr_file = os.path.abspath(csr_file)
        output_dir_abs = os.path.abspath(OUTPUT_DIR)
        
        if not key_file.startswith(output_dir_abs) or not csr_file.startswith(output_dir_abs):
            return jsonify({'error': 'Invalid filename'}), 400
        
        # Build subject string
        subject_parts = [f"CN={common_name}"]
        if country:
            subject_parts.append(f"C={country}")
        if state:
            subject_parts.append(f"ST={state}")
        if city:
            subject_parts.append(f"L={city}")
        if organization:
            subject_parts.append(f"O={organization}")
        if organizational_unit:
            subject_parts.append(f"OU={organizational_unit}")
        if email:
            subject_parts.append(f"emailAddress={email}")
        
        subject = "/" + "/".join(subject_parts)
        
        # Generate private key
        key_cmd = [
            'openssl', 'genrsa',
            '-out', key_file,
            key_size
        ]
        subprocess.run(key_cmd, check=True, capture_output=True)
        
        # Generate CSR
        csr_cmd = [
            'openssl', 'req',
            '-new',
            '-key', key_file,
            '-out', csr_file,
            '-subj', subject
        ]
        subprocess.run(csr_cmd, check=True, capture_output=True)
        
        # Read generated files
        with open(key_file, 'r') as f:
            private_key = f.read()
        
        with open(csr_file, 'r') as f:
            csr_content = f.read()
        
        # Verify CSR
        verify_cmd = [
            'openssl', 'req',
            '-text',
            '-noout',
            '-verify',
            '-in', csr_file
        ]
        verify_result = subprocess.run(verify_cmd, capture_output=True, text=True, check=True)
        
        return jsonify({
            'success': True,
            'csr': csr_content,
            'private_key': private_key,
            'key_filename': f"{base_filename}.key",
            'csr_filename': f"{base_filename}.csr",
            'verification': verify_result.stdout
        })
        
    except subprocess.CalledProcessError as e:
        # Security fix: Don't expose detailed error messages
        return jsonify({
            'error': 'Failed to generate CSR. Please check your inputs and try again.'
        }), 500
    except Exception as e:
        # Security fix: Don't expose detailed error messages
        return jsonify({
            'error': 'An error occurred while generating the CSR. Please try again.'
        }), 500

@app.route('/api/verify-csr', methods=['POST'])
def verify_csr():
    """Verify a CSR"""
    try:
        data = request.json
        csr_content = data.get('csr', '')
        
        if not csr_content:
            return jsonify({'error': 'CSR content is required'}), 400
        
        # Basic validation: check if it looks like a CSR
        if '-----BEGIN CERTIFICATE REQUEST-----' not in csr_content:
            return jsonify({'error': 'Invalid CSR format'}), 400
        
        # Write CSR to temporary file
        temp_csr = os.path.join(OUTPUT_DIR, 'temp_verify.csr')
        with open(temp_csr, 'w') as f:
            f.write(csr_content)
        
        # Verify CSR
        verify_cmd = [
            'openssl', 'req',
            '-text',
            '-noout',
            '-verify',
            '-in', temp_csr
        ]
        result = subprocess.run(verify_cmd, capture_output=True, text=True, check=True)
        
        # Clean up temp file
        try:
            os.remove(temp_csr)
        except:
            pass
        
        return jsonify({
            'success': True,
            'verification': result.stdout
        })
        
    except subprocess.CalledProcessError:
        # Security fix: Don't expose detailed error messages
        try:
            os.remove(temp_csr)
        except:
            pass
        return jsonify({
            'error': 'CSR verification failed. Please ensure you provided a valid CSR.'
        }), 500
    except Exception:
        # Security fix: Don't expose detailed error messages
        try:
            os.remove(temp_csr)
        except:
            pass
        return jsonify({
            'error': 'An error occurred while verifying the CSR.'
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
