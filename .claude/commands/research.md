# COMMAND: RESEARCH

Use PROFILE: CODE RESEARCH MODE

## TASK
Explore the codebase and answer the user's question with a structured, accurate, system-level explanation grounded strictly in the actual code.

## INPUT
{{args}}

## INSTRUCTIONS

Operate autonomously. Do NOT ask clarifying questions unless the question is fundamentally ambiguous.

1. **Understand the question**
   - Identify what the user actually needs to know (behavior, architecture, data flow, dependency, ownership).

2. **Locate relevant code**
   - Search across multiple files — do not stop at the first match.
   - Follow references, protocols, conformances, and call sites.
   - Read files fully when their contents are load-bearing for the answer.

3. **Analyze the system**
   - Where does the logic live?
   - How does data flow between layers (View → ViewModel → Repository → DataSource)?
   - What are the dependencies and invariants?
   - What is inferred from code vs. what is assumed?

4. **Synthesize**
   - Build a coherent, system-level explanation.
   - Ground every claim in a specific file/symbol.
   - Do not speculate. If code doesn't show it, say so.

## OUTPUT

Return a structured report:

- **Short answer** — 1–3 sentences, direct.
- **How it works** — the mechanism, in the correct order.
- **Relevant files / modules** — with `path:line` references.
- **Key nuances** — edge cases, gotchas, non-obvious behavior.

## FAILSAFE

If the answer cannot be fully determined from the code:
- State clearly what is missing or unverifiable.
- Point to the files, symbols, or external sources most likely to contain it.
- Do NOT fill gaps with guesses.

## CONSTRAINTS

- Do not modify code — research only.
- Base conclusions on code, not assumptions.
- Prefer precision over breadth; cite specific lines.
