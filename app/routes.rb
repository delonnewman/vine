require 'sinatra'

require_relative '../lib/vine'

helpers do
  include Vine::Core
end

get '/?' do
  erb :form
end

post '/' do
  content_type 'application/pdf'

  card_sheet(params)
end
