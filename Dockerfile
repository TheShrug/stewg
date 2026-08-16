FROM ruby:3.3-slim AS build

# sass-embedded ships no musl binaries, so the build stage stays on Debian.
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential git && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Copied ahead of the source so content-only changes reuse the bundle layer.
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
 && bundle install --jobs 4 --retry 3

COPY . .
RUN bundle exec jekyll build --trace

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/_site /usr/share/nginx/html
