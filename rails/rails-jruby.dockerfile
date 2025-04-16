FROM jruby:9.4-jdk21

EXPOSE 8080
WORKDIR /rails

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends redis-server

# Use Jemalloc
RUN apt-get update && \
    apt-get install -y --no-install-recommends libjemalloc2
ENV LD_PRELOAD=libjemalloc.so.2


COPY ./Gemfile* /rails/

#ENV BUNDLE_FORCE_RUBY_PLATFORM=true
ENV BUNDLE_WITH=postgresql:puma
RUN bundle install --jobs=8

COPY . /rails/

ENV WEB_CONCURRENCY=1
ENV RAILS_ENV=production_postgresql
ENV PORT=8080
ENV REDIS_URL=redis://localhost:6379/0
CMD config/java_tune.sh
CMD service redis-server start && \
    rails server
