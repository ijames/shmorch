# Workflow: Intake

Clarify the goal before routing to the right workflow.

## When to use
- New conversation where the user's goal isn't clearly stated
- User asks a question or makes a comment before naming a task
- Multiple valid directions and it's unclear which to take
- Any time you're uncertain which workflow to enter

## Inputs
- `docs/state/context.md`
- `docs/state/session.md`

## Roles
- None — runs inline

---

## Steps

1. If not already read: read `docs/state/context.md` + `docs/state/session.md`
2. Summarize where things stand in 1-2 sentences — orient yourself out loud
3. Ask ONE open-ended question: **"What do you want to work on?"** — then wait
4. Clarify until you can answer all three:
   - What is the desired outcome?
   - What are the constraints or non-goals?
   - Is there existing code/docs to analyze first, or is this greenfield?
5. Route to the correct workflow:

| User wants to... | Route to |
|-----------------|----------|
| Understand existing code or a codebase area | **Analyze** |
| Define what to build (outcome unclear) | **Spec** |
| Design how to build it (outcome clear, approach unclear) | **Design** |
| Write code (outcome and approach both clear) | **Build** — interview first |
| Remove dead code or stale docs | **Vacuum** |
| Sync docs/Zulip/tests with code | **Curate** |

6. Write to `docs/state/plan.md` (STATUS: PENDING) with enough detail to hand off to the target workflow
7. Confirm the route with the user, then enter the target workflow — stamp `PHASE: intake → <next>`

---

## Rules

- One question at a time — never a list of questions
- Do not route to Build without understanding the outcome and constraints
- Do not route to Spec without a concrete problem statement
- If in doubt between Design and Build: default to Design — it's faster to skip than to undo
