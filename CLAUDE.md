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
- `claude-sync` - Sync Claude Code across Node versions
- `claude-status` - Check Claude installation status
- `claude-update` - Update user config from gist

## Memory Management
- Use `/compact` at natural breakpoints
- Use `/memory` to view loaded configuration
- Save session notes to docs/ folder when needed
- Keep this file concise to save tokens

## Configuration Management
- Repository guidance: Place project guidance in `AGENT.md` at the repository root
- User-global settings: Use `~/.config/AGENT.MD` for personal preferences
- Claude installs per Node version; user config syncs via install script
- `AGENT.md` is the source of truth agents should follow

## Do Not
- Create project-local `.claude/` directories (use `~/.claude/` instead)
- Override machine-wide Claude Code configuration per project