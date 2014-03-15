# coding: utf-8
require 'sinatra'
set server: 'thin', connections: []

get '/' do
  send_file 'public/index.html'
end

get '/validationcode/:survey_code', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    out.callback { settings.connections.delete(out) }
  end
end

post '/' do
  settings.connections.each { |out| out << "data: #{params[:msg]}\n\n" }
  204 # response without entity body
end
