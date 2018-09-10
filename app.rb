require 'bundler/setup'
require 'sinatra'
require 'oauth2'
require 'json'
require "net/http"
require "uri"

set :port, 4567
set :static, true
set :public_folder, "static"
set :view, "views"

# Our client ID and secret, used to get the access token
CLIENT_ID = '0221ea6b-71da-47d0-bc54-0ec2d2b70c02' 
CLIENT_SECRET = 'd2edef94-8539-43bb-9a0f-8ed2e3374bf7'

use Rack::Session::Pool, :session_only => false

redirect_uri = 'http://localhost:4567/oauth/callback'
endpoints_uri = 'https://graph.api.smartthings.com/api/smartapps/endpoints'
options = {
    site: 'https://graph.api.smartthings.com/api/smartapps/endpoints',
    authhorize_url: '/oauth/authorize',
    token_url: '/oauth/token'
}
client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, options)

#web pages
get '/' do
    erb :hello_form
end

post '/submit' do
    token = params[:token] || "NONE"

    url = URI.parse(endpoints_uri)
    req = Net::HTTP::Get.new(url.request_uri)

    req['Authorization'] = 'Bearer ' + token

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")

    response = http.request(req)
    json = JSON.parse(response.body)

    puts json
    uri = json[0]['uri']

    pin = params[:pin] || "None"
    puts 'Unlock the lock with pin code'
    lockUrl = uri + '/code/' + pin
    getlockURL = URI.parse(lockUrl)
    getlockReq = Net::HTTP::Put.new(getlockURL.request_uri)
    getlockReq['Authorization'] = 'Bearer ' + token
    getlockHttp = Net::HTTP.new(getlockURL.host, getlockURL.port)
    getlockHttp.use_ssl = true
    lockStatus = getlockHttp.request(getlockReq)

    '<h3>Successfully set the pin code</h3>' + %(<a href="/">Back to home</a>)
end


post '/unlock' do
    token = params[:token] || "NONE"

    url = URI.parse(endpoints_uri)
    req = Net::HTTP::Get.new(url.request_uri)

    req['Authorization'] = 'Bearer ' + token

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")

    response = http.request(req)
    json = JSON.parse(response.body)

    puts json
    uri = json[0]['uri']

    puts 'Unlock the door'
    
    lockUrl = uri + '/switches/unlock'
    getlockURL = URI.parse(lockUrl)
    getlockReq = Net::HTTP::Put.new(getlockURL.request_uri)
    getlockReq['Authorization'] = 'Bearer ' + token
    getlockHttp = Net::HTTP.new(getlockURL.host, getlockURL.port)
    getlockHttp.use_ssl = true
    
    lockStatus = getlockHttp.request(getlockReq)

    '<h3>Successfully unlock the door </h3>' + %(<a href="/">Back to home</a>)

end

post '/lock' do
    token = params[:token] || "NONE"

    url = URI.parse(endpoints_uri)
    req = Net::HTTP::Get.new(url.request_uri)

    req['Authorization'] = 'Bearer ' + token

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")

    response = http.request(req)
    json = JSON.parse(response.body)

    puts json
    uri = json[0]['uri']

    puts 'Unlock the door'
    
    lockUrl = uri + '/switches/lock'
    getlockURL = URI.parse(lockUrl)
    getlockReq = Net::HTTP::Put.new(getlockURL.request_uri)
    getlockReq['Authorization'] = 'Bearer ' + token
    getlockHttp = Net::HTTP.new(getlockURL.host, getlockURL.port)
    getlockHttp.use_ssl = true
    
    lockStatus = getlockHttp.request(getlockReq)

    '<h3>Successfully lock the door </h3>' + %(<a href="/">Back to home</a>)
end



