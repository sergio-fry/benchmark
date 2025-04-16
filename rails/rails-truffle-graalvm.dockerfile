FROM ghcr.io/sergio-fry/truffleruby-jvm

EXPOSE 8080
WORKDIR /rails

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends redis-server

COPY ./Gemfile* /rails/

#ENV BUNDLE_FORCE_RUBY_PLATFORM=true
ENV BUNDLE_WITH=postgresql:puma
RUN bundle install --jobs=8

COPY . /rails/

ENV WEB_CONCURRENCY=0
ENV RAILS_ENV=production_postgresql
ENV PORT=8080
ENV REDIS_URL=redis://localhost:6379/0
CMD service redis-server start && \
    rails server
