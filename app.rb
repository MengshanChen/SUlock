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
CLIENT_ID = '96599e82-0aca-4211-80d6-8a8b4f52d20f' 
CLIENT_SECRET = '6fff357b-9e70-490a-a6af-61d3517c75e6'

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

    slot = params[:slot] || "NONE"
    pin = params[:pin] || "NONE"
    payload = slot + '-' + pin
    
    puts 'Unlock the lock with pin code'
    lockUrl = uri + '/code/' + payload  
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

post '/list' do
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

    puts 'list pin code'
    doorUrl = uri + '/keys'
    getdoorURL = URI.parse(doorUrl)
    getdoorReq = URI.parse(doorUrl)
    getdoorReq = Net::HTTP::Get.new(getdoorURL.request_uri)
    getdoorReq['Authorization'] = 'Bearer' + token
    getdoorHttp = Net::HTTP.new(getdoorURL.host,getdoorURL.port)
    getdoorHttp.use_ssl = true
    
    doorStatus = getdoorHttp.request(getdoorReq)

    '<h3> Pincodes: </h3>' + doorStatus.body + %(<p><a href="/">Back to home</a></p>) 
end

