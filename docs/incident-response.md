# Incident response: latency and intermittent errors after deployment

## Objective and decision posture

Treat the release as the leading hypothesis, not as proof of root cause. Stabilize customer impact first. Use the previous known-good Cloud Run revision and immutable image digest for rollback. Keep a timeline and preserve evidence. The timings below are targets, not a reason to delay mitigation.

## First 10–15 minutes

### 0–3 minutes: confirm impact and stop progression
- Declare incident severity based on customer impact and SLO burn; name an incident lead.
- Stop further promotions and freeze unrelated changes.
- Compare error rate, p50/p95/p99 latency, request volume, 4xx/5xx, instance count, startup latency, CPU/memory, and concurrency against baseline.
- Confirm the exact service, region, revision, traffic split, image digest, commit SHA, Terraform plan/apply identity, and deployment timestamp.
- Capture Cloud Run revision details, logs, request logs, traces, metrics, and relevant GitHub workflow run/artifacts before changing traffic.

### 3–7 minutes: compare revisions and segment the failure
- Compare new and previous revision with matched time windows and traffic levels.
- Filter logs by revision, status code, request path, trace ID, and exception type; inspect stack traces and startup logs.
- Check configuration/environment variable changes, secret version references, CPU/memory, timeout, concurrency, min/max instances, ingress, and service account changes.
- Inspect downstream dependency latency/error rate, quota, connection pool saturation, and DNS/network errors.
- Verify whether all regions/users/routes are affected or only one revision, region, identity, or request class.

### 7–15 minutes: mitigate and verify
- If impact is material and correlated with the release, shift traffic back to the previous healthy revision or redeploy its immutable image digest. Do not wait for perfect root-cause certainty if the rollback is low risk.
- If only one region is degraded, shift traffic away from it if the load-balancing configuration supports it and confirm capacity in the surviving region.
- Verify recovery using error rate, p95/p99 latency, availability, and synthetic health checks for at least the agreed observation window.
- Keep the bad revision and logs for diagnosis; do not delete evidence during the incident.

## Hypothesis separation

| Area | Evidence to inspect | Typical next action |
|---|---|---|
| Application | Exception rate, traces, changed code, `/version`, CPU profile if available | Roll back; isolate regression; add regression test |
| Configuration | Revision template diff, env vars, timeout, concurrency, memory, scaling | Restore last known-good config or correct a specific setting |
| Identity / secrets | Cloud Run service identity, Secret Manager access, IAM audit logs, token errors | Restore least-privilege binding or secret version; never paste secret values into incident chat |
| Networking / ingress | Cloud Run ingress, LB backend health, DNS/TLS, egress, firewall/PSC where applicable | Correct route or policy; validate direct URL cannot bypass intended LB controls |
| Scaling / capacity | Instance count, startup latency, CPU/memory, concurrency, quota, cold starts | Raise safe capacity, lower concurrency, warm min instances temporarily, request quota if justified |
| Downstream dependency | Dependency latency, error codes, saturation, connection pools, rate limits | Engage dependency owner; enable bounded retries/circuit breaker only if safe |

## Owners and what they need

- **Incident commander / service owner:** customer impact, timeline, decision log, rollback authority.
- **Application owner:** revision-specific traces, stack traces, changed commit, reproduction details.
- **Platform / Cloud Run owner:** revision template diff, scaling, quota, ingress, runtime identity, deployment evidence.
- **Security / IAM owner:** principal, exact denied permission, audit event, resource and timestamp; no secret material.
- **Network / load-balancer owner:** URL/route, region, backend health, request IDs, DNS/TLS and ingress findings.
- **Dependency owner:** correlation IDs, request timing, error distribution, dependency saturation, safe retry expectations.

## Rollback / traffic-shift decision

Rollback or shift traffic when one or more pre-agreed triggers are met, for example:
- Error rate or latency breaches the service SLO / error-budget burn threshold for a sustained short window.
- New revision is materially worse than the previous revision and the timing correlates with release.
- Data correctness, security, or availability risk is unacceptable.
- There is no safe, fast mitigation that is more reliable than rollback.

Continue investigation without rollback only when impact is low, evidence does not correlate to the release, rollback is riskier, and an incident lead explicitly accepts the risk. Record the rationale and next checkpoint.

## Evidence preservation

Preserve workflow run URL, commit SHA, image digest, Terraform plan and apply logs, Cloud Run revision names, traffic split, relevant logs/traces/metrics, IAM audit events, config diff, timestamps, and decisions. Redact personal data and secrets. Store evidence in the approved incident location with access controls.

## Recovery and follow-up

- Confirm SLO metrics return to baseline and stay healthy.
- Keep the faulty revision for investigation, but do not send traffic to it.
- Root-cause the issue; add a regression test and a rollout guard (for example, automated smoke test plus canary metric gate).
- Review rollback time and alert quality in a blameless post-incident review.
