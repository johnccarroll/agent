# AGENT.md (Root-Level Blueprint)

Scope: Repository-wide guidance for agents. Place this at the project root.

This blueprint follows the AGENT.md specification to provide a single source of truth for agentic tools.

## Project Overview

- Name: <PROJECT_NAME>
- Summary: <ONE_SENTENCE_DESCRIPTION>
- Repository layout: <KEY_DIRS like `src/`, `server/`, `client/`, `packages/`>
- Primary languages/frameworks: <LIST>

## Build & Commands

- Install dependencies: `<cmd>`
- Typecheck and lint: `<cmd>`
- Fix linting/formatting: `<cmd>`
- Run tests: `<cmd>`
- Run single test: `<cmd>`
- Dev server(s): `<cmd>`
- Build: `<cmd>`
- Preview: `<cmd>`

### Development Environment

- App URLs/ports: <DOC_PORTS>
- Databases/queues: <DOC_SERVICES>
- Supporting services: <DOC_RUNBOOK or docker-compose>

## Code Style and Conventions

- Languages & versions: <e.g., TS strict, Python 3.11>
- Formatting: <tabs/spaces, quotes, semicolons, trailing commas>
- Imports: <alias rules, type-only imports>
- Naming: <URL/API/ID casing rules>
- Documentation: <docstrings/JSDoc policy>
- Line length: <e.g., 100 chars>

## Architecture and Design Patterns

- High-level architecture: <brief description>
- Key modules/packages: <short list>
- Patterns and constraints: <DDD/layers/events/etc.>

## Testing Guidelines

- Unit/integration/E2E frameworks: <LIST>
- File conventions: <e.g., `*.test.ts`>
- Practices: <isolation, mocking, snapshot policy>

## Security Considerations

- Secrets management: <env vars, Vault, 1Password>
- Input validation and encoding: <client/server policy>
- Authn/authz: <summary>
- Dependencies: <update/audit policy>

## Git Workflow

- Branching strategy: <trunk/feature branches>
- Commit conventions: <Conventional Commits?>
- CI requirements: <lint, typecheck, tests>
- Force-push policy: <rules>

## Configuration

When adding new configuration options, update all relevant places:
1. Environment variables in `.env.example`
2. Configuration schemas in code
3. Documentation in `README.md` and this `AGENT.md`

## File References

Include related docs with @-mentions: @README.md, @docs/architecture.md, @CONTRIBUTING.md

## Multiple AGENT.md Files

Subsystem `AGENT.md` files may exist in subdirectories for specific guidance. Tools should merge configurations with more specific files taking precedence over general ones.

