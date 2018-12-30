require 'sinatra'
require 'sinatra/reloader' if development?
require 'termux_ruby_api'
require 'active_support/all'
require 'securerandom'

enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

before do
  puts(session)
  authenticate!
end

get '/sign_in' do
  haml :sign_in
end

post '/sign_in' do
  res = api.json_api_command('fingerprint')
  puts(res)
  if res && res[:auth_result] == 'AUTH_RESULT_SUCCESS'
    puts("Success!!!")
    session[:authenticated] = true
    redirect('/')
  else
    redirect('/sign_in')
  end
end

get '/sign_out' do
  session[:authenticated] = false
  redirect('/sign_in')
end

get '/' do
  haml :index
end

get '/call_log' do
  @call_log = api.call_log.log
  haml :call_log
end

get '/speak' do
  haml :speak
end

post '/speak' do
  if params['speak_text'].present?
    api.tts.speak(params['speak_text'])
  end
  redirect "/speak"
end

def authenticate!
  if request.path_info != '/sign_in' && !session[:authenticated]
    redirect '/sign_in'
  end
end

def link_to(label, *options)
  "<a href=\"#{url(*options)}\">#{label}</a>"
end

def api
  @api ||= TermuxRubyApi::Base.new
end
