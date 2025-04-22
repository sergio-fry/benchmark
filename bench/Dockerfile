FROM ruby:3.4

RUN apt-get update && \
    apt-get install -y --no-install-recommends apache2-utils 

WORKDIR /app
COPY . /app/

#ENTRYPOINT [ "ruby", "benchmark.rb" ]
