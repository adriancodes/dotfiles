---
name: ecc-skill-stocktake
description: "Use when auditing a skill catalog for duplicate triggers, stale references, broken supporting files, or skills to keep, improve, update, retire, or merge."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/skill-stocktake/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Agent Operations
  summary: "Audits real skill discovery roots and content changes without editing installed skills or reading private histories."
---

# Skill Stocktake

## Scope

Audit installed skills for overlap, stale guidance, broken dependencies, and unclear triggers. Use a full inventory or a content-hash-based comparison with an explicitly supplied previous audit. Do not change, retire, merge, or rewrite a skill during the audit. Ask for authorization before applying recommendations.

## Workflow

### Inventory the actual discovery roots

Discover the current harness's configured skill roots. Start with shared `~/.agents/skills` and the project's `.agents/skills` when supported, then account for native roots and explicit overrides. Report roots that are missing or unreadable. Do not assume all harnesses load the same roots.

Resolve symlinks and count each physical skill once. Preserve all discovery aliases and flag same-name skills with different targets. Parse frontmatter as YAML, including folded descriptions; do not infer names/descriptions with a line-only parser. Inspect the full skill and required local supporting files. Do not read credentials, private session logs, or raw conversation transcripts to obtain usage estimates.

Record name, description, canonical path, aliases, source revision when known, and content hashes covering the skill plus supporting dependencies. Report usage as unknown unless the user supplies suitable aggregate measurements; missing telemetry is not zero usage.

Done when every discovered entry is accounted for and incomplete discovery is explicit.

### Choose the review mode

For a full audit, assess every entry. For a changed-only audit, compare content hashes and discovery aliases against the supplied previous inventory. Include additions, modifications, deletions, and broken links. Modification time alone is not proof of unchanged content. If no comparable baseline exists, report that limitation and use a full audit.

Carry forward an unchanged verdict only with its original evidence and evaluation timestamp. Never stamp old evidence as newly evaluated. For an interrupted audit, list unfinished entries rather than describing the entire catalog as reviewed.

Done when the audit scope and carried-forward evidence are explicit.

### Evaluate quality

Assess each skill against these dimensions:

- Actionability: concrete steps, examples, and completion criteria.
- Scope fit: agreement between name, triggers, exclusions, and body.
- Uniqueness: contribution beyond existing skills and project rules.
- Currency: compatibility with the actual tools, APIs, and installed versions.
- Portability: self-contained references and honest capability fallbacks.
- Cost: context and maintenance burden justified by the task.

Read known official documentation URLs directly when checking API or CLI claims. Use available web search only when the source is not known. If current references cannot be verified, mark that evidence unavailable.

A large catalog may be divided into bounded batches. Use existing delegation only if the harness supports it and the task permits it; otherwise review sequentially. Every inventory item must retain a verdict or an explicit pending/error state. Do not infer completion from a worker finishing.

Use these evidence-backed verdicts:

| Verdict | Required reason |
|---|---|
| Keep | Specific useful behavior and why current alternatives do not replace it |
| Improve | Exact section and concrete change that would address the defect |
| Update | Outdated reference plus verified current replacement, or uncertainty |
| Retire | Concrete defect and the existing alternative covering the same need |
| Merge | Named target plus the distinct content worth carrying over |

Do not justify retirement solely by age, low observed usage, or origin. Treat verdicts as review judgments, not calibrated effectiveness scores. Do not require arbitrary line-count limits for unrelated project instruction files.

Done when every in-scope entry has a self-contained, actionable reason or an explicitly unresolved status.

## Output Contract

Return the scanned roots, completed/pending counts, and a table of skill, verdict, evidence, and recommended action. For merge/retire proposals, list dependent references and expected impact. Report deleted or broken entries separately. Preserve the distinction between observed faults and hypotheses about performance.

If the user requests a saved audit, write to the agreed output location, not inside an installed skill or a private harness state directory. Keep real UTC evaluation timestamps and per-entry source hashes. Never overwrite an unrelated audit or present incomplete batches as completed.

## Verification

Check that counts reconcile with the inventory, symlink aliases were deduplicated, and every verdict cites inspected evidence. Check that unchanged entries retain their old timestamp and broken/deleted dependencies were not omitted.

Done when the report accounts for the requested scope and no installed skills, settings, or private histories were changed.

## Attribution

Adapted from ECC by Affaan Mustafa, pinned revision `e04ea0b9cc8248686edf5ac751cadff550e162b8`, under the MIT license in `LICENSE`. This import has compatibility checks, not a claim of measured effectiveness.
