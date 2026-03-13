# Pencil MCP Workflow

Reference for working with .pen files via Pencil MCP tools. Load this knowledge when building or editing designs in Pencil.

## Starting a Session

1. `get_editor_state` — file state, schema, active document
2. `batch_get` with `{ reusable: true }` — discover existing design system components
3. `get_variables` — read all design tokens (colors, radii, spacing, fonts)
4. `get_guidelines` with relevant topic (`code`, `table`, `tailwind`, `landing-page`, `design-system`, `mobile-app`, `web-app`, `slides`) — Pencil's built-in design rules
5. `find_empty_space_on_canvas` — locate space for new screens/frames

Optional: `get_style_guide_tags` → `get_style_guide` for aesthetic direction from Pencil's style library.

## Component Reuse

Pencil design files contain reusable components (`reusable: true`) — buttons, cards, inputs, navbars. Recreating them from scratch causes divergence (inconsistent padding, colors, fonts) and breaks propagation.

**Always search before creating:**
```
batch_get({ patterns: [{ reusable: true }], readDepth: 2, searchDepth: 3 })
```

**Insert as ref instance** (not a copy of the structure):
```
btn=I("parentId", { type: "ref", ref: "btn-primary", width: "fill_container" })
```

**Customize via descendant paths:**
```
U(btn+"/btn-label", { content: "Submit" })
```

## Design Tokens (Variables)

Use variable references for all style values — never hardcode hex colors or pixel radii. Hardcoded values break theming, dark mode, and code generation (`fill: "#3b82f6"` becomes `bg-[#3b82f6]` instead of `bg-primary`).

```
get_variables()          → read all tokens
set_variables({ ... })   → create missing tokens
```

When a needed token doesn't exist, create it rather than hardcoding.

## Asset Management

AI image generation is non-deterministic — regenerating a logo produces a different logo.

Before any `G()` operation:
- Search for existing assets: `batch_get` with name patterns (`logo`, `brand`, `image`, `hero`)
- Copy existing assets with `C("existingNodeId", "targetParent", { width: 120 })`
- Only `G()` for genuinely new images that don't exist anywhere in the document

## Building and Verifying

Build each logical section (header, content, footer) independently. After each:
- `get_screenshot` of the section — evaluate visually as a user would
- `snapshot_layout` with `problemsOnly: true` — catch clipping, overflow, overlaps

Don't build an entire screen then check at the end — issues compound.

## Overflow Prevention

Mobile screens (375px) are especially prone:
- Text: `width: "fill_container"` inside auto-layout parents
- Containers: `layout: "vertical"` or `"horizontal"` with `gap` — avoid absolute positioning
- Long titles: `maxLines` for truncation
- Screen-level: horizontal padding (16-20px)

## Bulk Fixes

For consistency issues across many nodes:
- `search_all_unique_properties` on parent IDs → find all instances of a property
- `replace_all_matching_properties` → fix them in one call
- If a design token is wrong, `set_variables` — one fix propagates everywhere

## Common Pencil Failures

These are what `pen-design` produces most often — check for them during visual QA:
- Padding mismatch between sibling cards/sections (16px vs 24px)
- Icons at different sizes in the same row (16px next to 20px)
- Text not vertically centered in buttons or badges
- Uneven column widths in grids that should be equal
- Too much vertical space between sections
- Tap targets smaller than 44x44px
- Elements slightly off the alignment axis
- Font weight or size drift across same-type elements

Maximum 3 QA rounds — report remaining issues rather than looping.

## Operations Reference

| Operation | Syntax | Use |
|-----------|--------|-----|
| Insert | `foo=I("parent", { ... })` | Add new node |
| Copy | `baz=C("nodeId", "parent", { ... })` | Duplicate existing node |
| Replace | `foo2=R("nodeId", { ... })` | Swap node content |
| Update | `U("nodeId", { ... })` | Modify properties |
| Delete | `D("nodeId")` | Remove node |
| Move | `M("nodeId", "parent", index)` | Reorder |
| Generate image | `G("nodeId", "ai", "prompt")` | AI image generation |

Limit: 25 operations per `batch_design` call.
