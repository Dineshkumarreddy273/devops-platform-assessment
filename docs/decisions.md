# Design decisions and trade-offs

1. **Flask sample rather than feature work:** assessment values delivery pattern, not application features.
2. **Multi-stage Docker build:** dependencies are installed in a builder stage; runtime image is separate and runs as a non-root user.
3. **Cloud Run v2 service:** explicit ingress, resource limits, timeout, concurrency, scaling, dedicated runtime identity, and production deletion protection.
4. **No secrets in Terraform:** secret payloads can leak into plan/state. Only secret references should be configured; runtime identity gets narrowly scoped Secret Manager access.
5. **Separate Terraform roots:** dev and prod share a module but have independent root configs and intended independent state.
6. **State:** local backend is used only to make credential-free checks easy. Real deployment should use GCS backend with versioning, access controls, audit logging, and a documented recovery plan.
7. **Image identity:** use commit SHA and preferably digest; avoid mutable `latest`. Promotion should reuse the same digest.
8. **WIF:** OIDC short-lived credentials are preferred over long-lived service-account keys. Trust must be constrained to repository, branch, and environment claims.
9. **Production guardrails:** protected GitHub environment, required reviewer, serialized apply, saved plan review, and rollback to previous revision.
10. **Action pinning:** this sample uses major-version tags for readability. Before production use, pin every third-party action to a verified full commit SHA and use Dependabot/Renovate or an approved update process to refresh pins.
11. **Ingress:** dev permits unauthenticated access for smoke-test convenience. Production denies public invocation and assumes a load-balancer path; verify the direct Cloud Run URL is blocked when the LB is introduced.
12. **HA:** two regions are a design, not an implemented guarantee. State stores, queues, secrets, quotas, and third-party dependencies need their own resilience plan.
