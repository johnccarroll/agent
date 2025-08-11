# Claude Code Configuration

## Scope
- This file contains Claude-specific guidance only.
- Project-wide development and environment setup lives in `AGENT.md` (root) and user-global settings in `~/.config/AGENT.MD`.

## Prompting Conventions
- Use "think" for basic planning
- Use "think hard" for complex problems
- Use "think harder" for architectural decisions
- Use "ultrathink" for critical system design

## Claude Commands
- Claude Code installs automatically via nvm config

## Memory Management
- Use `/compact` at natural breakpoints
- Use `/memory` to view loaded configuration
- Save session notes to docs/ folder when needed
- Keep this file concise to save tokens

## Agent Configuration Management

### File Hierarchy
- **User-global**: `~/.config/AGENT.MD` - Personal preferences for all agentic tools
- **Project root**: `AGENT.md` - Repository-wide guidance (overrides user-global)
- **Subsystem**: `./AGENT.md` - Directory-specific guidance (overrides above)

### Detection Logic
1. **Project root detection**: Look for `.git/` directory or common project markers (`package.json`, `pyproject.toml`, etc.)
2. **Subsystem detection**: Check if current directory ≠ project root and has distinct purpose
3. **Priority**: Subsystem → Project Root → User-global (most specific wins)

### When to Create AGENT.md
- **Project root**: When no `AGENT.md` exists at repository root
- **Subsystem**: When working in specialized directories (src/, api/, frontend/, etc.)
- **Prompt user**: If agent detects new project structure or significant directory changes

### Usage Guidelines
- Always read existing AGENT.md files in order: subsystem → root → global
- Apply most specific configuration for current context
- Use `agent-init` to create missing files with appropriate blueprints

## Do Not
- Create project-local `.claude/` directories (use `~/.claude/` instead)
- Override machine-wide Claude Code configuration per project