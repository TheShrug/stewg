# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Work queue

Work lives in this repo's **GitHub Issues**, one issue per item, with exactly one
`type:` label — `feat` (epic), `tckt` (atomic unit of work), `bug`, `chore`,
`spike` (time-boxed investigation whose output is knowledge).

## Branches

Every branch:

```
TheShrug/<issue>-<type>-<slug>
```

```
^TheShrug/[0-9]+-(tckt|feat|bug|chore|spike)-[a-z0-9]+(-[a-z0-9]+)*$
```

- `<issue>` is the **issue number in this repo** — not a PR number. A PR number
  doesn't exist yet when the branch is cut, and renaming a branch after opening
  the PR detaches it.
- `<type>` matches the issue's `type:` label.
- `<slug>` is lowercase `a-z0-9-`; `.` and `_` collapse to `-` (`stewg.dev` →
  `stewg-dev`); aim for ≤ 40 characters. The issue holds the full title.

For example, an issue #12 labelled `type: tckt` titled "Fix the footer year"
becomes `TheShrug/12-tckt-fix-footer-year`.

**No issue, no branch.** The number is mandatory, so every branch traces back to
a queue item. Cut branches from `master`.

Existing branches predating this rule are grandfathered — never rename a branch
that already has an open PR.

The full policy and the reasoning behind it live in the `homelab` vault at
`Conventions/Branching.md`. It's restated here rather than linked because that
vault is private and this repo is public.
