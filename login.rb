require 'rubygems'
require 'bcrypt'
require 'haml'
require 'sinatra'
require "sinatra/reloader"

enable :sessions

userTable = {}

helpers do


  def login?
    if session[:username].nil?
      return false
    else
      return true
    end
  end

  def username
    return session[:username]
  end

end

get "/" do
  haml :index
end

get "/signup" do
  haml :signup
end

post "/signup" do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)

  #ideally this would be saved into a database, hash used just for sample
  userTable[params[:username]] = {
    :salt => password_salt,
    :passwordhash => password_hash
  }

  session[:username] = params[:username]
  redirect "/"
end

post "/login" do
  if userTable.has_key?(params[:username])
    user = userTable[params[:username]]
    if user[:passwordhash] == BCrypt::Engine.hash_secret(params[:password], user[:salt])
      session[:username] = params[:username]
      redirect "/"
    end
  end
  haml :error
end

get "/logout" do
  session[:username] = nil
  redirect "/"
end

__END__
@@layout
!!! 5
%html
  %head
    %title Sinatra Login
  %body
  =yield
@@index
-if login?
  %h1= "Welcome #{username}!"
  %a{:href => "/logout"} Logout
-else
  %form(action="/login" method="post")
    %div
      %label(for="username")名前:
      %input#username(type="text" name="username")
    %div
      %label(for="password")パスワード:
      %input#password(type="password" name="password")
    %div
      %input(type="submit" value="ログイン")
  %p
    %a{:href => "/signup"} 新規登録
@@signup
%form(action="/signup" method="post")
  %div
    %label(for="username")名前:
    %input#username(type="text" name="username")
  %div
    %label(for="password")パスワード:
    %input#password(type="password" name="password")
  %div
    %label(for="checkpassword")パスワードを再入力:
    %input#password(type="password" name="checkpassword")
  %div
    %input(type="submit" value="登録")
@@error
%p 名前かパスワードが間違っています
%p 再入力してください
