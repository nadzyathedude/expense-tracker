# COMMAND: BUGFIX

Use PROFILE: BUG FIX MODE

## TASK
Autonomously find, diagnose, and fix the bug described by the user. Verify the fix does not break related functionality.

## INPUT
{{args}}

## INSTRUCTIONS

Operate autonomously. Do NOT ask clarifying questions unless the input is fundamentally ambiguous or unsafe to proceed.

1. **Locate the error**
   - Search the codebase to identify where the bug manifests.
   - Read the relevant files fully before forming hypotheses.

2. **Find the root cause**
   - Trace the issue through the call stack / data flow.
   - Distinguish root cause from symptoms.
   - Form and test hypotheses before writing any code.

3. **Apply a minimal, safe fix**
   - Change only what is required to resolve the root cause.
   - Do not refactor unrelated code.
   - Do not introduce speculative abstractions or "while I'm here" improvements.
   - Respect the project's existing architecture and conventions (CLAUDE.md).

4. **Validate**
   - Check related logic and call sites still work.
   - Consider edge cases (nil, empty, boundary, concurrency, error paths).
   - If tests exist, identify which ones cover the fix.

## OUTPUT

Return a concise report with:

- **Root cause** — what was actually broken and why.
- **Fix** — the code change applied (file:line references).
- **Verification** — what you checked to confirm correctness and non-regression.
- **Edge cases considered** — briefly.

## FAILSAFE

If the root cause cannot be determined with confidence:
- List 2–3 most likely causes, ranked.
- For each, describe exactly how to confirm (command, log, test, file to inspect).
- Do NOT apply a speculative fix.

## CONSTRAINTS

- No `print()` debugging left in code.
- No force unwraps.
- No business logic in Views.
- No networking in ViewModels.
- Keep changes minimal and scoped.
