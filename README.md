# Dunkin' Donuts Auto-Survey

[ustasb.com/free-donut](http://ustasb.com/free-donut)

Completing a Dunkin' Donuts survey at [telldunkin.com](https://www.telldunkin.com/) will earn you a free donut.

This project automatically completes that survey and provides the validation code.

You'll need an actual receipt to obtain the survey code.

Initial release: 03/24/2014

## Usage

Build the Docker image:

    docker build -t dunkin_donuts_auto_survey .

Run the Sinatra server:

    docker run -p 9000:9000 dunkin_donuts_auto_survey

For a production server, add:

    -e SINATRA_ENV=production
