# AGENT.md (Subsystem Blueprint)

Scope: Subdirectory guidance for a specific subsystem (e.g., `server/`, `client/`, `packages/auth/`). Place this `AGENT.md` inside the subdirectory.

This file refines or overrides the root-level guidance for this subsystem. Keep it focused and short.

## Subsystem Overview

- Subsystem name: <SUBSYSTEM_NAME>
- Purpose: <WHAT_THIS_SUBSYSTEM_DOES>
- Entry points: <KEY_FILES>

## Commands (Scoped)

- Dev: `<cmd>`
- Tests (unit/integration/E2E): `<cmd>`
- Build/package: `<cmd>`

## Code Style and Conventions (Overrides)

- Language/framework specifics: <LIST>
- Module boundaries and layering rules: <RULES>
- Error handling: <STRATEGY>

## Architecture and Patterns (Scoped)

- Key components: <LIST>
- Data flow: <NOTES>
- Integration points: <APIs, events, queues>

## Testing Guidelines (Scoped)

- Test focus areas: <NOTES>
- Mocks and fakes: <GUIDELINES>

## Security Considerations (Scoped)

- Data sensitivity: <NOTES>
- Authn/authz scopes: <DETAILS>

## File References

@README.md @docs/ @ADR.md (adjust paths relative to this subdirectory)

---

Note: Tools should merge this file with the root `AGENT.md`; subsystem guidance takes precedence for files within this directory.

