# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="0" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# ---------------------------
# Build stage (instala gems)
# ---------------------------
FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/


# ---------------------------
# Final stage (runtime)
# ---------------------------
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client redis-tools && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copia gems e código da app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Cria usuário não-root
RUN useradd rails --create-home --shell /bin/bash

# ✅ Garante que pastas/arquivos críticos existam e tenham permissão
RUN mkdir -p db log tmp storage && \
    touch db/schema.rb log/development.log tmp/local_secret.txt && \
    chown -R rails:rails /rails && \
    chmod -R 777 db log tmp storage && \
    chmod +x bin/rails bin/docker-entrypoint bin/rake bin/bundle bin/setup

USER rails:rails

# Entrypoint prepara DB
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server"]
