# AGENT.md

Repository guidance for Claude Code configuration management.

## Project Overview

- Name: claude-config
- Summary: Cross-platform agent development environment setup and configuration management system
- Repository layout: Root-level configuration files and installation script
- Primary languages/frameworks: Bash scripting, Markdown documentation

## Build & Commands

- Install environment: `./install.sh`
- Sync configuration: `claude sync` or `/sync` (Claude only)
- Create AGENT.md: `agent-init` or `agent-init --subsystem`
- Test installation: Check that `agent-init` is on PATH, `claude sync` works in Claude

### Development Environment

- No servers or databases required
- Requires internet access for gist downloads
- Compatible with macOS, Linux, and Windows (WSL/Git Bash)

## Code Style and Conventions

- Languages & versions: Bash 3.2+ (macOS compatibility), Markdown
- Formatting: 2-space indentation, no trailing whitespace
- Shell scripting: Use `set -e`, quote variables, cross-platform compatibility
- Naming: snake_case for functions, UPPER_CASE for environment variables
- Documentation: Inline comments for complex logic only
- Line length: 100 characters max

## Architecture and Design Patterns

- High-level architecture: Configuration management via GitHub gist with local caching
- Key components: install.sh (environment setup), sync (config updates), agent-init (AGENT.md creation)
- Patterns: Downstream-only sync, hierarchical configuration (subsystem → root → global)

## Testing Guidelines

- Manual testing: Run install.sh on clean systems
- Test matrix: macOS (Intel/Apple Silicon), Linux (Ubuntu/CentOS), Windows (WSL)
- Verification: Commands available on PATH, configuration files downloaded correctly

## Security Considerations

- Gist access: Public gist, no authentication required
- Downloads: Use HTTPS, verify curl exit codes
- File permissions: Executable scripts only in ~/.local/bin
- No secrets: All configuration is public

## Git Workflow

- Branching strategy: Direct commits to main for configuration updates
- Commit conventions: Conventional commits (feat:, fix:, refactor:)
- No CI requirements: Simple shell scripts
- Force-push policy: Avoid force-push to preserve history

## Configuration

When modifying configuration:
1. Update gist files (CLAUDE.md, settings.json, commands.md, blueprints)
2. Test install.sh on different platforms
3. Update this AGENT.md if adding new commands or changing architecture
4. Users sync changes via `sync` command

## File Structure

- `install.sh` - Cross-platform installer and environment setup
- `CLAUDE.md` - Claude Code specific configuration and agent hierarchy guidance
- `commands.md` - Claude slash command definitions
- `settings.json` - Claude Code settings
- `AGENT.md` (this file) - Repository guidance for all agents
- `*-BLUEPRINT.md` - Templates for creating AGENT.md files

## Usage

1. Run `./install.sh` to set up environment
2. Use `claude sync` or `/sync` (Claude only) to pull latest configuration from gist
3. Use `agent-init` (shell script) to create AGENT.md files in projects
4. Configuration hierarchy: subsystem → project root → user-global

