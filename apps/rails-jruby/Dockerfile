FROM jruby:9.4.12.0-jdk

# RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN bundle install

COPY . /app

CMD ["rails", "server", "-b", "0.0.0.0"]
