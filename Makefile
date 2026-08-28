# Primary CLI surface for stewg. Each target is a thin wrapper over the
# underlying jekyll command; see CLAUDE.md.
#
# The fleet interface is `make build test run` across every app repo —
# TheShrug/homelab Conventions/Local Dev Interface.md. This repo has no
# `make database`: it is a static site with no database and no R2 dump.

# Assigned in the fleet port table, not defaulted. Overridable, but the number
# is written down so two apps can run at once without colliding.
PORT ?= 8003

.DEFAULT_GOAL := help
.PHONY: help build test run

help: ## Show this help
	@echo "stewg — make targets:"
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-8s %s\n", $$1, $$2}'

build: ## Build the site into _site/
	bundle exec jekyll build

# There is no spec suite here and there does not need to be one — this is a
# Jekyll site with no application code. A strict build IS the test: it fails on
# malformed front matter, which is the defect this repo can actually have.
#
# Said out loud because a repo where `make test` is missing and a repo where
# `make test` is meaningless look identical from outside, and only one of those
# is fine.
test: ## Run the suite: a strict build. Front matter errors fail it — that is the whole test
	bundle exec jekyll build --strict_front_matter

# Backgrounded, then polled, so the URL is the LAST line rather than buried
# above jekyll's startup banner. Ctrl-C reaches jekyll because it stays in this
# process group.
run: ## Serve the site on $(PORT) with livereload; prints the URL last
	@bundle exec jekyll serve --host 0.0.0.0 --port $(PORT) --livereload & \
	 pid=$$!; \
	 trap 'kill $$pid 2>/dev/null' INT TERM; \
	 for _ in $$(seq 1 60); do \
	   if curl -sfo /dev/null "http://localhost:$(PORT)/"; then break; fi; \
	   kill -0 $$pid 2>/dev/null || { echo "jekyll serve exited before it answered" >&2; exit 1; }; \
	   sleep 1; \
	 done; \
	 echo; \
	 echo "  stewg serving on http://localhost:$(PORT)/"; \
	 wait $$pid
