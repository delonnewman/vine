require 'sinatra'
require_relative '../lib/vine'

module Helpers
  def production?
    ENV['RACK_ENV'] == 'production'
  end

  def request_url
    URI(request.url)
  end

  def root_url
    uri = request_url
    "#{uri.scheme}://#{uri.host}:#{uri.port}"
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
