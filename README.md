# 🔐 CryptoKeyGen – RSA Key Pair Generator
Automated bash script for generating and managing RSA cryptographic key pairs (4096‑bit) with AES‑256 encryption. Built for Linux environments, it handles OpenSSL installation, passphrase management, timestamped keys, and secure permissions—ideal for DevOps, CI/CD pipelines, and security‑conscious deployments.

# ✨ Features
🔄 Automatic OpenSSL Installation – Detects your Linux distribution (Fedora/RHEL, Debian/Ubuntu, Arch) and installs OpenSSL if missing

🔑 Secure Key Generation – Creates 4096‑bit RSA keys with AES‑256 encryption for both encryption and digital signing

🕒 Timestamped Keys – Each key includes a timestamp for version tracking and auditability

🔐 Automatic Passphrase Creation – Generates a sample passphrase file if none exists

🛡️ Secure Permissions – Sets proper file permissions (600 for keys, 700 for directory)

🎨 Color‑coded Output – Easy‑to‑read console feedback with info, success, and error messages

🐧 Multi‑distribution Support – Works on Fedora/RHEL, Debian/Ubuntu, and Arch Linux

# 📋 Requirements
Requirement	Details
OS	Linux (Fedora, RHEL, Debian/Ubuntu, Arch)
Bash	Version 4.0 or higher
OpenSSL	Installed automatically if missing
sudo	Required for package installation
Supported Distributions
Distribution	Package Manager
Fedora / RHEL	dnf
Debian / Ubuntu	apt-get
Arch Linux	pacman

# 🚀 Usage
1. Save the Script
Save the script as setup_keys.sh in your project directory:

bash
nano setup_keys.sh
# Copy and paste the script content
2. Make it Executable
bash
chmod +x setup_keys.sh
3. Run the Script
bash
./setup_keys.sh
📁 Generated Keys
The script generates four cryptographic keys:

Encryption Key Pair – RSA 4096‑bit keys for data encryption/decryption

Signing Key Pair – RSA 4096‑bit keys for digital signatures

All private keys are encrypted with AES‑256 using a passphrase stored in a separate file.

# 🛠️ Tech Stack
Bash – Core scripting language

OpenSSL – Cryptographic operations (RSA, AES‑256)

Linux – Target environment