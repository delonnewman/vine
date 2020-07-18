require 'sinatra'
require_relative '../lib/vine'

module Helpers
  def root_url
    @root_url ||= "#{request.env['rack.url_scheme']}://#{request.env['SERVER_NAME']}:#{request.env['SERVER_PORT']}"
  end

  def url
    @url ||= URI.decode(params[:url]) if params[:url]
  end
end

helpers do
  include Helpers
  include Vine::Core
end

get '/?' do
  erb :form
end

post '/' do
  content_type 'application/pdf'

  card_sheet(params)
end
