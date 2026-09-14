# Product Capability Template

Use this when product intent exists but the implementation constraints are still implicit.

The purpose is to create a durable capability contract, not another vague planning doc.

## Capability

- **Capability name:**
- **Source:** PRD / issue / discussion / roadmap / founder note
- **Primary actor:**
- **Outcome after ship:**
- **Success signal:**

## Product Intent

Describe the user-visible promise in one short paragraph.

## Constraints

List the rules that must be true before implementation starts:

- business rules
- scope boundaries
- invariants
- rollout constraints
- migration constraints
- backwards compatibility constraints
- billing / auth / compliance constraints

## Actors and Surfaces

- actor(s)
- UI surfaces
- API surfaces
- automation / operator surfaces
- reporting / dashboard surfaces

## States and Transitions

Describe the lifecycle in terms of explicit states and allowed transitions.

Example:

- `draft -> active -> paused -> completed`
- `pending -> approved -> provisioned -> revoked`

## Interface Contract

- inputs
- outputs
- required side effects
- failure states
- retries / recovery
- idempotency expectations

## Data Implications

- source of truth
- new entities or fields
- ownership boundaries
- retention / deletion expectations

## Security and Policy

- trust boundaries
- permission requirements
- abuse paths
- policy / governance requirements

## Non-Goals

List what this capability explicitly does not own.

## Open Questions

Capture the unresolved decisions blocking implementation.

## Handoff

- **Ready for implementation?**
- **Needs architecture review?**
- **Needs product clarification?**
- **Next work:** delivery coordination / test-first implementation / verification / other; name an existing suitable workflow if available, or specify the concrete next steps directly

## Attribution

Adapted from [ECC's product capability template](https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/docs/examples/product-capability-template.md) by Affaan Mustafa. Upstream Git blob SHA-1: `1a7a0c84bcf5c43181ce04ed04b075a34b430c86`. MIT license; see `../LICENSE`. Local adaptation replaces required-looking companion names with a portable handoff; all contract sections are retained.
