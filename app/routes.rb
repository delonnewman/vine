require 'sinatra'
require_relative '../lib/vine'

module Helpers
  def production?
    ENV['APP_ENV'] == 'production'
  end
  
  def url_scheme
    return 'https' if production?

    'http'
  end

  def port
    return '' if production?

    ":#{request.env['SERVER_PORT']}"
  end

  def root_url
    @root_url ||= "#{url_scheme}://#{request.env['SERVER_NAME']}#{port}"
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
