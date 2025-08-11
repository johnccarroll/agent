#!/usr/bin/env bash
# Agent Development Environment Setup - Cross-Platform Installer v4.0.0
# Works on macOS, Linux, and Windows (WSL/Git Bash)
set -e

GIST_ID="18b75f992de5ecfc7fce2eee32b992bf"
GIST_URL="https://gist.githubusercontent.com/johnccarroll/${GIST_ID}/raw"
GIST_USER_AGENT_FILENAME="AGENT-GLOBAL-BLUEPRINT.md"

echo "🌍 Agent Development Environment Setup v4.0.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Gist: https://gist.github.com/${GIST_ID}"
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
    echo "☁️  Downloading configuration from gist..."
    
    mkdir -p ~/.claude ~/.local/bin ~/.config
    
    echo "Downloading CLAUDE.md..."
    curl -fsSL "${GIST_URL}/CLAUDE.md" -o ~/.claude/CLAUDE.md
    
    echo "Downloading AGENT-ROOT-BLUEPRINT.md (optional)..."
    if curl -fsSL "${GIST_URL}/AGENT-ROOT-BLUEPRINT.md" -o ~/.claude/AGENT-ROOT-BLUEPRINT.md 2>/dev/null; then
        echo "✅ AGENT-ROOT-BLUEPRINT.md downloaded from gist"
    else
        if [ -f "$(pwd)/AGENT-ROOT-BLUEPRINT.md" ]; then
            cp "$(pwd)/AGENT-ROOT-BLUEPRINT.md" ~/.claude/AGENT-ROOT-BLUEPRINT.md
            echo "✅ AGENT-ROOT-BLUEPRINT.md copied from local repository"
        else
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
            cat > "$HOME/.config/AGENT.MD" << 'EOF'
# AGENT.md (User-Global)

Personal preferences for agentic tools. Repository `AGENT.md` always takes precedence.
EOF
            echo "✅ Created minimal user-global AGENT.MD"
        fi
    fi

    if [ ! -e "$HOME/.config/AGENT.md" ]; then
        ln -sf "$HOME/.config/AGENT.MD" "$HOME/.config/AGENT.md"
    fi
    
    echo "Downloading settings.json..."
    curl -fsSL "${GIST_URL}/settings.json" -o ~/.claude/settings.json
    
    echo "Downloading commands.md..."
    curl -fsSL "${GIST_URL}/commands.md" -o ~/.claude/commands.md 2>/dev/null || true
    
    echo "✅ Configuration downloaded from gist"
}

create_utilities() {
    echo "🛠️  Creating utility scripts..."
    
    cat > ~/.local/bin/sync << EOF
#!/usr/bin/env bash
set -e

echo "🔄 Syncing global agent configuration from gist..."

GIST_URL="${GIST_URL}"
GIST_USER_AGENT_FILENAME="${GIST_USER_AGENT_FILENAME}"

mkdir -p "\$HOME/.claude" "\$HOME/.config"

echo "Downloading CLAUDE.md..."
curl -fsSL "\${GIST_URL}/CLAUDE.md" -o "\$HOME/.claude/CLAUDE.md" || echo "Warning: Could not download CLAUDE.md"

echo "Downloading settings.json..."
curl -fsSL "\${GIST_URL}/settings.json" -o "\$HOME/.claude/settings.json" || echo "Warning: Could not download settings.json"

echo "Downloading commands.md..."
curl -fsSL "\${GIST_URL}/commands.md" -o "\$HOME/.claude/commands.md" || echo "Warning: Could not download commands.md"

echo "Downloading agent blueprints..."
curl -fsSL "\${GIST_URL}/AGENT-ROOT-BLUEPRINT.md" -o "\$HOME/.claude/AGENT-ROOT-BLUEPRINT.md" 2>/dev/null || true
curl -fsSL "\${GIST_URL}/AGENT-SUBSYSTEM-BLUEPRINT.md" -o "\$HOME/.claude/AGENT-SUBSYSTEM-BLUEPRINT.md" 2>/dev/null || true

if curl -fsSL "\${GIST_URL}/\${GIST_USER_AGENT_FILENAME}" -o /tmp/AGENT.USER.GLOBAL 2>/dev/null; then
  if [ -f "\$HOME/.config/AGENT.MD" ]; then
    cp "\$HOME/.config/AGENT.MD" "\$HOME/.config/AGENT.MD.bak-\$(date +%Y%m%d-%H%M%S)"
  fi
  mv /tmp/AGENT.USER.GLOBAL "\$HOME/.config/AGENT.MD"
  echo "✅ Updated user-global AGENT.MD from gist"
fi

if [ ! -e "\$HOME/.config/AGENT.md" ]; then
  ln -sf "\$HOME/.config/AGENT.MD" "\$HOME/.config/AGENT.md"
fi

echo "✅ Configuration sync complete!"
EOF

    cat > ~/.local/bin/agent-init << 'EOA'
#!/usr/bin/env bash

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
    create_utilities
    add_shell_integration
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Cross-Platform Installation Complete!"
    echo ""
    echo "🌍 Platform: $OS ($ARCH)"
    echo "🐚 Shell configs: ${SHELL_CONFIGS[*]}"
    echo "🌩️  Configuration synced from gist"
    echo ""
    echo "🛠️  Commands:"
    echo "   sync           - Claude slash command (/sync) and CLI command to sync config from gist"
    echo "   agent-init     - Shell script to create/verify AGENT.md (works with any agent)"
    echo ""
    echo "🔄 Restart terminal or source your shell config to activate changes"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main "$@"