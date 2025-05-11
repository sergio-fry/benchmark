FROM ghcr.io/graalvm/truffleruby-community:24

EXPOSE 8080
WORKDIR /rails

RUN yum install -y --setopt=install_weak_deps=False \
  redis ruby-devel zlib-devel xz git-core gcc make postgresql-devel

COPY ./Gemfile* /rails/

#ENV BUNDLE_FORCE_RUBY_PLATFORM=true
ENV BUNDLE_WITH=postgresql:puma
RUN bundle install --jobs=8

COPY . /rails/

ENV WEB_CONCURRENCY=0
ENV RAILS_ENV=production_postgresql
ENV PORT=8080
ENV REDIS_URL=redis://localhost:6379/0
CMD redis-server & \
    rails server
