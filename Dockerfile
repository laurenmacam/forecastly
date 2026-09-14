# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.2.2
FROM ruby:${RUBY_VERSION}-slim

ENV RAILS_ENV=development \
    BUNDLE_PATH=/usr/local/bundle \
    LANG=C.UTF-8 \
    TZ=Etc/UTC

# System packages:
#   build-essential   -> compile native gem extensions
#   libyaml-dev       -> psych (YAML) native build
#   libsqlite3-dev    -> sqlite3 gem native build
#   git, curl         -> tooling some gems shell out to
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libyaml-dev \
      libsqlite3-dev \
      git \
      curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /rails

# Install gems first so this layer is cached until the Gemfile changes.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Copy the app. In development this is overlaid by a bind mount (see
# docker-compose.yml), so live edits on the host are picked up immediately.
COPY . .

EXPOSE 3000

CMD ["sh", "-c", "rm -f tmp/pids/server.pid && bin/rails server -b 0.0.0.0 -p 3000"]