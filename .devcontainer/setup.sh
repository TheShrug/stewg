#!/usr/bin/env bash
# Devcontainer post-create. Idempotent: safe to re-run after a rebuild.
set -euo pipefail

echo "==> bundle install"
# Deliberately NOT vendored into the workspace. This image sets
# BUNDLE_APP_CONFIG=/usr/local/bundle, so `bundle config set --local path` writes
# inside the container rather than next to the Gemfile: the gems land in
# vendor/bundle, the setting that points at them does not survive, and the next
# `bundle exec jekyll` fails with "command not found". Gems go to the image's
# own bundle path instead, and a rebuild re-runs this script.
bundle install --jobs 4 --retry 3

echo
echo "Ready. Run 'make' to see the targets."
