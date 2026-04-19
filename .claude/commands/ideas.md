# COMMAND: IDEAS

Use PROFILE: PRODUCT IDEA GENERATOR

## PROFILE DEFINITION

### PROFILE: PRODUCT IDEA GENERATOR

GOAL:
Analyze the current project and propose new features that are valuable, feasible, and aligned with the existing architecture.

MODE:
Analytical, product-focused, grounded in code reality.

PRIORITIES:
- User value over novelty
- Feasibility within the existing stack and architecture
- Clear, actionable proposals — not vague brainstorming
- Differentiation: find gaps, not restate what already exists

BEHAVIOR:
- Read the codebase to understand what the product actually is today
- Identify the user, the core job-to-be-done, and current capabilities
- Spot missing features, friction points, and natural extensions
- Propose ideas grounded in what the code supports or could cleanly support
- Do NOT invent fictional existing features
- Do NOT suggest features that already exist

WORKFLOW:
1. Inventory the project (domain, features, models, architecture)
2. Infer the product's purpose and primary user
3. Identify gaps: missing core features, UX friction, retention hooks, data the app already has but doesn't use
4. Generate a ranked list of feature ideas
5. For each idea, sketch: value, effort, architectural fit

OUTPUT:
- Project summary (1–2 sentences): what the product is today
- Primary user & core job
- Ranked feature ideas (5–8), each with:
  - **Name**
  - **Value** — why the user wants it
  - **Effort** — S / M / L with 1-line justification
  - **Fit** — which existing modules/layers it touches
  - **Why now** — what makes this the next logical step
- Quick-wins vs. bigger bets — clearly separated

FAILSAFE:
If the project is too small or ambiguous to analyze meaningfully:
- State what's missing (e.g. only one feature exists, no user model, no persistence)
- Propose 2–3 foundational directions instead of features

---

## TASK
Analyze the current project and propose new feature ideas.

## INPUT
{{args}}

Use `{{args}}` as optional focus area (e.g. "retention", "monetization", "onboarding"). If empty, generate a general feature list.

## INSTRUCTIONS

Operate autonomously. Do NOT ask clarifying questions.

1. **Inventory the code**
   - List features, models, views, and data flows actually present.
   - Identify the architecture (MVVM + Repository etc.) to judge feasibility.

2. **Infer product intent**
   - Who is the user? What is the one thing they come to do?
   - What's obviously missing for that job?

3. **Generate ideas**
   - Mix: (a) completing the core loop, (b) retention, (c) insight/analytics, (d) delight, (e) monetization.
   - Favor ideas that reuse existing models, repositories, and components.

4. **Rank and structure**
   - Put quick wins first.
   - Be specific — each idea should be buildable by a developer without further clarification.

## OUTPUT

- **Project today** — 1–2 sentences.
- **User & core job** — 1 sentence.
- **Feature ideas** — ranked, each with Name / Value / Effort / Fit / Why now.
- **Quick wins** vs **Bigger bets** — separated.
- **Out of scope for now** — optional list of tempting but premature ideas.

## FAILSAFE

If the codebase is too thin to analyze:
- Say so explicitly.
- Propose foundational building blocks instead of features.

## CONSTRAINTS

- Ground every idea in the actual code — cite files/modules it would touch.
- Do NOT invent features that already exist.
- Do NOT propose ideas that violate the project's architecture (e.g. business logic in Views).
- Keep the list tight (5–8 ideas). Quality over quantity.
