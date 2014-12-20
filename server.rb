# coding: utf-8

require 'sinatra'
require_relative 'save_file'
require_relative 'dd_auto_survey'

set server: 'thin'
set :bind, '0.0.0.0'
set :port, 9000

save_file = SaveFile.new('dd_save_file')
surveys_completed_key = 'surveys_completed'

get '/' do
  send_file 'public/index.html'
end

get '/validation_code/:survey_code', provides: 'text/event-stream' do
  stream :keep_open do |out|
    vcode = DunkinDonuts::AutoSurvey.new(params[:survey_code]) do |status|
      out << "data: #{status}\n\n"
    end.get_validation_code

    save_file.set do |json|
      json[surveys_completed_key] ||= 0
      json[surveys_completed_key] += 1
      json
    end if vcode
  end
end

get '/surveys_completed' do
  (save_file.get(surveys_completed_key) || 0).to_s
end
