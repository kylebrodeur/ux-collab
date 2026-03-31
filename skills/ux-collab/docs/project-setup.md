# Project Setup — `.ux-collab.md`

The `ux-collab` skill is project-agnostic. Drop a `.ux-collab.md` file at your **project root** to configure it for your specific app. The skill reads this file at the start of every session.

## Format

````markdown
# UX Collab — Project Config

## Settings

- **defaultUrl**: http://localhost:3000       ← dev server URL to navigate to at session start
- **decisionsDoc**: docs/DESIGN_DECISIONS.md  ← where resolved decisions are recorded
- **lucidShareEmail**: you@example.com        ← email for Lucid diagram share links

## Target Files

Files the agent should edit during the BUILD step:

- `app/v2/_components/`    — V2 UI components
- `app/v2/page.tsx`        — V2 route shell
- `app/globals.css`        — design token layer
- `tailwind.config.ts`     — token wiring
- `lib/`                   — non-UI business logic

## Brand Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `--brand-navy` | `#0D1B2A` | Primary background, headings |
| `--brand-gold` | `#F5A623` | Accent, CTAs |
| `--brand-blue` | `#1A73E8` | Interactive elements, links |
| `--brand-slate` | `#6B7A8D` | Secondary text |
| `--radius` | `0px` | Square-first; apply radius explicitly |

Verify against `app/globals.css` — these are the canonical values.

## Surface Map

| Surface | Route | Status | Notes |
|---------|-------|--------|-------|
| Shell / navigation | `/v2` | Active | No header yet |
| Product Browser | `/v2?tab=browse` | Placeholder | Format TBD |
| AI Literacy Survey | `/v2?tab=survey` | Functional | Minimal styling |
| Results | Post-survey | Exists, not visible | Needs routing |

## Open Design Decisions

1. **Product browser format** — Grid / tiered list / journey path
2. **Survey UX pattern** — All-at-once vs. stepped/progressive
3. **Shell header** — Does `/v2` need a nav header?
4. **Lead capture gate** — Before / after results / soft ask

## Code Rules

- All colors via brand tokens only — no inline hex
- Square-first radius (`--radius: 0px` base)
- shadcn/ui as component base — extend, don't replace
- No new dependencies without explicit discussion
````

## Minimal Example

If you just want to set the dev URL and email:

````markdown
# UX Collab — Project Config

## Settings

- **defaultUrl**: http://localhost:3000
- **lucidShareEmail**: you@example.com
````

## Full Field Reference

| Field | Location | Default | Description |
|-------|----------|---------|-------------|
| `defaultUrl` | Settings | `http://localhost:3000` | URL to navigate to at session start |
| `decisionsDoc` | Settings | `docs/DESIGN_DECISIONS.md` | Path to decisions log |
| `lucidShareEmail` | Settings | *(ask user)* | Email for Lucid share links |
| Target Files | Target Files section | *(auto-discover)* | Files the BUILD step is allowed to edit |
| Brand Tokens | Brand Tokens table | *(none)* | Token name/value/usage for labels and code |
| Surface Map | Surface Map table | *(none)* | Routes and status for session scoping |
| Open Design Decisions | Open Decisions list | *(none)* | Unresolved decisions to surface in DISCUSS |
| Code Rules | Code Rules section | *(none)* | Project-specific constraints for BUILD |

## Tips

- **Keep it short** — only include what the agent actually needs
- **Brand tokens** — pull exact values from your CSS file when setting these up
- **Open decisions** — move entries to your decisions doc (`decisionsDoc`) once resolved; remove from here
- **Surface map** — update status as work progresses so the agent has accurate context
