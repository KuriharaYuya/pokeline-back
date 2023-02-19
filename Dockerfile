FROM ruby:3.1.2
RUN apt-get update && apt-get install -y nodejs npm graphviz

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle
COPY . .
