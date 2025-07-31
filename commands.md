# Custom Claude Code Slash Commands

## review

Perform a comprehensive code review focusing on:

1. **Code Quality**
   - Follow established code style and conventions
   - Check for proper error handling
   - Verify test coverage for new functionality
   - Look for potential security vulnerabilities

2. **Architecture & Design**
   - Ensure code follows SOLID principles
   - Check for proper separation of concerns
   - Verify consistent patterns with existing codebase

3. **Performance & Best Practices**
   - Look for performance issues or anti-patterns
   - Check for memory leaks or inefficient algorithms
   - Verify proper async/await usage

4. **Documentation & Maintainability**
   - Ensure adequate inline documentation
   - Check that complex logic is well-explained
   - Verify README updates if needed

Be concise and focus on actionable feedback. Only report significant issues, not minor style preferences.

## plan

Think hard about the request and create a detailed implementation plan.

Follow this structure:

### Analysis
- Understand the requirements thoroughly
- Identify potential challenges or edge cases
- Consider impact on existing codebase

### Implementation Strategy
- Break down into logical, testable steps
- Identify files that need to be created/modified
- Plan the order of implementation

### Testing Approach
- Define what needs to be tested
- Plan unit tests, integration tests as needed
- Consider edge cases and error scenarios

### Checklist
Create a markdown checklist with [ ] for each major task:
- [ ] Task 1: Description
- [ ] Task 2: Description
- [ ] Task 3: Description

Save this plan to `docs/plan-$(date +%Y%m%d).md` for reference.

## commit

Analyze the current git changes and create a meaningful commit:

1. **Review Changes**
   - Use `git diff --staged` to see staged changes
   - If nothing staged, review `git diff` for unstaged changes

2. **Create Commit Message**
   - Use conventional commit format: `type(scope): description`
   - Types: feat, fix, docs, style, refactor, test, chore
   - Keep description under 72 characters
   - Add body if changes are complex

3. **Verify & Commit**
   - Ensure tests pass before committing
   - Run linting if available
   - Stage files if needed, then commit

Example formats:
- `feat(auth): add user login functionality`
- `fix(api): handle null response in user endpoint`
- `docs(readme): update installation instructions`

## sync

Ensure Claude Code is properly installed across all Node.js versions:

1. **Check Current Status**
   - Run `claude-status` to see current installation state
   - Identify any missing installations

2. **Sync Across Versions**
   - Run `claude-sync` to install in all Node versions
   - Verify each installation completed successfully

3. **Test Functionality**
   - Switch to a different Node version with `nvm use X`
   - Verify `claude --version` works
   - Test basic Claude Code functionality

4. **Update Configuration**
   - Ensure `~/.claude/CLAUDE.md` is up to date
   - Check that shared settings are properly configured

This ensures consistent Claude Code availability across your development environment.

## debug

Systematically debug the issue described in $ARGUMENTS:

1. **Understand the Problem**
   - Reproduce the issue if possible
   - Gather error messages, logs, or symptoms
   - Identify when the problem started occurring

2. **Investigate**
   - Check recent changes that might be related
   - Look for similar issues in codebase
   - Review relevant configuration files

3. **Diagnostic Steps**
   - Add logging/debugging statements as needed
   - Test individual components in isolation
   - Verify environment setup and dependencies

4. **Solution & Prevention**
   - Implement a fix for the root cause
   - Add tests to prevent regression
   - Update documentation if needed
   - Consider adding to CLAUDE.md if it's a common issue

Be methodical and document your findings for future reference.