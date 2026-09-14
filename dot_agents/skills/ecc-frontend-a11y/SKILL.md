---
name: ecc-frontend-a11y
description: "Use when implementing or reviewing React or Next.js form labels, ARIA relationships, keyboard selection, dialogs, focus, or reduced motion."
license: MIT
metadata:
  origin: ECC
  source: "https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/frontend-a11y/SKILL.md"
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Web
  summary: "Frontend semantics, labeling, keyboard interaction, focus, and reduced-motion patterns."
---
> Attributed third-party import from [ECC](https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/frontend-a11y/SKILL.md) at `e04ea0b9cc8248686edf5ac751cadff550e162b8`. Adapted for on-demand, harness-neutral use; not behaviorally evaluated or certified by this collection. See `LICENSE`.

## Use Boundary

Apply this reference on demand to the requested framework task. Read the installed versions and reuse the project's tools and conventions. Examples describe application code and local configuration, not permission to install dependencies, change global settings, reset caches, mutate git, deploy, upload data, or contact external services. Run code or modify project files only when that local work was requested. In a static review, read code and supplied results; request any missing runtime evidence from the caller instead of executing it. Use supported tools by role and keep diagnostics visible. Treat snippets with application-specific types, APIs, paths, and UI content as examples to adapt, not existing required files.

> Upstream ECC metadata credited this reference to the community; that origin is retained here alongside the pinned ECC import attribution.

# Frontend Accessibility Patterns

Practical accessibility patterns for React and Next.js. Covers the issues most commonly flagged in code review: missing form labels, incorrect ARIA usage, non-semantic interactive elements, and broken keyboard navigation.

## When to Activate

- Building or reviewing form components (`<input>`, `<select>`, `<textarea>`)
- Creating interactive elements (modals, dropdowns, tooltips, tabs)
- Using `<div>` or `<span>` with `onClick`
- Adding `aria-*` attributes to any element
- Implementing keyboard navigation or focus management
- Receiving accessibility feedback from code review tools (CodeRabbit, ESLint a11y)
- Building components that must support screen readers

## Form Accessibility

Missing `htmlFor` / `id` pairing and disconnected error messages are the most common issues flagged in code review.

### Label Connection

```tsx
// BAD: label has no connection to input — screen readers cannot associate them
<label>Email</label>
<input type="email" />

// GOOD: htmlFor matches input id
<label htmlFor="email">Email</label>
<input id="email" type="email" />
```

### Required Fields

```tsx
// BAD: visual-only asterisk conveys nothing to screen readers
<label htmlFor="email">Email *</label>
<input id="email" type="email" />

// GOOD: required enables native browser validation; aria-required signals it to screen readers
<label htmlFor="email">
  Email <span aria-hidden="true">*</span>
</label>
<input id="email" type="email" required aria-required="true" />
```

### Error Messages

```tsx
// BAD: error text exists visually but is not linked to the input
<input id="email" type="email" />
<span className="error">Invalid email address</span>

// GOOD: aria-describedby connects input to its error message
// aria-invalid signals the invalid state to screen readers
<input
  id="email"
  type="email"
  aria-describedby="email-error"
  aria-invalid={!!error}
/>
{error && (
  <span id="email-error" role="alert">
    {error}
  </span>
)}
```

### Complete Accessible Form

```tsx
interface LoginFormProps {
  onSubmit: (email: string, password: string) => void;
}

export function LoginForm({ onSubmit }: LoginFormProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState<{ email?: string; password?: string }>({});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const newErrors: typeof errors = {};
    if (!email) newErrors.email = 'Email is required';
    if (!password) newErrors.password = 'Password is required';
    if (Object.keys(newErrors).length) {
      setErrors(newErrors);
      return;
    }
    onSubmit(email, password);
  };

  return (
    <form onSubmit={handleSubmit} noValidate>
      <div>
        <label htmlFor="email">
          Email <span aria-hidden="true">*</span>
        </label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={e => setEmail(e.target.value)}
          aria-required="true"
          aria-describedby={errors.email ? 'email-error' : undefined}
          aria-invalid={!!errors.email}
          autoComplete="email"
        />
        {errors.email && (
          <span id="email-error" role="alert">
            {errors.email}
          </span>
        )}
      </div>

      <div>
        <label htmlFor="password">
          Password <span aria-hidden="true">*</span>
        </label>
        <input
          id="password"
          type="password"
          value={password}
          onChange={e => setPassword(e.target.value)}
          aria-required="true"
          aria-describedby={errors.password ? 'password-error' : undefined}
          aria-invalid={!!errors.password}
          autoComplete="current-password"
        />
        {errors.password && (
          <span id="password-error" role="alert">
            {errors.password}
          </span>
        )}
      </div>

      <button type="submit">Log in</button>
    </form>
  );
}
```

## Semantic HTML

Use the element that matches the intent. Screen readers and keyboard users depend on native semantics.

```tsx
// BAD: div has no role, no keyboard support, no accessible name
<div onClick={handleClick}>Submit</div>

// GOOD: button is focusable, activates on Enter/Space, announces as "button"
<button type="button" onClick={handleClick}>Submit</button>
```

```tsx
// BAD: non-semantic navigation
<div onClick={() => navigate('/home')}>Home</div>

// GOOD: anchor supports right-click, middle-click, and keyboard navigation
<a href="/home">Home</a>
```

```tsx
// BAD: heading hierarchy skipped (h1 to h4)
<h1>Dashboard</h1>
<h4>Recent Activity</h4>

// GOOD: sequential heading levels
<h1>Dashboard</h1>
<h2>Recent Activity</h2>
```

## ARIA Attributes

Use ARIA only when native HTML semantics are insufficient. Wrong ARIA is worse than no ARIA.

### aria-label vs aria-labelledby

```tsx
// aria-label: inline string label — use when no visible label text exists
<button aria-label="Close modal">
  <XIcon />
</button>

// aria-labelledby: references another element's text — use when a visible label exists
<section aria-labelledby="section-title">
  <h2 id="section-title">Recent Orders</h2>
  {/* content */}
</section>
```

### aria-describedby

```tsx
// Provides supplementary description beyond the label
<button
  aria-describedby="delete-warning"
  onClick={handleDelete}
> Delete account
</button>
<p id="delete-warning">This action cannot be undone.</p>
```

### aria-live for Dynamic Content

```tsx
// Use aria-live to announce content that updates without a page reload
// polite: waits for user to finish current action before announcing
// assertive: interrupts immediately — use only for urgent errors

export function StatusMessage({ message, isError }: { message: string; isError?: boolean }) {
  return (
    <div role="status" aria-live={isError ? 'assertive' : 'polite'} aria-atomic="true">
      {message}
    </div>
  );
}
```

### aria-expanded and aria-controls

```tsx
export function Accordion({ title, children }: { title: string; children: React.ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);
  const contentId = useId();

  return (
    <div>
      <button type="button" aria-expanded={isOpen} aria-controls={contentId} onClick={() => setIsOpen(prev => !prev)}>
        {title}
      </button>
      <div id={contentId} hidden={!isOpen}>
        {children}
      </div>
    </div>
  );
}
```

## Keyboard Navigation

Every interactive element must be reachable and operable by keyboard alone.

### Selection Controls

Use a labeled native select when it satisfies the interaction. It provides keyboard selection, focus, and selection announcements without recreating the combobox pattern.

```tsx
import { useId } from "react";

export function Dropdown({ label, options, value, onSelect }: {
  label: string; options: string[]; value: string;
  onSelect: (value: string) => void;
}) {
  const id = useId();
  return (
    <div>
      <label htmlFor={id}>{label}</label>
      <select id={id} value={value} onChange={e => onSelect(e.target.value)}>
        {options.map(option => <option key={option} value={option}>{option}</option>)}
      </select>
    </div>
  );
}
```

For a genuinely custom combobox, use an existing accessible primitive or implement its entire contract: accessible name, selected value separate from active option, `aria-expanded`, controlled listbox ID, active-descendant or managed focus, Arrow/Home/End keys, Enter selection, Escape dismissal, Tab behavior, pointer selection, and disabled/empty states. Do not claim a partial key handler provides complete keyboard or screen-reader support.

## Focus Management

Focus must move logically when UI state changes — especially for modals and route transitions.

### Modal Focus and Restoration

Use a native modal dialog or the project's established accessible dialog primitive. Native `showModal()` supplies modal focus containment and inert background behavior in supported browsers.

```tsx
import { useEffect, useId, useRef } from "react";

export function Modal({ isOpen, onClose, title, children }: {
  isOpen: boolean; onClose: () => void; title: string; children: React.ReactNode;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const titleId = useId();
  useEffect(() => {
    const dialog = ref.current;
    if (!isOpen || !dialog) return;
    const previous = document.activeElement;
    const overflow = document.body.style.overflow;
    dialog.showModal();
    document.body.style.overflow = "hidden";
    return () => {
      dialog.close();
      document.body.style.overflow = overflow;
      if (previous instanceof HTMLElement && previous.isConnected) previous.focus();
    };
  }, [isOpen]);
  return (
    <dialog ref={ref} aria-labelledby={titleId}
      onCancel={e => { e.preventDefault(); onClose(); }}>
      <h2 id={titleId}>{title}</h2>
      {children}
      <button type="button" onClick={onClose}>Close</button>
    </dialog>
  );
}
```

For stacked dialogs, reuse a dialog manager rather than independently restoring body styles. Verify initial focus, Escape, Tab/Shift+Tab, and restoration in the actual target browser when local verification is requested.

## Images and Icons

```tsx
// BAD: decorative icon announced as unlabeled image
<img src="/icon.svg" />

// GOOD: decorative image hidden from screen readers
<img src="/decoration.png" alt="" aria-hidden="true" />

// GOOD: meaningful image with descriptive alt text
<img src="/chart.png" alt="Monthly revenue increased 23% from January to March" />

// GOOD: icon button with accessible label
<button aria-label="Delete item">
  <TrashIcon aria-hidden="true" />
</button>
```

## Reduced Motion

Respect users who have requested reduced motion in their OS settings.

```tsx
export function useReducedMotion(): boolean {
  const [prefersReduced, setPrefersReduced] = useState(false);

  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    setPrefersReduced(mq.matches);
    const handler = (e: MediaQueryListEvent) => setPrefersReduced(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  return prefersReduced;
}

// Usage
export function AnimatedCard({ children }: { children: React.ReactNode }) {
  const reduceMotion = useReducedMotion();

  return (
    <div
      style={{
        transition: reduceMotion ? 'none' : 'transform 300ms ease'
      }}
    >
      {children}
    </div>
  );
}
```

## Anti-Patterns

```tsx
// BAD: onClick on non-interactive element with no keyboard support
<div onClick={handleClick}>Click me</div>

// BAD: aria-label on a div that has no role
<div aria-label="Navigation">...</div>

// BAD: placeholder used as a substitute for label
<input placeholder="Enter your email" />

// BAD: positive tabIndex creates unpredictable tab order
<button tabIndex={3}>Submit</button>

// BAD: aria-hidden on a focusable element — keyboard users get trapped
<button aria-hidden="true">Open</button>

// BAD: role="button" on div without keyboard handler
<div role="button" onClick={handleClick}>Submit</div>
// Missing: tabIndex={0}, onKeyDown for Enter/Space
```

## Checklist

Before submitting any interactive component for review:

- [ ] Every `<input>`, `<select>`, and `<textarea>` has a connected `<label>` via `htmlFor`/`id`
- [ ] Error messages are linked with `aria-describedby` and marked `role="alert"`
- [ ] No `onClick` on `<div>` or `<span>` without `role`, `tabIndex`, and `onKeyDown`
- [ ] Icon-only buttons have `aria-label`
- [ ] Decorative images use `alt=""` and `aria-hidden="true"`
- [ ] Modals contain focus, support Escape, and restore focus on close using native modal behavior or the existing accessible primitive
- [ ] Dynamic content updates use `aria-live`
- [ ] `prefers-reduced-motion` is respected for animations

## Related Guidance

- `ecc-react-patterns` if available; otherwise keep state transitions and accessible composition explicit.
- `ecc-design-system` if available; otherwise reuse consistent contrast, focus, and target-size tokens.
- `ecc-motion-patterns` if available; otherwise respect reduced motion and preserve accessible visibility during transitions.

