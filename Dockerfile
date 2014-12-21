FROM nepalez/ruby
MAINTAINER Brian Ustas <brianustas@gmail.com>

ENV SINATRA_ENV="production"

RUN apt-get -y update && \
    apt-get -y install git phantomjs

RUN git clone https://github.com/ustasb/dunkin_donuts_auto_survey.git /srv/www/dunkin_donuts_auto_survey && \
    rm -rf /srv/www/dunkin_donuts_auto_survey/.git

WORKDIR /srv/www/dunkin_donuts_auto_survey

RUN bundle install

VOLUME /srv/www/dunkin_donuts_auto_survey

EXPOSE 9000

CMD ["ruby", "server.rb"]
