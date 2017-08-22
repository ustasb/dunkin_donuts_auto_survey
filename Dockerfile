FROM ruby:2.4.1-alpine3.6
MAINTAINER Brian Ustas <brianustas@gmail.com>

ARG APP_PATH="/opt/dunkin_donuts_auto_survey"

RUN apk add --update build-base

# PhantomJS
# Credit: https://github.com/Overbryd/docker-phantomjs-alpine/releases/tag/2.11
RUN apk update && apk add --no-cache fontconfig curl && \
  mkdir -p /usr/share && \
  cd /usr/share \
  && curl -L https://github.com/Overbryd/docker-phantomjs-alpine/releases/download/2.11/phantomjs-alpine-x86_64.tar.bz2 | tar xj \
  && ln -s /usr/share/phantomjs/phantomjs /usr/bin/phantomjs \
  && phantomjs --version

WORKDIR $APP_PATH

# Add Gemfile and Gemfile.lock first for caching.
ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH
RUN bundle install

COPY . $APP_PATH
VOLUME $APP_PATH
EXPOSE 9000

CMD ["ruby", "src/server.rb"]
