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

get '/api/statistics' do
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

  # Remove blank rows
  rows = data['values'].reject { |row| row.length == 0 }

  # If there isn't a group to start with then we can't do anything
  return {} unless rows[0].length == 1

  @stats = []
  rows.each do |row|
    # Rows with a single value denote a new group of stats
    if row.length == 1
      # If there's an existing group of stats, push it to the main array
      if defined?(@stats_group)
        add_stats_to_array
      end

      @stats_group_name = row[0]
      @stats_group = {}
    else
      @stats_group[row[0]] = row[1]
    end
  end

  # Push last group of stats to a separate array
  total_stats = @stats_group

  JSON.generate({
    stats: @stats,
    totals: total_stats
  })
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

def add_stats_to_array
  @stats << {
    group_name: @stats_group_name,
    stats: @stats_group
  }
end
