#!/usr/bin/env bash
# Claude Code NVM Integration - Cross-Platform Installer v4.0.0
# Works on macOS, Linux, and Windows (WSL/Git Bash)
set -e

# Configuration - UPDATE THIS WITH YOUR GIST ID
GIST_ID="18b75f992de5ecfc7fce2eee32b992bf"
GIST_URL="https://gist.githubusercontent.com/johnccarroll/${GIST_ID}/raw"
# Remote filename for user-global AGENT (different name in GitHub/gist), installed as ~/.config/AGENT.MD
GIST_USER_AGENT_FILENAME="AGENT-GLOBAL-BLUEPRINT.md"

echo "🌍 Claude Code Cross-Platform NVM Integration v4.0.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Gist: https://gist.github.com/${GIST_ID}"
echo ""

# Detect operating system and architecture
detect_os() {
    case "$(uname -s)" in
        Darwin*) 
            OS="macos"
            ARCH=$(uname -m)
            if [ "$ARCH" = "arm64" ]; then
                ARCH="arm64"
            else
                ARCH="amd64"
            fi
            ;;
        Linux*)  
            OS="linux"
            ARCH=$(uname -m)
            case $ARCH in
                x86_64) ARCH="amd64" ;;
                aarch64) ARCH="arm64" ;;
                armv7l) ARCH="armv7" ;;
            esac
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS="windows"
            ARCH="amd64"
            ;;
        *)
            echo "❌ Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
    
    echo "🔍 Detected: $OS ($ARCH)"
}

# Detect available shells
detect_shell() {
    SHELL_CONFIGS=()
    
    # Check for zsh
    if [ -f "$HOME/.zshrc" ] || command -v zsh >/dev/null 2>&1; then
        SHELL_CONFIGS+=("$HOME/.zshrc")
    fi
    
    # Check for bash
    if [ -f "$HOME/.bashrc" ] || command -v bash >/dev/null 2>&1; then
        SHELL_CONFIGS+=("$HOME/.bashrc")
    fi
    
    # If no config files exist, create based on current shell or default
    if [ ${#SHELL_CONFIGS[@]} -eq 0 ]; then
        case "$SHELL" in
            */zsh)
                SHELL_CONFIGS=("$HOME/.zshrc")
                ;;
            */bash)
                SHELL_CONFIGS=("$HOME/.bashrc")
                ;;
            *)
                # Default to zsh on macOS, bash elsewhere
                if [ "$OS" = "macos" ]; then
                    SHELL_CONFIGS=("$HOME/.zshrc")
                else
                    SHELL_CONFIGS=("$HOME/.bashrc")
                fi
                ;;
        esac
    fi
    
    echo "🐚 Shell configs: ${SHELL_CONFIGS[*]}"
}

# Check if NVM is installed
check_nvm() {
    if [ ! -d "$HOME/.nvm" ] || [ ! -s "$HOME/.nvm/nvm.sh" ]; then
        echo "❌ NVM not found. Please install NVM first:"
        echo ""
        case $OS in
            macos|linux)
                echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"
                echo "   source ~/.${SHELL_TYPE}rc"
                ;;
            windows)
                echo "   Use nvm-windows: https://github.com/coreybutler/nvm-windows"
                ;;
        esac
        exit 1
    fi
    
    echo "✅ Found NVM installation"
}

# Check gist accessibility
check_gist() {
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
}

# Install package manager if needed
install_package_manager() {
    case $OS in
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                echo "📦 Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH for current session
                if [ "$ARCH" = "arm64" ]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            else
                echo "✅ Homebrew already installed"
            fi
            ;;
        linux)
            # Linux uses built-in package managers (apt, yum, etc.)
            echo "✅ Using system package manager"
            ;;
        windows)
            # Check for Chocolatey or WinGet
            if ! command -v choco >/dev/null 2>&1 && ! command -v winget >/dev/null 2>&1; then
                echo "📦 Installing Chocolatey..."
                powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command \
                    "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
            else
                echo "✅ Package manager available"
            fi
            ;;
    esac
}

# Function to run privileged commands
run_privileged() {
    case $OS in
        macos|linux)
            if [ "$EUID" -eq 0 ]; then
                "$@"
            elif command -v sudo >/dev/null 2>&1; then
                sudo "$@"
            else
                echo "❌ Error: Need sudo for system package installation"
                exit 1
            fi
            ;;
        windows)
            # Windows commands typically don't need sudo
            "$@"
            ;;
    esac
}

# Install Git LFS cross-platform
install_git_lfs() {
    if command -v git-lfs >/dev/null 2>&1; then
        echo "✅ Git LFS already installed"
        return 0
    fi
    
    echo "📦 Installing Git LFS..."
    
    case $OS in
        macos)
            brew install git-lfs
            ;;
        linux)
            # Try different Linux package managers
            if command -v apt >/dev/null 2>&1; then
                run_privileged apt update
                run_privileged apt install -y git-lfs
            elif command -v yum >/dev/null 2>&1; then
                run_privileged yum install -y git-lfs
            elif command -v dnf >/dev/null 2>&1; then
                run_privileged dnf install -y git-lfs
            elif command -v pacman >/dev/null 2>&1; then
                run_privileged pacman -S --noconfirm git-lfs
            else
                echo "⚠️  Warning: Could not determine package manager for Git LFS"
                return 1
            fi
            ;;
        windows)
            if command -v choco >/dev/null 2>&1; then
                choco install git-lfs -y
            elif command -v winget >/dev/null 2>&1; then
                winget install Git.LFS
            else
                echo "⚠️  Warning: No package manager found for Git LFS"
                return 1
            fi
            ;;
    esac
    
    git lfs install
    echo "✅ Git LFS installed"
}

# Install GitHub CLI cross-platform
install_github_cli() {
    if command -v gh >/dev/null 2>&1; then
        echo "✅ GitHub CLI already installed"
        return 0
    fi
    
    echo "📦 Installing GitHub CLI..."
    
    case $OS in
        macos)
            brew install gh
            ;;
        linux)
            if command -v apt >/dev/null 2>&1; then
                # Official GitHub CLI installation for Ubuntu/Debian
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | run_privileged dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                run_privileged chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | run_privileged tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                run_privileged apt update
                run_privileged apt install -y gh
            elif command -v yum >/dev/null 2>&1; then
                run_privileged yum install -y gh
            elif command -v dnf >/dev/null 2>&1; then
                run_privileged dnf install -y gh
            else
                echo "⚠️  Warning: Could not install GitHub CLI via package manager"
                return 1
            fi
            ;;
        windows)
            if command -v choco >/dev/null 2>&1; then
                choco install gh -y
            elif command -v winget >/dev/null 2>&1; then
                winget install GitHub.CLI
            else
                echo "⚠️  Warning: No package manager found for GitHub CLI"
                return 1
            fi
            ;;
    esac
    
    echo "✅ GitHub CLI installed"
}

# Install Python and packages cross-platform
install_python_packages() {
    echo "🐍 Installing Python packages..."
    
    # Check if pip3 is available
    if ! command -v pip3 >/dev/null 2>&1; then
        case $OS in
            macos)
                # Python3 should be available on modern macOS
                if ! command -v python3 >/dev/null 2>&1; then
                    brew install python
                fi
                ;;
            linux)
                if command -v apt >/dev/null 2>&1; then
                    run_privileged apt install -y python3-pip
                elif command -v yum >/dev/null 2>&1; then
                    run_privileged yum install -y python3-pip
                elif command -v dnf >/dev/null 2>&1; then
                    run_privileged dnf install -y python3-pip
                fi
                ;;
            windows)
                if command -v choco >/dev/null 2>&1; then
                    choco install python -y
                elif command -v winget >/dev/null 2>&1; then
                    winget install Python.Python.3.12
                fi
                ;;
        esac
    fi
    
    # Install Python packages
    pip3 install --user --upgrade pip wandb huggingface_hub 2>/dev/null || {
        echo "⚠️  Warning: Some Python packages may have failed to install"
    }
    
    echo "✅ Python packages installed"
}

# Install monitoring tools (optional)
install_monitoring_tools() {
    echo "📊 Installing monitoring tools..."
    
    case $OS in
        macos)
            if ! command -v htop >/dev/null 2>&1; then
                brew install htop
            fi
            # nvtop for macOS
            if ! command -v nvtop >/dev/null 2>&1; then
                brew install nvtop
            fi
            ;;
        linux)
            if command -v apt >/dev/null 2>&1; then
                run_privileged apt install -y htop
                # Try to install nvtop
                run_privileged apt install -y nvtop 2>/dev/null || {
                    echo "⚠️  nvtop not available via package manager"
                }
            elif command -v yum >/dev/null 2>&1; then
                run_privileged yum install -y htop
            elif command -v dnf >/dev/null 2>&1; then
                run_privileged dnf install -y htop
            fi
            ;;
        windows)
            # Windows equivalent monitoring tools
            if command -v choco >/dev/null 2>&1; then
                choco install htop -y 2>/dev/null || echo "⚠️  htop not available on Windows"
            fi
            ;;
    esac
    
    echo "✅ Monitoring tools installed"
}

# Download configuration files from gist
download_configuration() {
    echo "☁️  Downloading configuration from gist..."
    
    # Create directories
    mkdir -p ~/.claude ~/.claude/commands ~/.local/bin ~/.nvm ~/.config
    
    echo "Downloading CLAUDE.md..."
    curl -fsSL "${GIST_URL}/CLAUDE.md" -o ~/.claude/CLAUDE.md
    
    # Root-level AGENT blueprint
    echo "Downloading AGENT-ROOT-BLUEPRINT.md (optional)..."
    if curl -fsSL "${GIST_URL}/AGENT-ROOT-BLUEPRINT.md" -o ~/.claude/AGENT-ROOT-BLUEPRINT.md 2>/dev/null; then
        echo "✅ AGENT-ROOT-BLUEPRINT.md downloaded from gist"
    else
        if [ -f "$(pwd)/AGENT-ROOT-BLUEPRINT.md" ]; then
            cp "$(pwd)/AGENT-ROOT-BLUEPRINT.md" ~/.claude/AGENT-ROOT-BLUEPRINT.md
            echo "✅ AGENT-ROOT-BLUEPRINT.md copied from local repository"
        else
            # Fallback to legacy AGENT-BLUEPRINT.md naming if present in gist
            if curl -fsSL "${GIST_URL}/AGENT-BLUEPRINT.md" -o ~/.claude/AGENT-ROOT-BLUEPRINT.md 2>/dev/null; then
                echo "✅ AGENT-ROOT-BLUEPRINT.md populated from AGENT-BLUEPRINT.md in gist"
            else
                cat > ~/.claude/AGENT-ROOT-BLUEPRINT.md << 'EOF'
# AGENT.md (Root-Level) Blueprint

## Project Overview
- Name: <PROJECT_NAME>
- Summary: <ONE_SENTENCE_DESCRIPTION>

## Build & Commands
- Install: <CMD>
- Test: <CMD>
- Dev: <CMD>

## Code Style
- <RULES>

## Architecture
- <NOTES>

## Testing
- <NOTES>

## Security
- <NOTES>
EOF
                echo "✅ AGENT-ROOT-BLUEPRINT.md created from default template"
            fi
        fi
    fi

    # Subsystem AGENT blueprint
    echo "Downloading AGENT-SUBSYSTEM-BLUEPRINT.md (optional)..."
    if curl -fsSL "${GIST_URL}/AGENT-SUBSYSTEM-BLUEPRINT.md" -o ~/.claude/AGENT-SUBSYSTEM-BLUEPRINT.md 2>/dev/null; then
        echo "✅ AGENT-SUBSYSTEM-BLUEPRINT.md downloaded from gist"
    else
        if [ -f "$(pwd)/AGENT-SUBSYSTEM-BLUEPRINT.md" ]; then
            cp "$(pwd)/AGENT-SUBSYSTEM-BLUEPRINT.md" ~/.claude/AGENT-SUBSYSTEM-BLUEPRINT.md
            echo "✅ AGENT-SUBSYSTEM-BLUEPRINT.md copied from local repository"
        else
            cat > ~/.claude/AGENT-SUBSYSTEM-BLUEPRINT.md << 'EOF'
# AGENT.md (Subsystem) Blueprint

## Subsystem Overview
- Name: <SUBSYSTEM_NAME>
- Purpose: <BRIEF>

## Commands
- Dev: <CMD>
- Test: <CMD>
- Build: <CMD>
EOF
            echo "✅ AGENT-SUBSYSTEM-BLUEPRINT.md created from default template"
        fi
    fi

    # User-global AGENT: install from gist under configured remote filename
    echo "Updating user-global ~/.config/AGENT.MD from gist (if available)..."
    if curl -fsSL "${GIST_URL}/${GIST_USER_AGENT_FILENAME}" -o /tmp/AGENT.USER.GLOBAL 2>/dev/null; then
        if [ -f "$HOME/.config/AGENT.MD" ]; then
            cp "$HOME/.config/AGENT.MD" "$HOME/.config/AGENT.MD.bak-$(date +%Y%m%d-%H%M%S)"
        fi
        mv /tmp/AGENT.USER.GLOBAL "$HOME/.config/AGENT.MD"
        echo "✅ Installed user-global AGENT.MD from gist file: ${GIST_USER_AGENT_FILENAME}"
    else
        if [ -f "$(pwd)/AGENT-GLOBAL-BLUEPRINT.md" ]; then
            cp "$(pwd)/AGENT-GLOBAL-BLUEPRINT.md" "$HOME/.config/AGENT.MD"
            echo "✅ Installed user-global AGENT.MD from local blueprint"
        else
            # Minimal default
            cat > "$HOME/.config/AGENT.MD" << 'EOF'
# AGENT.md (User-Global)

Personal preferences for agentic tools. Repository `AGENT.md` always takes precedence.
EOF
            echo "✅ Created minimal user-global AGENT.MD"
        fi
    fi

    # Create lowercase symlink for compatibility (if not exists)
    if [ ! -e "$HOME/.config/AGENT.md" ]; then
        ln -sf "$HOME/.config/AGENT.MD" "$HOME/.config/AGENT.md"
    fi
    
    echo "Downloading settings.json..."
    curl -fsSL "${GIST_URL}/settings.json" -o ~/.claude/settings.json
    
    echo "Downloading custom commands..."
    curl -fsSL "${GIST_URL}/commands.md" -o /tmp/commands.md
    
    # Extract individual command files from commands.md
    cd ~/.claude/commands
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
}

# Create Claude auto-installer hook
create_claude_hook() {
    echo "🪝 Creating Claude auto-installer hook..."
    
    cat > ~/.nvm/claude-hook.sh << 'EOH'
#!/usr/bin/env bash
# Claude Code Auto-Installer Hook for NVM (Cross-Platform)

CLAUDE_PACKAGES=("@anthropic-ai/claude-code")
VERBOSE=false

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

# Functions are available in this script context only
EOH
    
    chmod +x ~/.nvm/claude-hook.sh
}

# Create NVM wrapper
create_nvm_wrapper() {
    echo "🔄 Creating NVM wrapper..."
    
    cat > ~/.nvm/nvm-claude-wrapper.sh << 'EOW'
#!/usr/bin/env bash
# NVM wrapper with Claude Code auto-install (Cross-Platform)

source "$HOME/.nvm/claude-hook.sh"

nvm() {
    local cmd="$1"
    command nvm "$@"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        case "$cmd" in
            "use"|"install"|"alias")
                (ensure_claude_available >/dev/null 2>&1) &
                ;;
        esac
    fi
    
    return $exit_code
}

# Only run initial check if this is an interactive shell (silently)
if [[ $- == *i* ]] && ! command -v claude >/dev/null 2>&1; then
    (ensure_claude_available >/dev/null 2>&1) &
fi
EOW
    
    chmod +x ~/.nvm/nvm-claude-wrapper.sh
}

# Create utility scripts
create_utilities() {
    echo "🛠️  Creating utility scripts..."
    
    # claude-sync script (combined: update from gist + sync across Node versions)
    cat > ~/.local/bin/claude-sync << EOF
#!/usr/bin/env bash
set -e

echo "🔄 Updating global config from gist and syncing Claude Code across Node.js versions..."

GIST_URL="${GIST_URL}"
GIST_USER_AGENT_FILENAME="${GIST_USER_AGENT_FILENAME}"

# Ensure directories
mkdir -p "\$HOME/.claude/commands" "\$HOME/.config" "\$HOME/.nvm"

# Update Claude config cache from gist
curl -fsSL "\${GIST_URL}/CLAUDE.md" -o "\$HOME/.claude/CLAUDE.md"
curl -fsSL "\${GIST_URL}/settings.json" -o "\$HOME/.claude/settings.json"
curl -fsSL "\${GIST_URL}/commands.md" -o /tmp/commands.md

# Extract individual command files
cd "\$HOME/.claude/commands"
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

# Update blueprint caches (optional)
curl -fsSL "\${GIST_URL}/AGENT-ROOT-BLUEPRINT.md" -o "\$HOME/.claude/AGENT-ROOT-BLUEPRINT.md" 2>/dev/null || true
curl -fsSL "\${GIST_URL}/AGENT-SUBSYSTEM-BLUEPRINT.md" -o "\$HOME/.claude/AGENT-SUBSYSTEM-BLUEPRINT.md" 2>/dev/null || true

# Update user-global AGENT.MD from gist; do not touch project AGENT.md files
if curl -fsSL "\${GIST_URL}/\${GIST_USER_AGENT_FILENAME}" -o /tmp/AGENT.USER.GLOBAL 2>/dev/null; then
  if [ -f "\$HOME/.config/AGENT.MD" ]; then
    cp "\$HOME/.config/AGENT.MD" "\$HOME/.config/AGENT.MD.bak-\$(date +%Y%m%d-%H%M%S)"
  fi
  mv /tmp/AGENT.USER.GLOBAL "\$HOME/.config/AGENT.MD"
  echo "✅ Updated user-global AGENT.MD from gist"
fi

# Maintain lowercase symlink for compatibility
if [ ! -e "\$HOME/.config/AGENT.md" ]; then
  ln -sf "\$HOME/.config/AGENT.MD" "\$HOME/.config/AGENT.md"
fi

# Load NVM properly
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"
[ -s "\$HOME/.nvm/claude-hook.sh" ] && source "\$HOME/.nvm/claude-hook.sh"

# Check if NVM is available
if ! command -v nvm >/dev/null 2>&1; then
  echo "❌ NVM not found in PATH"
  echo "   Make sure NVM is properly installed and sourced in your shell"
  exit 1
fi

versions=\$(nvm list --no-colors 2>/dev/null | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/[^v0-9.]//g')
current_version=\$(nvm current 2>/dev/null || echo "none")

for version in \$versions; do
  echo "📦 Ensuring Claude Code for \$version..."
  nvm use "\$version" >/dev/null 2>&1
  install_claude_packages
done

if [ "\$current_version" != "none" ]; then
  nvm use "\$current_version" >/dev/null 2>&1
fi

echo "✅ Sync complete!"
EOF
    
    # claude-status script
    cat > ~/.local/bin/claude-status << 'EOT'
#!/usr/bin/env bash
echo "📊 Claude Code Status Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Load NVM properly
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Check if NVM is available
if ! command -v nvm >/dev/null 2>&1; then
    echo "❌ NVM not found in PATH"
    echo "   Make sure NVM is properly installed and sourced in your shell"
    exit 1
fi

versions=$(nvm list --no-colors 2>/dev/null | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/[^v0-9.]//g')
current_version=$(nvm current 2>/dev/null || echo "none")

for version in $versions; do
    nvm use "$version" >/dev/null 2>&1
    if npm list -g @anthropic-ai/claude-code >/dev/null 2>&1; then
        pkg_version=$(npm list -g @anthropic-ai/claude-code --depth=0 2>/dev/null | grep @anthropic-ai/claude-code | sed 's/.*@//' | sed 's/ .*//') 
        echo "✅ $version: claude-code@$pkg_version"
    else
        echo "❌ $version: claude-code missing"
    fi
done

if [ "$current_version" != "none" ]; then
    nvm use "$current_version" >/dev/null 2>&1
fi

echo ""
echo "Commands: claude-sync | claude-status | claude-update"
EOT
    
    # removed: claude-update alias (use claude-sync only)
    
    # agent-init script (create/verify AGENT.md for root or subsystem)
    cat > ~/.local/bin/agent-init << 'EOA'
#!/usr/bin/env bash
# Initialize AGENT.md from blueprints.

set -e

usage() {
  cat <<USAGE
Usage: agent-init [--subsystem]

Without flags, ensures a root-level AGENT.md exists at the repository root.
With --subsystem, creates a scoped AGENT.md in the current subdirectory.
USAGE
}

MODE="root"
if [ "$1" = "--subsystem" ]; then
  MODE="subsystem"
elif [ -n "$1" ]; then
  usage
  exit 1
fi

# Detect repo root (if inside a git repository)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
else
  REPO_ROOT=$(pwd)
fi

if [ "$MODE" = "root" ]; then
  TARGET="$REPO_ROOT/AGENT.md"
  BLUEPRINT="$HOME/.claude/AGENT-ROOT-BLUEPRINT.md"
else
  TARGET="$(pwd)/AGENT.md"
  BLUEPRINT="$HOME/.claude/AGENT-SUBSYSTEM-BLUEPRINT.md"
fi

ensure_file() {
  if [ ! -f "$TARGET" ]; then
    if [ -f "$BLUEPRINT" ]; then
      cp "$BLUEPRINT" "$TARGET"
    else
      cat > "$TARGET" << 'EOF'
# AGENT.md

Please customize this file for your project. See https://agent.md for guidance.
EOF
    fi
    echo "🧭 Created AGENT.md: $TARGET"
    CREATED=1
  fi
}

prompt_if_placeholder() {
  if grep -q "<PROJECT_NAME>\|AGENT.md initial blueprint" "$TARGET" 2>/dev/null; then
    echo "✍️  AGENT.md contains placeholders. Please update it to reflect your project."
    echo "    File: $TARGET"
  fi
}

tip_for_subsystem() {
  if [ "$MODE" = "root" ] && [ -d "$REPO_ROOT" ] && [ "$(pwd)" != "$REPO_ROOT" ] && [ ! -f "$(pwd)/AGENT.md" ]; then
    echo "💡 Tip: To create a scoped AGENT.md for this subdirectory, run: agent-init --subsystem"
  fi
}

ensure_file
prompt_if_placeholder
tip_for_subsystem
EOA

    # No backward-compatible alias is required

    # claude wrapper: run agent-init automatically before invoking real CLI
    cat > ~/.local/bin/claude << 'EOC'
#!/usr/bin/env bash

# Run AGENT.md initialization/check
if command -v agent-init >/dev/null 2>&1; then
  agent-init >/dev/null 2>&1 || true
fi

# Try to locate the real claude CLI installed by npm
REAL_BIN="$(npm bin -g 2>/dev/null)/claude"
if [ -x "$REAL_BIN" ]; then
  exec "$REAL_BIN" "$@"
fi

# Fallback: temporarily drop ~/.local/bin from PATH and try again
SAFE_PATH=$(printf "%s" "$PATH" | awk -v RS=: -v ORS=: -v p="$HOME/.local/bin" '$0 != p {print}' | sed 's/:$//')
exec env PATH="$SAFE_PATH" claude "$@"
EOC

    chmod +x \
      ~/.local/bin/claude-sync \
      ~/.local/bin/claude-status \
      ~/.local/bin/agent-init \
      ~/.local/bin/claude
}

# Add shell integration
add_shell_integration() {
    echo "🐚 Adding shell integration..."
    
    local integration_block='
# Claude Code NVM Integration (Cross-Platform)
if [ -s "$HOME/.nvm/nvm-claude-wrapper.sh" ]; then
    source "$HOME/.nvm/nvm-claude-wrapper.sh"
fi
export PATH="$HOME/.local/bin:$PATH"

# Platform-specific PATH additions
case "$(uname -s)" in
    Darwin*)
        # macOS Homebrew paths
        if [ -d "/opt/homebrew/bin" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -d "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        ;;
esac'
    
    for shell_config in "${SHELL_CONFIGS[@]}"; do
        echo "  📝 Updating $(basename "$shell_config")..."
        
        # Check if already integrated
        if grep -q "nvm-claude-wrapper" "$shell_config" 2>/dev/null; then
            echo "     ⚠️  Integration already exists, skipping..."
            continue
        fi
        
        # Create config file if it doesn't exist
        touch "$shell_config"
        
        # Add integration
        echo "$integration_block" >> "$shell_config"
        echo "     ✅ Integration added"
    done
    
    echo "✅ Shell integration complete"
}

# Initial Claude Code installation
install_initial_claude() {
    echo "🚀 Installing Claude Code for current Node.js version..."
    
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    source ~/.nvm/claude-hook.sh
    install_claude_packages
    
    echo "✅ Initial Claude Code installation complete"
}

# Main installation flow
main() {
    detect_os
    detect_shell
    check_nvm
    check_gist
    
    echo ""
    echo "📦 Installing dependencies..."
    install_package_manager
    install_git_lfs
    install_github_cli
    install_python_packages
    install_monitoring_tools
    
    echo ""
    download_configuration
    create_claude_hook
    create_nvm_wrapper
    create_utilities
    add_shell_integration
    install_initial_claude
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Cross-Platform Installation Complete!"
    echo ""
    echo "🌍 Platform: $OS ($ARCH)"
    echo "🐚 Shell configs: ${SHELL_CONFIGS[*]}"
    echo "🌩️  Configuration synced from gist"
    echo ""
    echo "🛠️  Commands:"
    echo "   claude-sync   - Sync across all Node versions"
    echo "   claude-status - Check installation status"
    echo "   agent-init    - Create/verify AGENT.md in current repository"
    echo ""
    echo "🔄 Restart terminal or source your shell config to activate changes"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Run main installation
main "$@"