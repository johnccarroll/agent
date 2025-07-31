# Multi-Node.js Development Environment

## Environment Setup
- **Node.js**: Multiple versions via nvm (auto-switching with Claude Code)
- **Package Manager**: npm (global packages per Node version)
- **Python**: pip3 with user-level packages (version independent)
- **Git**: Configured with LFS and GitHub CLI
- **Monitoring**: htop, nvtop available

## Development Workflow
- Use `nvm use <version>` to switch Node.js versions
- Claude Code auto-installs with each Node version
- All Node versions share this configuration
- Python packages installed once (user-level)

## Code Style & Standards
- **JavaScript/TypeScript**: ES6+, arrow functions, template literals
- **Formatting**: 2-space indentation, trailing commas, semicolons
- **Imports**: ES modules (import/export), not CommonJS
- **Functions**: Prefer arrow functions and const declarations
- **Async**: Use async/await over promises when possible

## Git Workflow
- **Branches**: feature/description or fix/description
- **Commits**: Conventional format (feat:, fix:, docs:, etc.)
- **PRs**: Create from feature branches, require review
- **Commands**: Use `gh` CLI for GitHub operations

## Thinking & Planning
- Use "think" for basic planning
- Use "think hard" for complex problems  
- Use "think harder" for architectural decisions
- Use "ultrathink" for critical system design

## Commands & Shortcuts
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run test` - Run tests
- `npm run lint` - Lint code
- `gh pr create` - Create pull request
- `claude-sync` - Sync Claude Code across Node versions
- `claude-status` - Check Claude installation status

## Best Practices
- **Context**: Always provide full context for complex requests
- **Iteration**: Expect 2-3 iterations for optimal results
- **Testing**: Write tests, especially for new features
- **Documentation**: Update README and inline docs
- **Security**: Review code for vulnerabilities
- **Performance**: Consider performance implications

## Memory Management
- Use `/compact` at natural breakpoints
- Use `/memory` to view loaded configuration
- Save session notes to docs/ folder when needed
- Keep this file concise to save tokens

## Do Not
- Edit files in node_modules/ directories
- Commit package-lock.json conflicts without resolution
- Use deprecated Node.js APIs
- Mix ES modules and CommonJS in same project
- Install packages globally unless specifically needed
- Commit sensitive data (API keys, passwords)