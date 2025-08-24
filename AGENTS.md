# AGENTS.md (User-Global Instructions)

Personal preferences and standards for all agentic tools. This file gets synced to `~/.config/agent/AGENTS.md` and applies across all repositories unless overridden by project-specific AGENTS.md files.

## 2025 Coding Standards & Best Practices

### Clean Code Principles (Foundation)
- **Meaningful naming**: Use descriptive variable and function names that reveal intent
- **Single Responsibility**: Each function/class should have one clear, focused purpose
- **DRY principle**: Don't Repeat Yourself - extract common patterns into reusable functions
- **KISS principle**: Keep It Simple, Stupid - prefer clear, simple solutions over complex ones
- **Small functions**: Break complex logic into smaller, testable, readable functions
- **Consistent formatting**: Use automated formatters (Prettier, Black, etc.) for consistency

### Code Style Preferences

#### General
- **Indentation**: 2 spaces (no tabs)
- **Line length**: 100 characters maximum (industry standard for modern screens)
- **Trailing whitespace**: Remove always
- **File endings**: Always end files with single newline
- **Comments**: Focus on WHY, not WHAT - code should be self-documenting

#### JavaScript/TypeScript
- **Quotes**: Double quotes for strings, single quotes for JSX props
- **Semicolons**: Always use semicolons (ASI can be unpredictable)
- **Imports**: Organize imports alphabetically, separate by blank lines (external, internal, relative)
- **Functions**: Prefer arrow functions for simple expressions, named functions for complex logic
- **Variables**: Use `const` by default, `let` when reassignment needed, never `var`
- **Type safety**: Use TypeScript strict mode, avoid `any` type
- **Async/await**: Prefer over promises for better readability
- **Destructuring**: Use destructuring for cleaner object/array access

#### Python
- **Style**: Follow PEP 8 strictly, use tools like `ruff` or `black` for formatting
- **Imports**: One import per line, grouped by standard library, third-party, local
- **Type hints**: Use type hints for function parameters and return values (required for new code)
- **Docstrings**: Use Google-style docstrings for functions and classes
- **f-strings**: Prefer f-strings over format() or % formatting
- **Context managers**: Use `with` statements for resource management
- **List comprehensions**: Use when they improve readability, not complexity

#### Shell/Bash
- **Safety**: Always use `set -e` for error handling, `set -u` for undefined variables
- **Variables**: Quote all variable expansions (`"$var"`)
- **Functions**: Use snake_case for function names
- **Constants**: Use UPPER_CASE for environment variables and constants
- **Shellcheck**: Use shellcheck for linting and best practice validation

## Development Preferences

### Essential Tools (2025 Stack)
- **Package Manager**: npm preferred over yarn/pnpm for consistency
- **Testing**: vitest for JS/TS (faster than Jest), pytest for Python
- **Linting**: ESLint + Prettier for JS/TS, ruff for Python (replaces flake8/black)
- **Git**: Conventional Commits format (`feat:`, `fix:`, `refactor:`, etc.)
- **GitHub CLI**: Use `gh` command for GitHub operations (installed by default)
- **Code formatting**: Automated formatters integrated into CI/CD pipeline
- **Type checking**: TypeScript strict mode, mypy for Python

### Version Control & Collaboration
- **GitHub CLI**: Use `gh` for creating PRs, managing issues, viewing repo info
  - `gh pr create` instead of web interface
  - `gh issue create` for bug reports
  - `gh repo view` for quick repo information
- **Branching**: Use descriptive branch names (feature/fix/docs/refactor prefix)
- **Commits**: Atomic commits with clear, descriptive messages
- **Code reviews**: Required for all changes, focus on logic and standards compliance

### Modern Development Practices (2025)
- **Security-first**: Follow OWASP Top 10, security scanning in CI/CD
- **CI/CD integration**: Automated testing, linting, and deployment
- **Documentation-as-code**: Keep docs in repository, version with code
- **Performance monitoring**: Include performance budgets and monitoring
- **Accessibility**: WCAG compliance for web applications
- **Error tracking**: Implement comprehensive error tracking and alerting

### Testing Strategy
- **Test pyramid**: Unit tests (70%), Integration tests (20%), E2E tests (10%)
- **TDD approach**: Write tests first for complex business logic
- **Coverage targets**: Minimum 80% for critical paths, 60% overall
- **Performance tests**: Load testing for APIs, lighthouse scores for frontend
- **Security tests**: Vulnerability scanning, dependency audits

### Error Handling & Observability
- **Logging**: Structured logging with correlation IDs for request tracing
- **Error handling**: Fail fast, provide actionable error messages with context
- **Monitoring**: Application metrics, health checks, alerting thresholds
- **Debugging**: Include debug information without exposing sensitive data
- **Graceful degradation**: Handle external service failures elegantly

## AI Agent Guidelines

### Communication & Workflow
- **Conciseness**: Be direct and to the point, avoid unnecessary explanations
- **Context awareness**: Read existing patterns before making changes
- **Progress tracking**: Use todo lists for multi-step tasks, update status regularly
- **Clarification**: Ask specific questions when requirements are ambiguous
- **Documentation**: Explain complex changes and architectural decisions

### Code Generation (2025 Standards)
- **Pattern matching**: Follow established patterns in the codebase consistently
- **Security by default**: Apply security best practices automatically
- **Performance consideration**: Consider performance implications of generated code
- **Test-driven**: Generate comprehensive tests alongside implementation
- **Dependency management**: Check existing dependencies, avoid duplicates
- **Type safety**: Generate type-safe code by default (TypeScript, Python type hints)

### File Operations & Safety
- **Read first**: Always read files before editing to understand context
- **Atomic changes**: Make focused, minimal changes that can be easily reviewed
- **Backup awareness**: Suggest backups for destructive operations
- **Permission respect**: Maintain file permissions and ownership
- **Git integration**: Use `gh` CLI for GitHub operations when applicable

### Quality Assurance
- **Linting integration**: Apply linters and formatters automatically
- **Performance budgets**: Consider performance implications of changes
- **Accessibility compliance**: Ensure web interfaces meet WCAG standards
- **Security scanning**: Flag potential security issues during development

## Security & Privacy (2025 Enhanced)

### Data Protection
- **Zero trust**: Never log, display, or commit sensitive information
- **Input validation**: Validate and sanitize all external inputs rigorously
- **Least privilege**: Use minimal required permissions for operations
- **Encryption**: Encrypt sensitive data at rest and in transit

### Dependency Security
- **Vulnerability scanning**: Regularly audit dependencies for known vulnerabilities
- **Supply chain security**: Verify dependency integrity and authenticity
- **Update strategy**: Keep dependencies updated with security patches
- **License compliance**: Ensure all dependencies have compatible licenses

### Development Security
- **Secrets management**: Use environment variables or dedicated secret management
- **Code scanning**: Implement SAST/DAST tools in development pipeline
- **Access control**: Implement proper authentication and authorization
- **Audit logging**: Log security-relevant events for compliance and monitoring

## Project Structure & Architecture (2025)

### Modern Project Organization
- **Monorepo support**: Handle both single repos and monorepo structures
- **Configuration management**: Keep config files organized and documented
- **Documentation strategy**: Maintain README, CHANGELOG, and API docs
- **Script organization**: Place automation in dedicated directories (`scripts/`, `.github/`)
- **Environment setup**: Provide clear development environment setup instructions

### Infrastructure as Code
- **Container support**: Include Docker/containerization when appropriate
- **CI/CD templates**: Provide standard CI/CD pipeline configurations
- **Environment parity**: Ensure dev/staging/prod environment consistency
- **Deployment automation**: Prefer automated deployments over manual processes

---

**Note**: Repository-specific AGENTS.md files always take precedence over these global preferences.