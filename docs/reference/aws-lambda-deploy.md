# AWS Lambda Deployment Patterns

Hard-won lessons from darkbadge Day 13 (2026-05-24). Apply to any project deploying Python to Lambda via SAM.

↑ parent: [docs/reference/](.)

---

## Multi-cloud projects: choose Pulumi, not SAM

**Rule:** If a project spans more than one cloud provider from day one (e.g. Neon + Vercel + AWS), reach for Pulumi before SAM.

SAM is AWS-only. It manages Lambda, SQS, CloudFormation — nothing else. When you also have Vercel (frontend env vars) and Neon (DB), they share state only through manual copy-paste: deploy Lambda → copy URL → paste into Vercel dashboard → redeploy. There is no single source of truth for environment variables or infrastructure state.

Pulumi solves this: one typed program, providers for AWS + Vercel + Neon, single `pulumi up` that wires the whole system. The Lambda URL is an output that flows directly into the Vercel env var — no manual step.

**When SAM is fine:** AWS-only projects. Lambda + SQS + RDS all in one account.

**When to reconsider Shmorch guidance:** If `context.md` shows Neon + Vercel + AWS in the stack at project start, flag Pulumi as the IaC recommendation before the team picks SAM.

---

## IAM least-privilege for deploy users

**Rule:** Start with `AdministratorAccess`, do a clean deploy, then generate the minimal policy from CloudTrail. Do not hand-roll the policy before the first successful deploy.

**Why:** SAM deploy touches a long chain: CloudFormation bootstrap stack (S3 bucket), Lambda, SQS, IAM roles, SSM. The full permission set isn't knowable in advance — each failed deploy reveals one more missing action. Hand-rolling is whack-a-mole.

**The right process:**
1. Attach `AdministratorAccess` to the deploy IAM user
2. Run a successful `make deploy`
3. IAM Console → Users → `<deploy-user>` → **Generate policy based on CloudTrail events** (set date range to last hour)
4. Review the generated policy, save as `infra/iam-deploy-policy.json`, replace `AdministratorAccess`

**Constraint:** The deploy user cannot manage its own IAM permissions. All IAM changes must be done from a root/admin account — via the Console, not the CLI as the deploy user.

---

## Python cross-compilation for Lambda

**Rule:** When building Python Lambda packages on a Mac, always pin platform, Python version, and implementation in the pip install command.

```makefile
pip3 install \
  --platform manylinux2014_aarch64 \
  --python-version 3.13 \
  --implementation cp \
  --only-binary=:all: \
  --target "$(ARTIFACTS_DIR)" \
  -r requirements.txt
```

**Why each flag:**
- `--platform manylinux2014_aarch64` — fetches Linux ARM64 wheels instead of macOS wheels. Lambda is Linux, your Mac is not.
- `--python-version 3.13` — without this, pip uses your *local* Python version (could be 3.12, 3.14, anything). Compiled extensions (`.so` files) are named `_module.cpython-313-aarch64-linux-gnu.so` — a `cp314` wheel won't load on Lambda Python 3.13.
- `--implementation cp` — CPython only. Excludes PyPy and other implementations.
- `--only-binary=:all:` — never fall back to compiling from source, which would produce a Mac binary.

**The silent failure mode:** If you omit `--python-version`, the deploy succeeds but the Lambda returns `No module named 'pydantic_core._pydantic_core'` (or similar) at runtime. The error gives no hint that the platform is wrong.

**When the runtime version changes** (e.g. upgrading from `python3.13` to `python3.14`): update both `infra/template.yaml` (`Runtime:`) and both `app/api/Makefile` + `app/worker/Makefile` (`--python-version`). These are currently two separate files — a known DRY violation.

**After changing pip flags:** always `rm -rf infra/.aws-sam` before redeploying. SAM caches builds keyed on `requirements.txt` hash — it doesn't detect flag changes.

---

## SAM template pitfalls

**`samconfig.toml` named environments don't inherit from `[default]`:**
```toml
[default.global.parameters]
stack_name = "myapp"   # ← NOT inherited by [prod.*]

[prod.global.parameters]
stack_name = "myapp"   # ← must repeat this for every named env
region = "us-east-1"
```
Every named environment (`prod`, `staging`) needs its own `[env.global.parameters]` block with `stack_name` and `region`.

**`AllowMethods` in `FunctionUrlConfig.Cors` doesn't accept `OPTIONS`:**
CloudFormation's schema only allows: `GET`, `PUT`, `HEAD`, `POST`, `PATCH`, `DELETE`, `*`. `OPTIONS` is rejected at changeset creation (silent until `sam validate --lint`). Lambda Function URLs handle CORS preflight automatically — you don't need to list OPTIONS.

**`*` can't be mixed with other methods:** Use either `['*']` alone or an explicit list. Not both.

**Run `sam validate --lint` before every first deploy to a new environment.** It catches schema violations that would otherwise surface as opaque `EarlyValidation::PropertyValidation` errors in CloudFormation.

---

## Recovering from `ROLLBACK_COMPLETE`

When a first deploy fails partway through, the stack ends up in `ROLLBACK_COMPLETE`. CloudFormation won't update it — it must be deleted first.

```bash
aws cloudformation delete-stack --stack-name <name> --region us-east-1 --profile <profile>
aws cloudformation wait stack-delete-complete --stack-name <name> --region us-east-1 --profile <profile>
# Then redeploy
make deploy
```

Check current state: `aws cloudformation describe-stacks --stack-name <name> --query "Stacks[0].StackStatus" --output text`

---

## Trace the full request path before committing to a transport protocol

**Rule:** Before choosing any transport protocol (streaming, SSE, WebSockets, HTTP/2), trace the complete request path through every layer and verify each one supports it.

**What went wrong on darkbadge:** `InvokeMode: RESPONSE_STREAM` was chosen because SSE needed it. But the full chain was never verified:

```
Lambda (RESPONSE_STREAM) → Mangum (API Gateway dict) → Function URL (passes dict as raw body) → Next.js proxy → browser
```

Mangum returns an API Gateway-style dict `{"statusCode": 200, "body": "..."}`. With `RESPONSE_STREAM`, Lambda Function URL passes that dict directly as the HTTP response body — no unwrapping. Every API call returned the wrapper dict instead of the actual data. The error (`a.filter is not a function`) gave no hint about the transport mismatch.

**The fix:** `BUFFERED` mode — Lambda unwraps the API Gateway dict correctly. SSE events are delivered buffered (all at once at end of stream) rather than live. Acceptable for a proof sprint; true streaming requires a custom handler that bypasses Mangum entirely.

**The principle:** A protocol choice that works at one layer can silently fail at another. Map the full chain — function → ASGI adapter → Lambda invoke mode → Function URL → proxy → client — before committing. One layer that can't handle streaming invalidates the whole stack.
