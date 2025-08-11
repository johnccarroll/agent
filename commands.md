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

## agent

High-level agent guidance and quick actions:

1. Read the repository `AGENT.md` (root) and apply its conventions
2. Respect user-global preferences in `~/.config/AGENT.MD`
3. If working within a subdirectory and no local `AGENT.md` exists, ask whether to create one using the subsystem blueprint
4. Avoid modifying repository `AGENT.md` without explicit user request

## sync

Pull the latest configuration from the gist and update local installations:

1. **Update global config**
   - Runs `claude-sync` to fetch latest `CLAUDE.md`, `settings.json`, and `commands.md` from the gist
   - Updates user-global `~/.config/AGENT.MD` if provided by the gist

2. **Sync across Node versions**
   - Ensures `@anthropic-ai/claude-code` is installed for each local Node version via nvm

3. **Non-invasive**
   - Does not modify repository `AGENT.md` files; only updates user-global config and Claude installs

Use this command when you want to refresh configs and ensure Claude is ready across Node versions.

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
    - Consider adding to AGENT.md if it's a common issue

Be methodical and document your findings for future reference.