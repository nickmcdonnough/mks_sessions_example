require 'sinatra'
require 'rack-flash'

class MKS::Server < Sinatra::Application

  configure do
    set :sessions, true
    use Rack::Flash
  end

  get '/' do
    if session['mks_session_example'] # if the key 'mks_session_example' exists in session
      user_session = MKS::Session.find_by(session_id: session['mks_session_example'])
      @user = user_session.user
    end
  
    erb :index
  end
  
  get '/signin' do
    erb :signin
  end
  
  get '/signup' do
    if session['mks_session_example']
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
  
    if MKS::User.find_by(username: params['username'])
      "USER ALREADY EXISTS. TRY AGAIN"
    elsif params['password'] == params['password_conf']
      user = MKS::User.new
      user.username = params['username']
      user.update_password params['password']
      user.save

      user_session = user.sessions.new
      user_session.generate_id
      user_session.save

      session['mks_session_example'] = user_session.session_id
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
  
    user = MKS::User.find_by(username: params['username'])
  
    if user && user.has_password?(params['password'])
      user_session = user.sessions.new
      user_session.generate_id
      user_session.save

      session['mks_session_example'] = user_session.session_id
      redirect to '/'
    else
      flash[:alert] = "THERE WAS A PROBLEM!!!!"
      redirect to '/signin'
    end
  end
  
  get '/signout' do
    sesh = MKS::Session.find_by(session_id: session['mks_session_example'])
    sesh.destroy
    session.clear
    redirect to '/'
  end

end
