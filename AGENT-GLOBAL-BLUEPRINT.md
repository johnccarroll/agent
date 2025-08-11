# AGENT.md (User-Global Blueprint)

Scope: Personal preferences that apply across all repositories. Installed as `~/.config/AGENT.MD`.

Keep this vendor-neutral and focused on defaults that agents can honor without overriding repository rules.

## Preferences

- Editor: <e.g., VS Code>
- Tab width / indentation: <e.g., 2 spaces>
- Line length: <e.g., 100>
- Preferred package manager: <npm/pnpm/yarn>
- Testing preference: <e.g., vitest>

## Behaviors

- Auto-run checks before commit: <true/false>
- Prefer CLI over GUI tooling: <true/false>
- Ask before running migrations: <true/false>

## Security & Privacy

- Never upload proprietary code to remote analysis tools
- Redact secrets in logs and debugging output

## Accessibility

- Color contrast: <high/normal>
- Motion/animation: <reduced/normal>

## Multiple AGENT.md Files and Precedence

- Subsystem `AGENT.md` files MAY exist within subdirectories for domain-specific guidance.
- Repository root `AGENT.md` provides project-wide guidance.
- Precedence: Subsystem `AGENT.md` > Root `AGENT.md` > User-global `AGENT.MD`.

## Agent Behavior for Subsystem Files

When working within a subdirectory that represents a meaningful subsystem (e.g., `server/`, `client/`, `packages/auth/`):

1. Check whether an `AGENT.md` exists in that subdirectory.
2. If not present and the task scope is primarily local to that subsystem, PROMPT the user:
   - “Would you like me to create a scoped `AGENT.md` for this subsystem using the standard subsystem blueprint?”
3. If the user agrees, create `AGENT.md` in that directory using the subsystem blueprint and populate minimal scoped commands and conventions.
4. Keep the subsystem file concise and avoid duplicating root guidance—only override or refine where necessary.

## File References

May reference personal docs: @~/.config/README.md

---

Note: Repository `AGENT.md` and subsystem `AGENT.md` always take precedence over these user-global preferences.

