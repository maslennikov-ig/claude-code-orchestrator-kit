---
name: frontend-aesthetics
description: Guide frontend design decisions to create distinctive, creative UIs that avoid generic AI-generated aesthetics. Use when building UI components, designing layouts, selecting colors/fonts, or implementing animations.
---

# Frontend Aesthetics

Create distinctive designs that avoid generic AI-generated aesthetics.

## When to Use

- Designing UI components, layouts, landing pages, dashboards
- Selecting typography, colors, animations
- Reviewing designs for generic patterns

## Design Principles

### Typography

**AVOID** (overused): Inter, Roboto, Arial, system fonts

**Recommended**:
- Code/Technical: JetBrains Mono, Fira Code, Victor Mono
- Editorial: Playfair Display, Crimson Pro, Spectral, Lora
- Modern: DM Sans, Outfit, Plus Jakarta Sans (vary across projects)

### Colors & Theme

**AVOID**: Purple gradients on white (clichéd AI aesthetic), generic blue/gray

**Principles**:
- Dominant colors with sharp accents > evenly-distributed palettes
- Draw from IDE themes (Dracula, Nord, Tokyo Night, Monokai)
- Use CSS variables for theming
- 1-2 dominant + 1-2 accent colors

### Animation

**Priorities**:
1. High-impact: Orchestrated page loads with staggered reveals
2. Micro-interactions: Button hovers, state changes
3. Contextual: Scroll-triggered, parallax

**Implementation**: CSS-only for HTML/Vanilla JS, Motion (Framer) for React

```css
.stagger-item { animation: fadeInUp 0.6s ease-out forwards; opacity: 0; }
.stagger-item:nth-child(1) { animation-delay: 0.1s; }
.stagger-item:nth-child(2) { animation-delay: 0.2s; }
```

### Backgrounds

**AVOID**: Solid white/gray, flat surfaces

**Use**: Layered gradients, geometric patterns, subtle noise, contextual glow/blur

## Anti-Pattern Checklist

- [ ] Not using Inter, Roboto, Arial, system fonts
- [ ] No purple gradients on white
- [ ] Color hierarchy clear (dominant + accent)
- [ ] Animations orchestrated and purposeful
- [ ] Backgrounds have depth
- [ ] Typography matches brand personality
- [ ] Design varies from previous projects

## Output Format

```json
{
  "typography": { "primary": "Font + reasoning", "secondary": "Font", "code": "Mono font" },
  "colors": { "dominant": ["#hex"], "accent": ["#hex"], "theme_inspiration": "Reference" },
  "animations": { "approach": "CSS-only|Framer", "focus": "Page load|micro-interactions", "key_moments": [] },
  "backgrounds": { "technique": "Gradients|patterns", "atmosphere": "Description" },
  "anti_pattern_validation": { "passed": true, "warnings": [] }
}
```

## Example

**Input**: Technical documentation, code-focused, for developers

**Output**:
- Typography: DM Sans (primary), Crimson Pro (editorial), JetBrains Mono (code)
- Colors: #0f172a, #1e293b (dominant), #38bdf8, #f97316 (accent) - Tokyo Night inspired
- Animations: CSS-only, staggered section reveals
- Background: Dark gradient with subtle grid overlay

## Notes

- Variation is critical - avoid converging on same choices across projects
- Context matters - match brand identity and purpose
- Performance: CSS-only preferred, Framer Motion for complex React animations
- Ensure WCAG compliance despite distinctive aesthetics
