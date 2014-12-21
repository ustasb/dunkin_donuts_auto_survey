# Dunkin' Donuts Auto-Survey

[ustasb.com/freedonut](http://ustasb.com/freedonut)

Completing a Dunkin' Donuts survey at [telldunkin.com](https://www.telldunkin.com/) will earn you a free donut.

This project automatically completes that survey and provides the validation code.

You'll need an actual receipt to obtain the survey code.

## Setup

Install [Phantom JS](http://phantomjs.org/):

    brew install phantomjs # os x

    or

    apt-get install phantomjs # ubuntu

Install the Ruby gems:

    bundle install

Start the [Thin](http://code.macournoyer.com/thin) server:

    ruby server.rb

    or for production:

    SINATRA_ENV=production ruby server.rb
