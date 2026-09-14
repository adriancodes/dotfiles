---
name: ecc-regex-vs-llm-structured-text
description: "Use when the requested task concerns regex vs llm structured text."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/regex-vs-llm-structured-text/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for regex vs llm structured text; adapted for explicit local scope and evidence-backed use."
---

# Regex Vs Llm Structured Text — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Regex versus LLM for Structured Text

Choose deterministic parsing for a stable grammar and use model assistance only for explicitly authorized, low-confidence cases that the grammar cannot handle. Corpus-specific accuracy and cost claims are not universal; measure against a representative labeled sample.

## Decision Framework

1. Identify the grammar and observable completeness contract.
2. Use a regex or ordinary parser when structure is consistent.
3. Account for every input record, including malformed and unmatched records.
4. Compare extraction accuracy and unresolved coverage against the caller's threshold.
5. Choose human review, a richer parser, or an authorized model adapter for unresolved cases; a model is not automatically the best parser for free-form input.

## Complete Quiz Parser Example

The grammar is numbered questions, four labeled choices, and an A–D answer. Unmatched records are reported instead of disappearing before confidence scoring.

```python
import re
from dataclasses import dataclass
from typing import Callable

@dataclass
class ParsedItem:
    item_id: str
    text: str
    choices: tuple[str, ...]
    answer: str

@dataclass
class Unresolved:
    source: str
    reason: str

@dataclass
class ParseResult:
    items: list[ParsedItem]
    unresolved: list[Unresolved]

START = re.compile(r"(?m)^\d+\.\s+")
RECORD = re.compile(
    r"(?P<id>\d+)\.\s+(?P<text>.+?)\n"
    r"A\.\s+(?P<a>[^\n]+)\n"
    r"B\.\s+(?P<b>[^\n]+)\n"
    r"C\.\s+(?P<c>[^\n]+)\n"
    r"D\.\s+(?P<d>[^\n]+)\n"
    r"Answer:\s*(?P<answer>[A-D])\s*",
    re.S,
)

def parse_structured_text(content: str) -> ParseResult:
    content = content.replace("\r\n", "\n").replace("\r", "\n")
    starts = list(START.finditer(content))
    result = ParseResult([], [])
    if not starts:
        if content.strip():
            result.unresolved.append(Unresolved(content, "no numbered record"))
        return result
    if content[:starts[0].start()].strip():
        result.unresolved.append(Unresolved(content[:starts[0].start()], "unparsed prefix"))
    seen = set()
    for index, start in enumerate(starts):
        end = starts[index + 1].start() if index + 1 < len(starts) else len(content)
        block = content[start.start():end].strip()
        match = RECORD.fullmatch(block)
        if match is None:
            result.unresolved.append(Unresolved(block, "record does not match grammar"))
            continue
        item_id = match["id"]
        if item_id in seen:
            result.unresolved.append(Unresolved(block, "duplicate item ID"))
            continue
        seen.add(item_id)
        choices = tuple(match[name].strip() for name in ("a", "b", "c", "d"))
        result.items.append(ParsedItem(item_id, match["text"].strip(), choices, match["answer"]))
    return result

def confidence_reasons(item: ParsedItem) -> tuple[str, ...]:
    reasons = []
    if len(item.text) < 10:
        reasons.append("short question; inspect source")
    if len(set(item.choices)) != 4:
        reasons.append("duplicate choice text")
    if any(not choice for choice in item.choices):
        reasons.append("empty choice")
    return tuple(reasons)

def validate_candidate(original: ParsedItem, candidate: dict) -> ParsedItem:
    if set(candidate) != {"item_id", "text", "choices", "answer"}:
        raise ValueError("unexpected candidate schema")
    choices = candidate["choices"]
    if candidate["item_id"] != original.item_id:
        raise ValueError("candidate changed record identity")
    if not isinstance(candidate["text"], str) or not candidate["text"].strip():
        raise ValueError("candidate question is missing")
    if not isinstance(choices, list) or len(choices) != 4:
        raise ValueError("candidate must have four choices")
    if any(not isinstance(value, str) or not value.strip() for value in choices):
        raise ValueError("candidate choices are invalid")
    if candidate["answer"] not in ("A", "B", "C", "D"):
        raise ValueError("candidate answer is invalid")
    return ParsedItem(original.item_id, candidate["text"], tuple(choices), candidate["answer"])
```

This is an intentionally narrow grammar, not a general invoice or PDF parser. Numbered lines inside a question, multiline choices, missing answers, OCR noise, and malformed encodings need corpus-specific cases or a richer parser. A heuristic warning is not a calibrated probability.

## Optional Validator Boundary

Pass only the exact problematic source span and parsed candidate to a separately authorized validator. Require an explicit structured result, validate it using the schema above, and compare it to source evidence. Correct JSON does not establish factual correctness. Never accept a fabricated answer merely because the model supplied an A–D letter.

A provider adapter must use an approved model, version-matched structured-output API, timeout, token/spend cap, and data-egress policy. It must expose failures rather than inventing a `corrected_item`. No paid API client, model call, or prompt is executed by this skill. Without an adapter or approval, return unresolved items and confidence reasons to the caller.

## Hybrid Pipeline Contract

```text
source text
  -> deterministic parser
  -> parsed records + unmatched spans
  -> confidence reasons
  -> acceptable records / unresolved review queue
  -> optional explicitly authorized validator
  -> schema check + source-grounding check
  -> output with unresolved counts and reasons
```

## Metrics and Boundary Cases

Report exact-match accuracy, field accuracy, unmatched-record rate, unresolved rate, and validator cost using the caller's labeled corpus. Record denominators and dataset version. Do not repeat the upstream anecdotal 95–98% coverage or 95% cost savings as expected results.

Check missing fields, duplicate IDs, trailing garbage, Unicode/OCR variants, multiline content, invalid model schemas, ungrounded repairs, and unavailable validation. Avoid sending a whole private document to repair one record. Do not log source text or collect session learning automatically.

Done when every candidate record is either grounded output or explicitly unresolved, and the regex/model choice is justified by supplied corpus evidence.

