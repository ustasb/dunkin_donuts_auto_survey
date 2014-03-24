# Dunkin' Donuts Auto-Survey

[ustasb.com/freedonut](http://ustasb.com/freedonut)

Completing a Dunkin' Donuts survey at [telldunkin.com](1) will earn you a free donut.

This project automatically completes that survey and provides the validation code.

You'll need an actual receipt to obtain the survey code.

## Setup

Install the Ruby gems:

    bundle install

Setup the Thin configuration file:

    sudo thin config -C /etc/thin/dunkin_donuts_auto_survey.yml -c /path/to/dunkin_donuts_auto_survey --address 127.0.0.1 --port 5000 --servers 2 -e production --log /path/to/log/dunkin_donuts_auto_survey/thin.log

Launch the Thin server:

    thin start -C /path/to/dunkin_donuts_auto_survey.yml

[1]: https://www.telldunkin.com/
