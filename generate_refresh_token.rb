# Call this file using `ruby generate_refresh_token.rb`.
require 'rubygems'
require 'oauth2'

redirect_uri = 'https://localhost/oauth2callback'

puts "Make sure #{redirect_uri} is set as a 'Redirect URI' in the Google Developer Console for the project you want to create a token for.\n"

puts "Enter Client ID from Google Console (and hit enter):\n"
client_id = gets.chomp.strip

puts "\nEnter Client Secret from Google Console (and hit enter):\n"
client_secret = gets.chomp.strip

puts "\nEnter scope of the service you want, for example: https://www.googleapis.com/auth/analytics.readonly. A list of scopes is available at https://developers.google.com/identity/protocols/googlescopes\n"
scope = gets.chomp.strip

auth_client_obj = OAuth2::Client.new(client_id, client_secret, site: 'https://accounts.google.com', authorize_url: "/o/oauth2/auth", token_url: "/o/oauth2/token")

puts "\nPaste this URL into your browser\n\n"
puts auth_client_obj.auth_code.authorize_url(scope: scope, access_type: "offline", redirect_uri: redirect_uri, approval_prompt: 'force')

puts "\nAccept the authorization request. Google will then redirect you to localhost, copy the code parameter out of the URL they redirect you to, paste it here and hit enter:\n"
code = gets.chomp.strip

access_token_obj = auth_client_obj.auth_code.get_token(code, redirect_uri: redirect_uri, token_method: :post)

puts "\nToken is: #{access_token_obj.token}"
puts "Refresh token is: #{access_token_obj.refresh_token}"
