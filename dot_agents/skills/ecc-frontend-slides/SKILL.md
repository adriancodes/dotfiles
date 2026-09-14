---
name: ecc-frontend-slides
description: Create stunning, animation-rich HTML presentations from scratch or by converting PowerPoint files. Use when the user wants to build a presentation, convert a PPT/PPTX to web, or create slides for a talk/pitch. Helps non-designers discover their aesthetic through visual exploration rather than abstract choices.
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/frontend-slides/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  adaptation: local-portable-guide
---

# Frontend Slides

Create zero-dependency, animation-rich HTML presentations that run entirely in the browser.

Inspired by the visual exploration approach showcased in work by zarazhangrui (credit: @zarazhangrui).

## Local scope and opt-in prerequisites

Installation preserves this guide and its supporting assets only; it does not generate previews, run scripts, install packages, start servers, or open applications. At invocation, confirm the workspace output location. A browser is required to render and visually verify the deck; without it, report that verification is unavailable rather than claiming viewport fit.

- HTML authoring can use plain file-writing tools; browser automation is optional, with manual browser checks as the fallback.
- PPTX extraction requires an existing Python 3 environment with `python-pptx`. Read [scripts/extract-pptx.py](scripts/extract-pptx.py) before an explicitly requested extraction. It writes `assets/` images and `extracted-slides.json` and can overwrite same-named outputs. It does not read legacy `.ppt`; ask for a `.pptx` or an export from an already-available converter.
- Optional image processing in [html-template.md](html-template.md) requires existing Pillow. Do not install it automatically; keep original images or request user-prepared assets if unavailable.
- Use an already-available browser print/export facility for a requested PDF, or report the missing capability. Preserve [references/upstream-export-pdf.sh.txt](references/upstream-export-pdf.sh.txt) as **audit-only source, not a runnable recommendation**: it installs Playwright, downloads Chromium, serves files on an unspecified interface without path containment, executes deck scripts and remote requests, creates PDF/temp files, deletes temp data, and opens the result. Do not execute this retained helper.
- Remote Google Fonts/Fontshare requests require an explicitly accepted network dependency; use supplied local fonts or an intentional system-font treatment when offline. Inline editing is separately opt-in because it persists content in browser localStorage and downloads edited HTML.

These prerequisites are not permission grants. Missing tooling remains a reported limitation; no new service, integration, account, or dependency is installed by this guide.

## When to Activate

- Creating a talk deck, pitch deck, workshop deck, or internal presentation
- Converting `.ppt` or `.pptx` slides into an HTML presentation
- Improving an existing HTML presentation's layout, motion, or typography
- Exploring presentation styles with a user who does not know their design preference yet

## Non-Negotiables

1. **Zero dependencies**: default to one self-contained HTML file with inline CSS and JS.
2. **Viewport fit is mandatory**: every slide must fit inside one viewport with no internal scrolling.
3. **Show, don't tell**: use visual previews instead of abstract style questionnaires.
4. **Distinctive design**: avoid generic purple-gradient, Inter-on-white, template-looking decks.
5. **Production quality**: keep code commented, accessible, responsive, and performant.

Before generating, read [STYLE_PRESETS.md](STYLE_PRESETS.md) for the viewport-safe CSS base, density limits, preset catalog, and CSS gotchas. Read [html-template.md](html-template.md) for the generation architecture, [viewport-base.css](viewport-base.css) for the full CSS base, and [animation-patterns.md](animation-patterns.md) when selecting motion. The HTML template is illustrative, not a finished deck: implement its controller methods and verify the actual output before delivery.

## Workflow

### 1. Detect Mode

Choose one path:
- **New presentation**: user has a topic, notes, or full draft
- **PPT conversion**: user has `.ppt` or `.pptx`
- **Enhancement**: user already has HTML slides and wants improvements

### 2. Discover Content

Ask only the minimum needed:
- purpose: pitch, teaching, conference talk, internal update
- length: short (5-10), medium (10-20), long (20+)
- content state: finished copy, rough notes, topic only

If the user has content, ask them to paste it before styling.

### 3. Discover Style

Default to visual exploration.

If the user already knows the desired preset, skip previews and use it directly.

Otherwise:
1. Ask what feeling the deck should create: impressed, energized, focused, inspired.
2. Generate **3 single-slide preview files** in `.ecc-design/slide-previews/`.
3. Each preview must be self-contained, show typography/color/motion clearly, and stay under roughly 100 lines of slide content.
4. Ask the user which preview to keep or what elements to mix.

Use the preset guide in `STYLE_PRESETS.md` when mapping mood to style.

### 4. Build the Presentation

Output either:
- `presentation.html`
- `[presentation-name].html`

Use an `assets/` folder only when the deck contains extracted or user-supplied images.

Required structure:
- semantic slide sections
- a viewport-safe CSS base from `STYLE_PRESETS.md`
- CSS custom properties for theme values
- a presentation controller class for keyboard, wheel, and touch navigation
- Intersection Observer for reveal animations
- reduced-motion support

### 5. Enforce Viewport Fit

Treat this as a hard gate.

Rules:
- every `.slide` must use `height: 100vh; height: 100dvh; overflow: hidden;`
- all type and spacing must scale with `clamp()`
- when content does not fit, split into multiple slides
- never solve overflow by shrinking text below readable sizes
- never allow scrollbars inside a slide

Use the density limits and mandatory CSS block in `STYLE_PRESETS.md`.

### 6. Validate

Check the finished deck at these sizes:
- 1920x1080
- 1280x720
- 768x1024
- 375x667
- 667x375

If browser automation is available, use it to verify no slide overflows and that keyboard navigation works.

### 7. Deliver

At handoff:
- delete temporary preview files unless the user wants to keep them
- open the deck with the platform-appropriate opener when useful
- summarize file path, preset used, slide count, and easy theme customization points

Use the correct opener for the current OS:
- macOS: `open file.html`
- Linux: `xdg-open file.html`
- Windows: `start "" file.html`

## PPT / PPTX Conversion

For PowerPoint conversion:
1. For `.pptx`, use an existing `python3` environment with `python-pptx` to extract text, images, and notes; legacy `.ppt` needs a user-provided conversion or export first.
2. If `python-pptx` is unavailable, report it and request a user-provided export/manual source. Package installation is a separate opt-in task, not an automatic step.
3. Preserve slide order, speaker notes, and extracted assets.
4. After extraction, run the same style-selection workflow as a new presentation.

Keep conversion cross-platform. Do not rely on macOS-only tools when Python can do the job.

## Implementation Requirements

### HTML / CSS

- Use inline CSS and JS unless the user explicitly wants a multi-file project.
- Fonts may come from Google Fonts or Fontshare when that network dependency is accepted; otherwise use supplied local fonts or an intentional system-font treatment.
- Prefer atmospheric backgrounds, strong type hierarchy, and a clear visual direction.
- Use abstract shapes, gradients, grids, noise, and geometry rather than illustrations.

### JavaScript

Include:
- keyboard navigation
- touch / swipe navigation
- mouse wheel navigation
- progress indicator or slide index
- reveal-on-enter animation triggers

### Accessibility

- use semantic structure (`main`, `section`, `nav`)
- keep contrast readable
- support keyboard-only navigation
- respect `prefers-reduced-motion`

## Content Density Limits

Use these maxima unless the user explicitly asks for denser slides and readability still holds:

| Slide type | Limit |
|------------|-------|
| Title | 1 heading + 1 subtitle + optional tagline |
| Content | 1 heading + 4-6 bullets or 2 short paragraphs |
| Feature grid | 6 cards max |
| Code | 8-10 lines max |
| Quote | 1 quote + attribution |
| Image | 1 image constrained by viewport |

## Anti-Patterns

- generic startup gradients with no visual identity
- system-font decks unless intentionally editorial
- long bullet walls
- code blocks that need scrolling
- fixed-height content boxes that break on short screens
- invalid negated CSS functions like `-clamp(...)`

## Related ECC Skills

- Optional component/interaction guidance: use the project's existing patterns or semantic HTML and the bundled controller architecture; no `frontend-patterns` companion is required.
- Optional glass aesthetics: apply translucent layers only when intentionally chosen and contrast remains readable; no `liquid-glass-design` companion is required.
- Optional browser automation: exercise viewport fit, navigation, and reduced motion using an existing browser tool, or perform manual checks; no extra `e2e-testing` skill or browser service is installed.

## Deliverable Checklist

- presentation runs from a local file in a browser
- every slide fits the viewport without scrolling
- style is distinctive and intentional
- animation is meaningful, not noisy
- reduced motion is respected
- file paths and customization points are explained at handoff

## Attribution

Adapted from ECC by Affaan Mustafa, revision `e04ea0b9cc8248686edf5ac751cadff550e162b8`. MIT license; see `LICENSE` in this directory. Upstream credits the visual exploration approach of zarazhangrui. All upstream support content is retained; the unsafe PDF exporter is relocated as audit-only text. Local adaptations clarify optional tooling and side effects; browser rendering, conversion, and export integrations have not been verified by this import.
