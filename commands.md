# Custom Claude Code Slash Commands

## agent-init

Create a local AGENTS.md file in the current directory using the standard template for project-specific agent guidance.

This command copies the AGENT-template.md file to create a project-specific AGENTS.md with placeholder sections for:

### Project Details
- Project name, summary, and key technologies
- Repository layout and directory structure
- Development environment requirements

### Development Workflow  
- Build commands, testing, and deployment
- Code style guidelines and conventions
- Git workflow and review processes

### Architecture & Design
- Key components and design patterns
- External dependencies and integrations
- Security considerations

Think of AGENTS.md as a "README for agents" - providing clear, structured context that helps AI agents understand your project beyond what a human-focused README provides.

**Usage**: `/agent-init`

**Result**: Creates `AGENTS.md` in current directory with template placeholders to fill out based on your specific project needs.