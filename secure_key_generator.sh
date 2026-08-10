#!/bin/bash

# Always run from the script directory
cd "$(dirname "$(realpath "$0")")"

# ----------------------------
# Color definitions for output
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ----------------------------
# Helper functions for colored output
# ----------------------------
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# ----------------------------
# Check and install OpenSSL if missing
# ----------------------------
check_openssl() {
    if ! command -v openssl &> /dev/null; then
        print_warning "OpenSSL is not installed. Attempting to install..."
        
        # Detect distribution and install OpenSSL
        if [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
            print_info "Detected Fedora/RHEL-based system. Installing OpenSSL..."
            sudo dnf install -y openssl openssl-devel
        elif [ -f /etc/debian_version ]; then
            print_info "Detected Debian-based system. Installing OpenSSL..."
            sudo apt-get update -qq
            sudo apt-get install -y -qq openssl libssl-dev
        elif [ -f /etc/arch-release ]; then
            print_info "Detected Arch-based system. Installing OpenSSL..."
            sudo pacman -Sy --noconfirm openssl
        else
            print_error "Unsupported distribution. Please install OpenSSL manually."
            return 1
        fi
        
        # Verify installation
        if command -v openssl &> /dev/null; then
            print_success "OpenSSL installed successfully: $(openssl version)"
            return 0
        else
            print_error "Failed to install OpenSSL. Please install it manually."
            return 1
        fi
    else
        print_success "OpenSSL is already installed: $(openssl version)"
        return 0
    fi
}

# ----------------------------
# Cryptographic keys setup function
# ----------------------------
setup_crypto_keys() {
    print_info "Setting up cryptographic keys..."

    # Check for OpenSSL first
    if ! check_openssl; then
        return 1
    fi

    # Configuration for keys
    DEST_KEYS_PATH="secure_keys"
    PASSPHRASE_FILE="passphrase"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)

    # Key filenames inside secure_keys directory
    ENCRYPT_PRIV_KEY="${DEST_KEYS_PATH}/encrypt_private_${TIMESTAMP}.pem"
    ENCRYPT_PUB_KEY="${DEST_KEYS_PATH}/encrypt_public_${TIMESTAMP}.pem"
    SIGN_PRIV_KEY="${DEST_KEYS_PATH}/sign_private_${TIMESTAMP}.pem"
    SIGN_PUB_KEY="${DEST_KEYS_PATH}/sign_public_${TIMESTAMP}.pem"

    # Read passphrase from file
    if [ ! -f "$PASSPHRASE_FILE" ]; then
        print_error "Passphrase file '$PASSPHRASE_FILE' not found in $(pwd)"
        print_info "Creating a sample passphrase file..."
        echo "my_secure_passphrase_$(date +%s)" > "$PASSPHRASE_FILE"
        chmod 600 "$PASSPHRASE_FILE"
        print_success "Created sample passphrase file: $PASSPHRASE_FILE"
        print_warning "Please change the passphrase in this file for production use!"
    fi

    PASSPHRASE=$(cat "$PASSPHRASE_FILE" | tr -d '\r\n')

    if [ -z "$PASSPHRASE" ]; then
        print_error "Passphrase file '$PASSPHRASE_FILE' is empty."
        return 1
    fi

    # Ensure target directory exists
    if [ ! -d "$DEST_KEYS_PATH" ]; then
        print_info "Creating secure key directory '$DEST_KEYS_PATH'..."
        mkdir -p "$DEST_KEYS_PATH"
        chmod 700 "$DEST_KEYS_PATH"
    fi

    echo ""
    print_info "Generating 4 new cryptographic keys in '$DEST_KEYS_PATH'..."

    # 1. Generate Encrypted Private Key for Encryption
    print_info "Generating Encryption Private Key..."
    if openssl genpkey -algorithm RSA -out "$ENCRYPT_PRIV_KEY" -aes256 -pass pass:"$PASSPHRASE" -pkeyopt rsa_keygen_bits:4096 2>/dev/null; then
        print_success "Created: $(basename "$ENCRYPT_PRIV_KEY")"
    else
        print_error "Failed to generate Encryption Private Key"
        return 1
    fi

    # 2. Extract Public Key for Encryption
    print_info "Extracting Encryption Public Key..."
    if openssl rsa -in "$ENCRYPT_PRIV_KEY" -passin pass:"$PASSPHRASE" -pubout -out "$ENCRYPT_PUB_KEY" 2>/dev/null; then
        print_success "Created: $(basename "$ENCRYPT_PUB_KEY")"
    else
        print_error "Failed to extract Encryption Public Key"
        return 1
    fi

    # 3. Generate Encrypted Private Key for Signing
    print_info "Generating Signing Private Key..."
    if openssl genpkey -algorithm RSA -out "$SIGN_PRIV_KEY" -aes256 -pass pass:"$PASSPHRASE" -pkeyopt rsa_keygen_bits:4096 2>/dev/null; then
        print_success "Created: $(basename "$SIGN_PRIV_KEY")"
    else
        print_error "Failed to generate Signing Private Key"
        return 1
    fi

    # 4. Extract Public Key for Signing
    print_info "Extracting Signing Public Key..."
    if openssl rsa -in "$SIGN_PRIV_KEY" -passin pass:"$PASSPHRASE" -pubout -out "$SIGN_PUB_KEY" 2>/dev/null; then
        print_success "Created: $(basename "$SIGN_PUB_KEY")"
    else
        print_error "Failed to extract Signing Public Key"
        return 1
    fi

    echo ""
    print_info "Configuring key permissions..."
    chmod 600 "$DEST_KEYS_PATH"/*.pem

    print_success "Cryptographic keys setup completed successfully."

    # Summary
    echo ""
    print_info "Keys Summary:"
    echo "  📁 Destination: $DEST_KEYS_PATH/"
    echo "  🔑 Encrypt Private: $(basename "$ENCRYPT_PRIV_KEY")"
    echo "  🔑 Encrypt Public:  $(basename "$ENCRYPT_PUB_KEY")"
    echo "  🔑 Sign Private:    $(basename "$SIGN_PRIV_KEY")"
    echo "  🔑 Sign Public:     $(basename "$SIGN_PUB_KEY")"
    echo ""
    print_info "To view a key: cat $DEST_KEYS_PATH/filename.pem"
    print_warning "Keep your private keys and passphrase file secure!"

    return 0
}

# ----------------------------
# Execution
# ----------------------------
setup_crypto_keys