# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

Personal site — a Jekyll static site (`_config.yml`, `_layouts/`, `_includes/`, `_sass/`,
`_posts/`, `_projects/`) built to `_site/` and served by nginx from the container.

## Local dev interface

`make` is the interface, and it lives **inside the devcontainer** — Ruby, Jekyll and `make`
itself are none of them on the Windows host. Open the repo in the devcontainer
(`.devcontainer/`), which runs `bundle install` on create, then:

| | |
| --- | --- |
| `make` | List the targets. `.DEFAULT_GOAL := help` |
| `make build` | `jekyll build` into `_site/` |
| `make test` | `jekyll build --strict_front_matter` |
| `make run` | `jekyll serve` with livereload on **8003**, printing the URL as the last line |

There is no `make database` here: static site, no database, nothing in the nightly R2 dump.

**Port 8003 is assigned, not defaulted.** Every app in the fleet has a fixed port so two can run
at once; override with `PORT=` if you must, but the number is written down on purpose. The
fleet-wide table and reasoning live in the `homelab` vault at
`Conventions/Local Dev Interface.md` — restated here because that vault is private and this repo
is public.

### When `make` is not on PATH

`make` lives in the devcontainer image (`mcr.microsoft.com/devcontainers/ruby:3.3`, which ships it
— that is why the image was chosen), and never on the Windows host: Git Bash and PowerShell have
neither `make` nor Ruby. So a missing `make` means you are in the wrong place. **That is a location
error, not a tooling gap** — don't run `bundle`/`jekyll` "directly" instead, and don't reconstruct
a target's recipe by hand. Get into the container:

- **Devcontainer already up?** Find it with `docker ps`, then
  `docker exec -w /workspaces/stewg <container> make test`.
- **Nothing running?** A throwaway container over the same image works from Git Bash — verified
  2026-08-30 for bare `make`:

  ```sh
  MSYS_NO_PATHCONV=1 docker run --rm \
    -v "/$PWD://workspaces/stewg" -w //workspaces/stewg \
    mcr.microsoft.com/devcontainers/ruby:3.3 make
  ```

  The leading `/` on `$PWD` and the doubled slashes are Git Bash path-mangling protection, not
  typos. `build` and `test` need the gems, which a throwaway container does not have, so chain
  them: `... ruby:3.3 sh -c 'bundle install && make test'`.
- **Otherwise say the devcontainer isn't available and stop.** A `jekyll build` faked some other
  way is not the gate `make test` is, and this repo's only gate is that build.

## Work queue

Work lives in this repo's **GitHub Issues**, one issue per item, with exactly one `type:` label
— `feat` (epic), `tckt` (atomic unit of work), `bug`, `chore`, `spike` (time-boxed
investigation whose output is knowledge). Status is the issue's own state: open with no
`status:` label is queued, `status: active` / `status: blocked` say the rest, `done` is closed as
*completed*, `dropped` is closed as *not planned*. The body is `## Goal` /
`## Acceptance criteria` / `## Notes`, scaffolded by `.github/ISSUE_TEMPLATE/ticket.yml`.

## Branches and pull requests

Two levels:

- **`master` is production *and* the integration branch**, and the base for everything. Nothing
  is committed to it directly — `.github/workflows/deploy.yml` runs on every push to `master`,
  so merging the PR *is* the release. (Markdown- and docs-only commits are `paths-ignore`d and
  do not trigger a rebuild.)
- **A working branch per issue**, cut from `master` and merged back through a pull request.
  `.github/workflows/ci.yml` runs `jekyll build` on every non-`master` branch and PR, so the PR
  is where a broken build gets caught before it can reach the live site.

There is deliberately **no spec suite** — this is a static site, so the meaningful gate is "does
it still build", which catches bad front matter, a missing include, a Liquid syntax error, a
broken layout reference. That gate is `make test`, which is `jekyll build --strict_front_matter`
and nothing more. Said explicitly because a repo where `make test` is missing and a repo where
`make test` is meaningless look identical from outside, and only one of those is fine. That build is the entire distance between a merge and production, so a
PR is the only review point there is.

Name the branch:

```
TheShrug/<issue>-<type>-<slug>
```

```
^TheShrug/[0-9]+-(tckt|feat|bug|chore|spike)-[a-z0-9]+(-[a-z0-9]+)*$
```

- `<issue>` is the **issue number in this repo** — not a PR number. A PR number doesn't exist
  yet when the branch is cut, and renaming a branch after opening the PR detaches it from its
  head.
- `<type>` matches the issue's one `type:` label.
- `<slug>` is lowercase `a-z0-9-`; `.` and `_` collapse to `-` (`stewg.dev` → `stewg-dev`); aim
  for ≤ 40 characters. The issue holds the full title, so this is a handle, not a summary.

So issue #12 `type: tckt` "Fix the footer year" becomes `TheShrug/12-tckt-fix-footer-year`.

**No issue, no branch** — the number is mandatory, so every branch traces back to the queue.
This replaces the old `chore/<slug>` / `feat/<slug>` convention and, deliberately, the "or
whatever an agent's worktree already gave you" escape hatch: a tool that names a branch from a
task description is a branch that has lost its link to the queue.

Branches are grandfathered **by date, not by a list** — the policy was adopted 2026-08-16, and a
branch whose last commit predates that could not have complied. Never rename a branch that
already has an open PR. **Reference the issue number in the PR title too**, so the two link up
even for grandfathered branches.

**Cut from `origin/master`, and fetch first.** A branch cut from a stale local `master` starts
life missing merged work and will conflict with it later. The stale base also lies to you at
close-out: `git branch -d` compares against whatever `master` currently is, so a genuinely
merged branch refuses to delete and looks unmerged. Fast-forward the base rather than reaching
for `-D`, which skips the check entirely and would delete an unmerged branch just as happily:

```sh
git checkout master && git merge --ff-only origin/master
git branch -d <branch>          # now succeeds, and still checks
```

That bit this repo on 2026-08-22.

The fleet-wide policy and its reasoning live in the `homelab` vault at
`Conventions/Branching.md`. It's restated here rather than linked because that vault is private
and this repo is public.
