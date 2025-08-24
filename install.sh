#!/usr/bin/env bash
# Agent Development Environment Setup - Cross-Platform Installer v4.0.0
# Works on macOS, Linux, and Windows (WSL/Git Bash)
set -e

REPO_URL="https://raw.githubusercontent.com/johnccarroll/agent/main"
USER_AGENT_FILENAME="AGENTS.md"

echo "🌍 Agent Development Environment Setup v4.0.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Repo: https://github.com/johnccarroll/agent"
echo ""

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

detect_shell() {
    SHELL_CONFIGS=()
    
    if [ -f "$HOME/.zshrc" ] || command -v zsh >/dev/null 2>&1; then
        SHELL_CONFIGS+=("$HOME/.zshrc")
    fi
    
    if [ -f "$HOME/.bashrc" ] || command -v bash >/dev/null 2>&1; then
        SHELL_CONFIGS+=("$HOME/.bashrc")
    fi
    
    if [ ${#SHELL_CONFIGS[@]} -eq 0 ]; then
        case "$SHELL" in
            */zsh)
                SHELL_CONFIGS=("$HOME/.zshrc")
                ;;
            */bash)
                SHELL_CONFIGS=("$HOME/.bashrc")
                ;;
            *)
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

check_repo() {
    echo "🔍 Checking repo accessibility..."
    if ! curl -sSf "${REPO_URL}/AGENTS.md" >/dev/null 2>&1; then
        echo "❌ Cannot access repo: https://github.com/johnccarroll/agent"
        echo "   Please ensure:"
        echo "   1. Repository exists and is public"
        echo "   2. AGENTS.md file exists in the repo"
        echo "   3. Network connection is working"
        exit 1
    fi
    
    echo "✅ Repo accessible"
}

install_package_manager() {
    case $OS in
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                echo "📦 Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
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
            echo "✅ Using system package manager"
            ;;
        windows)
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
            "$@"
            ;;
    esac
}

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

install_python_packages() {
    echo "🐍 Installing Python packages..."
    
    if ! command -v pip3 >/dev/null 2>&1; then
        case $OS in
            macos)
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
    
    pip3 install --user --upgrade pip wandb huggingface_hub 2>/dev/null || {
        echo "⚠️  Warning: Some Python packages may have failed to install"
    }
    
    echo "✅ Python packages installed"
}

install_monitoring_tools() {
    echo "📊 Installing monitoring tools..."
    
    case $OS in
        macos)
            if ! command -v htop >/dev/null 2>&1; then
                brew install htop
            fi
            if ! command -v nvtop >/dev/null 2>&1; then
                brew install nvtop
            fi
            ;;
        linux)
            if command -v apt >/dev/null 2>&1; then
                run_privileged apt install -y htop
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
            if command -v choco >/dev/null 2>&1; then
                choco install htop -y 2>/dev/null || echo "⚠️  htop not available on Windows"
            fi
            ;;
    esac
    
    echo "✅ Monitoring tools installed"
}

download_configuration() {
    echo "☁️  Downloading configuration from repo..."
    
    mkdir -p ~/.claude ~/.local/bin ~/.config/agent
    
    # Ensure global canonical config exists at ~/.config/agent/AGENTS.md
    if [ -f "$HOME/.config/AGENT.MD" ] && [ ! -f "$HOME/.config/agent/AGENTS.md" ]; then
        mv "$HOME/.config/AGENT.MD" "$HOME/.config/agent/AGENTS.md"
        echo "✅ Migrated ~/.config/AGENT.MD -> ~/.config/agent/AGENTS.md"
    fi
    if [ -f "$HOME/.config/AGENT.md" ] && [ ! -f "$HOME/.config/agent/AGENTS.md" ]; then
        mv "$HOME/.config/AGENT.md" "$HOME/.config/agent/AGENTS.md"
        echo "✅ Migrated ~/.config/AGENT.md -> ~/.config/agent/AGENTS.md"
    fi
    if [ -f "$HOME/.config/AGENTS.md" ] && [ ! -f "$HOME/.config/agent/AGENTS.md" ]; then
        mv "$HOME/.config/AGENTS.md" "$HOME/.config/agent/AGENTS.md"
        echo "✅ Migrated ~/.config/AGENTS.md -> ~/.config/agent/AGENTS.md"
    fi
    
    echo "Downloading AGENTS-template.md (optional)..."
    if curl -fsSL "${REPO_URL}/AGENTS-template.md" -o ~/.claude/AGENTS-template.md 2>/dev/null; then
        echo "✅ AGENTS-template.md downloaded from repo"
    else
        if [ -f "$(pwd)/AGENTS-template.md" ]; then
            cp "$(pwd)/AGENTS-template.md" ~/.claude/AGENTS-template.md
            echo "✅ AGENTS-template.md copied from local repository"
        else
            cat > ~/.claude/AGENTS-template.md << 'EOF'
# AGENTS.md Template

Personal preferences for agentic tools. Repository `AGENTS.md` always takes precedence.

## Preferences

- Editor: <e.g., VS Code>
- Tab width / indentation: <e.g., 2 spaces>
- Line length: <e.g., 100>
- Preferred package manager: <npm/pnpm/yarn>
- Testing preference: <e.g., vitest>

## Behaviors

- Auto-run checks before commit: <true/false>
- Prefer CLI over GUI tooling: <true/false>
- Ask before running migrations: <true/false>

## Security & Privacy

- Never upload proprietary code to remote analysis tools
- Redact secrets in logs and debugging output
EOF
            echo "✅ AGENTS-template.md created from default template"
        fi
    fi

    echo "Updating user-global ~/.config/agent/AGENTS.md from repo (if available)..."
    if curl -fsSL "${REPO_URL}/${USER_AGENT_FILENAME}" -o /tmp/AGENT.USER.GLOBAL 2>/dev/null; then
        if [ -f "$HOME/.config/agent/AGENTS.md" ]; then
            cp "$HOME/.config/agent/AGENTS.md" "$HOME/.config/agent/AGENTS.md.bak-$(date +%Y%m%d-%H%M%S)"
        fi
        mv /tmp/AGENT.USER.GLOBAL "$HOME/.config/agent/AGENTS.md"
        echo "✅ Installed user-global AGENTS.md from repo"
    else
        if [ -f "$(pwd)/AGENTS.md" ]; then
            cp "$(pwd)/AGENTS.md" "$HOME/.config/agent/AGENTS.md"
            echo "✅ Installed user-global AGENTS.md from local project file"
        else
            cat > "$HOME/.config/agent/AGENTS.md" << 'EOF'
# AGENTS.md (User-Global)

Personal preferences for agentic tools. Repository `AGENTS.md` always takes precedence.
EOF
            echo "✅ Created minimal user-global AGENTS.md"
        fi
    fi
    
    # Ensure Claude reads the canonical config via symlink: ~/.claude/CLAUDE.md -> ~/.config/agent/AGENTS.md
    ln -sf "$HOME/.config/agent/AGENTS.md" "$HOME/.claude/CLAUDE.md"
    
    echo "Downloading settings.json..."
    curl -fsSL "${REPO_URL}/settings.json" -o ~/.claude/settings.json
    
    echo "Downloading commands.md..."
    curl -fsSL "${REPO_URL}/commands.md" -o ~/.claude/commands.md 2>/dev/null || true
    
    echo "✅ Configuration downloaded from repo"
}

create_utilities() {
    echo "🛠️  Creating utility scripts..."
    
    cat > ~/.local/bin/sync << EOF
#!/usr/bin/env bash
set -e

echo "🔄 Syncing global agent configuration..."

REPO_URL="${REPO_URL}"
USER_AGENT_FILENAME="${USER_AGENT_FILENAME}"

mkdir -p "\$HOME/.claude" "\$HOME/.config/agent"

echo "Linking ~/.claude/CLAUDE.md to ~/.config/agent/AGENTS.md..."
ln -sf "\$HOME/.config/agent/AGENTS.md" "\$HOME/.claude/CLAUDE.md"

echo "Downloading settings.json..."
curl -fsSL "\${REPO_URL}/settings.json" -o "\$HOME/.claude/settings.json" || echo "Warning: Could not download settings.json"

echo "Downloading commands.md..."
curl -fsSL "\${REPO_URL}/commands.md" -o "\$HOME/.claude/commands.md" || echo "Warning: Could not download commands.md"

echo "Downloading agent template..."
curl -fsSL "\${REPO_URL}/AGENTS-template.md" -o "\$HOME/.claude/AGENTS-template.md" 2>/dev/null || true

if curl -fsSL "\${REPO_URL}/\${USER_AGENT_FILENAME}" -o /tmp/AGENT.USER.GLOBAL 2>/dev/null; then
  if [ -f "\$HOME/.config/agent/AGENTS.md" ]; then
    cp "\$HOME/.config/agent/AGENTS.md" "\$HOME/.config/agent/AGENTS.md.bak-\$(date +%Y%m%d-%H%M%S)"
  fi
  mv /tmp/AGENT.USER.GLOBAL "\$HOME/.config/agent/AGENTS.md"
  echo "✅ Updated user-global AGENTS.md from repo"
else
  echo "Warning: Could not download AGENTS.md from repo"
fi

# Maintain CLAUDE.md symlink after updates
ln -sf "\$HOME/.config/agent/AGENTS.md" "\$HOME/.claude/CLAUDE.md"

echo "✅ Configuration sync complete!"
EOF

    cat > ~/.local/bin/agent-init << 'EOA'
#!/usr/bin/env bash

set -e

usage() {
  cat <<USAGE
Usage: agent-init

Creates an AGENTS.md file in the current directory using the template.
USAGE
}

if [ -n "$1" ]; then
  usage
  exit 1
fi

TARGET="$(pwd)/AGENTS.md"
TEMPLATE="$HOME/.claude/AGENTS-template.md"

ensure_file() {
  if [ ! -f "$TARGET" ]; then
    if [ -f "$TEMPLATE" ]; then
      cp "$TEMPLATE" "$TARGET"
      echo "🧭 Created AGENTS.md from template: $TARGET"
    else
      cat > "$TARGET" << 'EOF'
# AGENTS.md

Personal preferences for agentic tools. Repository `AGENTS.md` always takes precedence.

## Preferences

- Editor: VS Code
- Tab width / indentation: 2 spaces  
- Line length: 100
- Preferred package manager: npm
- Testing preference: vitest

## Behaviors

- Auto-run checks before commit: true
- Prefer CLI over GUI tooling: true
- Ask before running migrations: true

## Security & Privacy

- Never upload proprietary code to remote analysis tools
- Redact secrets in logs and debugging output
EOF
      echo "🧭 Created AGENTS.md with default content: $TARGET"
    fi
  else
    echo "✅ AGENTS.md already exists: $TARGET"
  fi
}

ensure_file
EOA

    chmod +x ~/.local/bin/sync ~/.local/bin/agent-init
}

add_shell_integration() {
    echo "🐚 Adding shell integration..."
    
    local integration_block='
# >>> Agent Integration >>>
# Agent utilities
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
esac
# <<< Agent Integration <<<'

    local targets=()
    targets+=("${SHELL_CONFIGS[@]}")
    if [ "$(uname -s)" = "Darwin" ]; then
        targets+=("$HOME/.zprofile")
    fi

    local unique_targets=()
    for f in "${targets[@]}"; do
        local seen=false
        for u in "${unique_targets[@]}"; do
            if [ "$u" = "$f" ]; then seen=true; break; fi
        done
        $seen || unique_targets+=("$f")
    done

    for shell_config in "${unique_targets[@]}"; do
        [ -z "$shell_config" ] && continue
        echo "  📝 Updating $(basename "$shell_config")..."
        
        touch "$shell_config"
        
        if grep -q "^# >>> \(Claude\|Agent\) Integration >>>" "$shell_config" 2>/dev/null; then
            sed -i '.bak' '/^# >>> \(Claude\|Agent\) Integration >>>/,/^# <<< \(Claude\|Agent\) Integration <<</d' "$shell_config" || true
            rm -f "${shell_config}.bak"
        fi
        
        printf "%s\n" "$integration_block" >> "$shell_config"
        echo "     ✅ Integration ensured"
    done
    
    echo "✅ Shell integration complete"
}

main() {
    detect_os
    detect_shell
    check_repo
    
    echo ""
    echo "📦 Installing dependencies..."
    install_package_manager
    install_git_lfs
    install_github_cli
    install_python_packages
    install_monitoring_tools
    
    echo ""
    download_configuration
    create_utilities
    add_shell_integration
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Cross-Platform Installation Complete!"
    echo ""
    echo "🌍 Platform: $OS ($ARCH)"
    echo "🐚 Shell configs: ${SHELL_CONFIGS[*]}"
    echo "🌩️  Configuration synced from repo"
    echo ""
    echo "🛠️  Commands:"
    echo "   sync           - Claude slash command (/sync) and CLI command to sync config from repo"
    echo "   agent-init     - Shell script to create AGENTS.md from template"
    echo ""
    echo "🔄 Restart terminal or source your shell config to activate changes"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main "$@"