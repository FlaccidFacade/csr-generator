// Global variables to store filenames
let currentCSRFilename = '';
let currentKeyFilename = '';

// Form submission handler
document.getElementById('csr-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    // Show loading, hide results and errors
    document.getElementById('loading').style.display = 'block';
    document.getElementById('result').style.display = 'none';
    document.getElementById('error').style.display = 'none';
    
    // Collect form data
    const formData = {
        commonName: document.getElementById('commonName').value,
        organization: document.getElementById('organization').value,
        organizationalUnit: document.getElementById('organizationalUnit').value,
        city: document.getElementById('city').value,
        state: document.getElementById('state').value,
        country: document.getElementById('country').value.toUpperCase(),
        email: document.getElementById('email').value,
        keySize: document.getElementById('keySize').value
    };
    
    try {
        const response = await fetch('/api/generate-csr', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(formData)
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Failed to generate CSR');
        }
        
        // Hide loading
        document.getElementById('loading').style.display = 'none';
        
        // Display results
        document.getElementById('csr-output').value = data.csr;
        document.getElementById('key-output').value = data.private_key;
        document.getElementById('verification-output').textContent = data.verification;
        
        // Store filenames
        currentCSRFilename = data.csr_filename;
        currentKeyFilename = data.key_filename;
        
        // Show result section
        document.getElementById('result').style.display = 'block';
        
        // Scroll to results
        document.getElementById('result').scrollIntoView({ behavior: 'smooth' });
        
    } catch (error) {
        document.getElementById('loading').style.display = 'none';
        showError(error.message);
    }
});

// Refresh SSL info
async function refreshSSLInfo() {
    try {
        const response = await fetch('/api/ssl-version');
        const data = await response.json();
        
        document.getElementById('ssl-version').textContent = data.full_version;
        document.getElementById('ssl-status').textContent = data.status;
        
        // Update status badge color
        const statusBadge = document.getElementById('ssl-status');
        if (data.status === 'installed') {
            statusBadge.style.background = '#4caf50';
        } else {
            statusBadge.style.background = '#f44336';
        }
        
        // Show temporary success message
        const originalText = statusBadge.textContent;
        statusBadge.textContent = '✓ Updated';
        setTimeout(() => {
            statusBadge.textContent = originalText;
        }, 2000);
        
    } catch (error) {
        showError('Failed to refresh SSL information: ' + error.message);
    }
}

// Copy to clipboard
function copyToClipboard(elementId) {
    const element = document.getElementById(elementId);
    element.select();
    document.execCommand('copy');
    
    // Find the copy button and show feedback
    const button = event.target;
    const originalText = button.textContent;
    button.textContent = '✓ Copied!';
    button.style.background = '#4caf50';
    button.style.color = 'white';
    
    setTimeout(() => {
        button.textContent = originalText;
        button.style.background = '';
        button.style.color = '';
    }, 2000);
}

// Download file
function downloadFile(elementId, type) {
    const content = document.getElementById(elementId).value;
    const filename = type === 'csr' ? currentCSRFilename : currentKeyFilename;
    
    const blob = new Blob([content], { type: 'text/plain' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename || `generated.${type}`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
}

// Reset form
function resetForm() {
    document.getElementById('csr-form').reset();
    document.getElementById('result').style.display = 'none';
    document.querySelector('.form-section').scrollIntoView({ behavior: 'smooth' });
}

// Show error
function showError(message) {
    document.getElementById('error-message').textContent = message;
    document.getElementById('error').style.display = 'block';
    document.getElementById('error').scrollIntoView({ behavior: 'smooth' });
}

// Hide error
function hideError() {
    document.getElementById('error').style.display = 'none';
}

// Verify CSR
async function verifyCsr() {
    const csrContent = document.getElementById('verify-csr-input').value.trim();
    
    if (!csrContent) {
        showError('Please paste a CSR to verify');
        return;
    }
    
    try {
        const response = await fetch('/api/verify-csr', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ csr: csrContent })
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Failed to verify CSR');
        }
        
        document.getElementById('verify-output').textContent = data.verification;
        document.getElementById('verify-result').style.display = 'block';
        
    } catch (error) {
        showError('CSR verification failed: ' + error.message);
    }
}

// Auto-uppercase country code
document.getElementById('country').addEventListener('input', (e) => {
    e.target.value = e.target.value.toUpperCase();
});
