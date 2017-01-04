require 'rubygems'
require 'sinatra'
require 'json'
require 'rack-cache'
require 'net/http'
require 'net/https'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'

use Rack::Cache
set :bind, '0.0.0.0'
set :protection, except: :frame_options

if ENV['USERNAME'] && ENV['PASSWORD']
  use Rack::Auth::Basic, 'Tagathon Display Screen' do |user, pass|
    user == ENV['USERNAME'] && pass == ENV['PASSWORD']
  end
end

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/realtime' do
  cache_control :public, max_age: 20
  content_type :json

  return {} unless ENV['SPREADSHEET_ID'] && ENV['SPREADSHEET_RANGE']

  query = { access_token: get_token }.merge(params)
  uri = "/v4/spreadsheets/#{ENV['SPREADSHEET_ID']}/values/#{CGI.escape(ENV['SPREADSHEET_RANGE'])}?#{query.to_param}"

  http = Net::HTTP.new('sheets.googleapis.com', 443)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri)
  response = http.request(req)
  data = JSON.parse(response.body)
  # Remove stats that don't have a name
  stats = data['values'].reject { |stat| stat.length != 2 }
  JSON.generate(stats.to_h)
end

def get_token
  if @token.nil? || @token_timeout < Time.now
    params = {
      'client_id' => ENV['CLIENT_ID'],
      'client_secret' => ENV['CLIENT_SECRET'],
      'refresh_token' => ENV['REFRESH_TOKEN'],
      'grant_type' => 'refresh_token'
    }

    http = Net::HTTP.new('accounts.google.com', 443)
    http.use_ssl = true
    req = Net::HTTP::Post.new('/o/oauth2/token')
    req.form_data = params
    response = http.request(req)
    data = JSON.parse(response.body)
    @token_timeout = Time.now + data['expires_in']
    @token = data['access_token']
  end

  @token
end
