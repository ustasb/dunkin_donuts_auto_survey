# coding: utf-8

require 'sinatra'
require_relative 'dd_auto_survey'

set server: 'thin'

get '/' do
  send_file 'public/index.html'
end

get '/validation_code/:survey_code', provides: 'text/event-stream' do
  stream :keep_open do |out|
    DunkinDonuts::AutoSurvey.new(params[:survey_code]) do |status|
      out << "data: #{status}\n\n"
    end.get_validation_code
  end
end
