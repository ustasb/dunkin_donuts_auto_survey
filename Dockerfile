FROM ruby:2.4.1-alpine3.6
MAINTAINER Brian Ustas <brianustas@gmail.com>

ARG APP_PATH="/srv/www/dunkin_donuts_auto_survey"
ENV SINATRA_ENV="production"

RUN apk add --update build-base

# PhantomJS
# Credit: https://github.com/Overbryd/docker-phantomjs-alpine/releases/tag/2.11
RUN apk update && apk add --no-cache fontconfig curl && \
  mkdir -p /usr/share && \
  cd /usr/share \
  && curl -L https://github.com/Overbryd/docker-phantomjs-alpine/releases/download/2.11/phantomjs-alpine-x86_64.tar.bz2 | tar xj \
  && ln -s /usr/share/phantomjs/phantomjs /usr/bin/phantomjs \
  && phantomjs --version

COPY . $APP_PATH
WORKDIR $APP_PATH

RUN bundle install

VOLUME $APP_PATH
EXPOSE 9000

CMD ["ruby", "src/server.rb"]
