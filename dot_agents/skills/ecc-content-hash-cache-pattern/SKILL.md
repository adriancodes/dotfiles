---
name: ecc-content-hash-cache-pattern
description: "Use when repeated file processing is slow and results should be cached and invalidated by content rather than path."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/content-hash-cache-pattern/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for content hash cache pattern; adapted for explicit local scope and evidence-backed use."
---

# Content Hash Cache Pattern — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Content-Hash File Cache Pattern

Cache expensive deterministic file processing using content identity, processor version, configuration, and authorization scope. A content hash alone is insufficient when the result depends on configuration, model version, locale, or tenant access.

## When to Use

- PDF, OCR, image, or text processing is repeated on the same bytes.
- Renaming a file should retain a cache hit.
- Changed bytes or processor configuration must invalidate a cached result.
- A caller needs an explicit cache bypass.

## Streaming Content Identity

```python
import hashlib
from pathlib import Path

def compute_file_hash(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(65_536):
            digest.update(chunk)
    return digest.hexdigest()
```

Hashing is O(file size); the key lookup does not remove that cost. Hash and process the same immutable snapshot. Reading a mutable path once for hashing and again for extraction can cache one version under another version's hash.

## Complete Bounded-File Cache Example

This JSON-object processor example reads one bounded snapshot and passes those exact bytes to extraction. The caller supplies a private cache directory; do not use a shared untrusted directory or follow an attacker-controlled cache location. Permission/I/O errors remain visible. Corrupt JSON becomes an explicit cache-miss warning in the returned result, not a swallowed failure.

```python
import json
import os
import tempfile
from dataclasses import dataclass
from typing import Callable

@dataclass
class CachedResult:
    document: dict
    cache_hit: bool
    warnings: tuple[str, ...]

def extract_with_cache(
    path: Path,
    extract: Callable[[bytes], dict],
    *,
    cache_dir: Path,
    processor_version: str,
    configuration: dict,
    authorization_scope: str,
    cache_enabled: bool = True,
    max_bytes: int = 64 * 1024 * 1024,
) -> CachedResult:
    if max_bytes < 1:
        raise ValueError("max_bytes must be positive")
    with path.open("rb") as stream:
        content = stream.read(max_bytes + 1)
    if len(content) > max_bytes:
        raise ValueError("file exceeds bounded snapshot limit")
    if not cache_enabled:
        document = extract(content)
        if not isinstance(document, dict):
            raise TypeError("processor must return a JSON object")
        return CachedResult(document, False, ())

    identity = json.dumps(
        {
            "schema": 1,
            "processor": processor_version,
            "configuration": configuration,
            "scope": authorization_scope,
            "content_sha256": hashlib.sha256(content).hexdigest(),
        },
        sort_keys=True, separators=(",", ":"), allow_nan=False,
    )
    key = hashlib.sha256(identity.encode("utf-8")).hexdigest()
    destination = cache_dir / (key + ".json")
    warnings = ()
    try:
        encoded = destination.read_text(encoding="utf-8")
    except FileNotFoundError:
        encoded = None
    if encoded is not None:
        try:
            entry = json.loads(encoded)
            if not isinstance(entry, dict) or entry.get("key") != key:
                raise ValueError("cache identity mismatch")
            if not isinstance(entry.get("document"), dict):
                raise ValueError("cached document is not an object")
        except (json.JSONDecodeError, ValueError) as exc:
            warnings = ("Invalid cache entry: " + str(exc),)
        else:
            return CachedResult(entry["document"], True, ())

    document = extract(content)
    if not isinstance(document, dict):
        raise TypeError("processor must return a JSON object")
    payload = json.dumps({"key": key, "document": document}, allow_nan=False)
    cache_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", dir=cache_dir, delete=False
        ) as stream:
            temporary = Path(stream.name)
            stream.write(payload)
            stream.flush()
        os.replace(temporary, destination)
        temporary = None
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    return CachedResult(document, False, warnings)
```

All definitions needed by the cache example are present across the two blocks. `extract` is the application's real deterministic processor, not an included PDF/OCR engine. Loading this document does not run it or create a cache.

## Design Decisions

| Decision | Contract |
| --- | --- |
| Hash bytes rather than path | Same authorized bytes/configuration can hit after rename |
| Include processor/configuration/scope | Prevent reuse across incompatible processing or access domains |
| One bounded snapshot | Hash and processing refer to the same version |
| JSON envelope with identity | Validate cached structure instead of trusting arbitrary deserialization |
| Atomic replacement | Readers do not observe a partially written JSON file |
| Explicit corruption warning | Reprocessing is visible; permission errors are not disguised as misses |
| Separate processing callback | Cache policy does not leak into extraction logic |

For very large files, use a stable caller-owned snapshot and a streaming processor rather than unbounded `read_bytes`. Concurrent callers may duplicate expensive work; add single-flight only if that cost is measured. Atomic replacement is not a durability guarantee against power loss; a reconstructible cache usually does not need database-like durability.

## Boundaries and Review

- Store only data permitted by the cache retention/privacy policy; content hashes can also reveal information.
- Set a size/age cleanup policy explicitly rather than silently growing forever.
- Bypass caching for nondeterministic or externally stateful processing unless all relevant version/state inputs are represented.
- Check changed-content invalidation, rename hits, changed-config misses, corrupted entry warnings, and cache-disabled behavior against supplied results or an explicitly requested local scenario.
- Do not add session log capture or learning records.

Done when the cache key covers every result-affecting input and reported evidence distinguishes cache correctness from extraction correctness.

