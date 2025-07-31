#!/bin/bash
# Claude Code NVM Integration - Gist-Powered Installer v3.0.0
set -e

# Configuration - UPDATE THIS WITH YOUR GIST ID
GIST_ID="YOUR_GIST_ID_HERE"  # Replace with your actual gist ID
GIST_URL="https://gist.githubusercontent.com/YOUR_USERNAME/${GIST_ID}/raw"

echo "🌩️  Claude Code Gist-Powered NVM Integration v3.0.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Gist: https://gist.github.com/${GIST_ID}"
echo ""

# Check if NVM is installed
if [ ! -d "$HOME/.nvm" ] || [ ! -s "$HOME/.nvm/nvm.sh" ]; then
    echo "❌ NVM not found. Please install NVM first."
    echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"
    exit 1
fi

echo "✅ Found NVM installation"

# Function to run commands with or without sudo
run_privileged() {
    if [ "$EUID" -eq 0 ]; then
        "$@"
    else
        if command -v sudo &> /dev/null; then
            sudo "$@"
        else
            echo "❌ Error: Need sudo for system package installation"
            exit 1
        fi
    fi
}

# Check gist accessibility
echo "🔍 Checking gist accessibility..."
if ! curl -sSf "${GIST_URL}/CLAUDE.md" >/dev/null 2>&1; then
    echo "❌ Cannot access gist: ${GIST_ID}"
    echo "   Please ensure:"
    echo "   1. Gist exists and is public"
    echo "   2. GIST_ID is correct in this script"
    echo "   3. CLAUDE.md file exists in the gist"
    exit 1
fi

echo "✅ Gist accessible"

# Install system dependencies
echo ""
echo "📦 Installing system dependencies..."

# Install Git LFS
if ! command -v git-lfs &> /dev/null; then
    echo "Installing Git LFS..."
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | run_privileged bash
    run_privileged apt-get update
    run_privileged apt-get install -y git-lfs
    git lfs install
fi

# Install GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /tmp/githubcli-archive-keyring.gpg
    run_privileged dd if=/tmp/githubcli-archive-keyring.gpg of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    run_privileged chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | run_privileged tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    run_privileged apt update
    run_privileged apt install -y gh
    rm -f /tmp/githubcli-archive-keyring.gpg
fi

# Install Python dependencies
if ! command -v pip3 &> /dev/null; then
    run_privileged apt-get install -y python3-pip
fi

# Install monitoring tools
if ! command -v htop &> /dev/null; then
    run_privileged apt-get install -y htop cmake libncurses5-dev libncursesw5-dev git
    
    if ! command -v nvtop &> /dev/null; then
        git clone https://github.com/Syllo/nvtop.git /tmp/nvtop
        mkdir -p /tmp/nvtop/build && cd /tmp/nvtop/build
        cmake .. && make && run_privileged make install
        cd ~ && rm -rf /tmp/nvtop
    fi
fi

# Install Python packages
echo "🐍 Installing Python packages..."
pip3 install --user --upgrade pip wandb huggingface_hub >/dev/null 2>&1

# Create directories
mkdir -p ~/.claude ~/.claude/commands ~/.local/bin ~/.nvm

# Download configuration files from gist
echo ""
echo "☁️  Downloading configuration from gist..."

echo "Downloading CLAUDE.md..."
curl -fsSL "${GIST_URL}/CLAUDE.md" -o ~/.claude/CLAUDE.md

echo "Downloading settings.json..."
curl -fsSL "${GIST_URL}/settings.json" -o ~/.claude/settings.json

echo "Downloading custom commands..."
curl -fsSL "${GIST_URL}/commands.md" -o /tmp/commands.md

# Extract individual command files from commands.md
mkdir -p ~/.claude/commands
cd ~/.claude/commands

# Parse the commands.md file to extract individual commands
awk '
/^## [a-zA-Z]/ {
    if (filename) close(filename)
    gsub(/^## /, "", $0)
    gsub(/ .*/, "", $0)
    filename = tolower($0) ".md"
    print "# " substr($0, 1, 1) toupper(substr($0, 2)) " Command" > filename
    next
}
filename { print > filename }
' /tmp/commands.md

rm /tmp/commands.md

echo "✅ Configuration downloaded from gist"

# Create the Claude package installer hook
cat > ~/.nvm/claude-hook.sh << 'EOH'
#!/bin/bash
# Claude Code Auto-Installer Hook for NVM

CLAUDE_PACKAGES=("@anthropic-ai/claude-code")
VERBOSE=true

log() {
    if [ "$VERBOSE" = true ]; then
        echo "$@"
    fi
}

install_claude_packages() {
    local node_version=$(node -v 2>/dev/null || echo "unknown")
    log "🔧 Ensuring Claude Code is available for Node.js $node_version..."
    
    if command -v claude >/dev/null 2>&1; then
        return 0
    fi
    
    local installed_any=false
    for package in "${CLAUDE_PACKAGES[@]}"; do
        if ! npm list -g "$package" >/dev/null 2>&1; then
            log "📦 Installing $package for Node.js $node_version..."
            if npm install -g "$package" >/dev/null 2>&1; then
                installed_any=true
            else
                echo "❌ Failed to install $package"
            fi
        fi
    done
    
    if [ "$installed_any" = true ]; then
        log "✅ Claude Code installed for Node.js $node_version"
    fi
}

ensure_claude_available() {
    if ! command -v claude >/dev/null 2>&1; then
        install_claude_packages
    fi
}

export -f install_claude_packages ensure_claude_available
EOH

chmod +x ~/.nvm/claude-hook.sh

# Create NVM wrapper
cat > ~/.nvm/nvm-claude-wrapper.sh << 'EOW'
#!/bin/bash
source "$HOME/.nvm/claude-hook.sh"

nvm() {
    local cmd="$1"
    command nvm "$@"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        case "$cmd" in
            "use"|"install"|"alias")
                (sleep 1 && ensure_claude_available) &
                ;;
        esac
    fi
    
    return $exit_code
}

ensure_claude_available >/dev/null 2>&1 &
EOW

chmod +x ~/.nvm/nvm-claude-wrapper.sh

# Create utility scripts
cat > ~/.local/bin/claude-sync << 'EOS'
#!/bin/bash
echo "🔄 Syncing Claude Code across all Node.js versions..."

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$HOME/.nvm/claude-hook.sh" ] && source "$HOME/.nvm/claude-hook.sh"

versions=$(command nvm list --no-colors | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/[^v0-9.]//g')
current_version=$(command nvm current)

for version in $versions; do
    echo "📦 Installing Claude Code for $version..."
    command nvm use "$version" >/dev/null 2>&1
    install_claude_packages
done

if [ "$current_version" != "none" ]; then
    command nvm use "$current_version" >/dev/null 2>&1
fi

echo "✅ Sync complete!"
EOS

cat > ~/.local/bin/claude-status << 'EOT'
#!/bin/bash
echo "📊 Claude Code Status Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

versions=$(command nvm list --no-colors | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/[^v0-9.]//g')
current_version=$(command nvm current)

for version in $versions; do
    command nvm use "$version" >/dev/null 2>&1
    if npm list -g @anthropic-ai/claude-code >/dev/null 2>&1; then
        pkg_version=$(npm list -g @anthropic-ai/claude-code --depth=0 2>/dev/null | grep @anthropic-ai/claude-code | sed 's/.*@//' | sed 's/ .*//')
        echo "✅ $version: claude-code@$pkg_version"
    else
        echo "❌ $version: claude-code missing"
    fi
done

if [ "$current_version" != "none" ]; then
    command nvm use "$current_version" >/dev/null 2>&1
fi

echo ""
echo "Commands: claude-sync | claude-status | claude-update"
EOT

cat > ~/.local/bin/claude-update << EOF
#!/bin/bash
echo "🔄 Updating Claude Code configuration from gist..."

GIST_URL="$GIST_URL"

# Backup current configuration
backup_dir="\$HOME/.claude/backup-\$(date +%Y%m%d-%H%M%S)"
mkdir -p "\$backup_dir"
cp -r ~/.claude/* "\$backup_dir/" 2>/dev/null || true

# Download updated files
curl -fsSL "\${GIST_URL}/CLAUDE.md" -o ~/.claude/CLAUDE.md
curl -fsSL "\${GIST_URL}/settings.json" -o ~/.claude/settings.json
curl -fsSL "\${GIST_URL}/commands.md" -o /tmp/commands.md

# Extract commands
cd ~/.claude/commands
awk '
/^## [a-zA-Z]/ {
    if (filename) close(filename)
    gsub(/^## /, "", \$0)
    gsub(/ .*/, "", \$0)
    filename = tolower(\$0) ".md"
    print "# " substr(\$0, 1, 1) toupper(substr(\$0, 2)) " Command" > filename
    next
}
filename { print > filename }
' /tmp/commands.md

rm /tmp/commands.md

echo "✅ Configuration updated from gist"
echo "📁 Backup saved to: \$backup_dir"
EOF

chmod +x ~/.local/bin/claude-sync ~/.local/bin/claude-status ~/.local/bin/claude-update

# Add shell integration
if ! grep -q "nvm-claude-wrapper" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOB'

# Claude Code NVM Integration
if [ -s "$HOME/.nvm/nvm-claude-wrapper.sh" ]; then
    source "$HOME/.nvm/nvm-claude-wrapper.sh"
fi
export PATH="$HOME/.local/bin:$PATH"
EOB
fi

# Install Claude Code for current Node.js version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
source ~/.nvm/claude-hook.sh
install_claude_packages

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Gist-Powered Installation Complete!"
echo ""
echo "🌩️  Configuration synced from gist"
echo "🔄 Use 'claude-update' to pull latest changes"
echo "📝 Edit your gist to update across all machines"
echo ""
echo "🛠️  Commands:"
echo "   claude-sync   - Sync across all Node versions"
echo "   claude-status - Check installation status"
echo "   claude-update - Update from gist"
echo ""
echo "🔄 Restart terminal or run: source ~/.bashrc"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"