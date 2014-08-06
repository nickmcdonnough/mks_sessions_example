require 'sinatra'
require 'rack-flash'
require_relative 'lib/sesh.rb'

set :sessions, true
use Rack::Flash

get '/' do
  if session['sesh_example']
    @user = Sesh.dbi.get_user_by_username(session['sesh_example'])
  end
  
  erb :index
end

get '/signin' do
  erb :signin
end

get '/signup' do
  if session['sesh_example']
    redirect to '/'
  else
    erb :signup
  end
end

post '/signup' do
  if params['username'].empty? || params['password'].empty? || params['password_conf'].empty?
    flash[:alert] = "Blank inputs!"
    redirect to '/signup'
  end

  if Sesh.dbi.username_exists?(params['username'])
    "USER ALREADY EXISTS. TRY AGAIN"
  elsif params['password'] == params['password_conf']
    user = Sesh::User.new(params['username'])
    user.update_password(params['password'])
    Sesh.dbi.persist_user(user)
    session['sesh_example'] = user.username
    redirect to '/'
  else
    flash[:alert] = "PASSWORDS DONT MATCH YO!"
    redirect to '/signup'
  end
end

post '/signin' do
  if params['username'].empty? || params['password'].empty?
    redirect to '/signin'
  end

  user = Sesh.dbi.get_user_by_username(params['username'])
  if user && user.has_password?(params['password'])
    session['sesh_example'] = user.username
    redirect to '/'
  else
    flash[:alert] = "THERE WAS A PROBLEM!!!!"
    redirect to '/signin'
  end
end

get '/signout' do
  session.clear
  redirect to '/'
end
