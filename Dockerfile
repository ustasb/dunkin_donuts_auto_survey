FROM ruby:2.4.1-alpine3.6
MAINTAINER Brian Ustas <brianustas@gmail.com>

ARG APP_PATH="/opt/dunkin_donuts_auto_survey"

RUN apk add --update build-base curl

# PhantomJS
# Credit: https://github.com/sv0/docker-alpine-phantomjs/blob/master/Dockerfile
ENV PHANTOMJS_ARCHIVE="phantomjs.tar.gz"
RUN curl -Lk -o $PHANTOMJS_ARCHIVE https://github.com/fgrehm/docker-phantomjs2/releases/download/v2.0.0-20150722/dockerized-phantomjs.tar.gz \
	&& tar -xf $PHANTOMJS_ARCHIVE -C /tmp/ \
	&& cp -R /tmp/etc/fonts /etc/ \
	&& cp -R /tmp/lib/* /lib/ \
	&& cp -R /tmp/lib64 / \
	&& cp -R /tmp/usr/lib/* /usr/lib/ \
	&& cp -R /tmp/usr/lib/x86_64-linux-gnu /usr/ \
	&& cp -R /tmp/usr/share/* /usr/share/ \
	&& cp /tmp/usr/local/bin/phantomjs /usr/bin/ \
	&& rm -fr $PHANTOMJS_ARCHIVE  /tmp/*

WORKDIR $APP_PATH

# Add Gemfile and Gemfile.lock first for caching.
ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH
RUN bundle install

COPY . $APP_PATH
VOLUME $APP_PATH
EXPOSE 9000

CMD ["ruby", "src/server.rb"]
