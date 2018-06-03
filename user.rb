require 'rubygems'
require 'bcrypt'
require 'sinatra'
require 'sinatra/reloader'
require 'active_record'

#モデル
class User < ActiveRecord::Base
  has_secure_password
 validates :userid,  presence: true
 validates :name,  presence: true
 validates :email, presence: true
 validates :password, presence: true, length: { minimum: 6 }

 def password
   @password ||= BCrypt::Password.new(password)
 end

 def password=(new_password_plaintext)
   @password = BCrypt::Password.create(new_password_plaintext)
   self.password = @password.to_s
 end

 def authenticate(password_plaintext)
   return self.password == password_plaintext
 end
end

enable :sessions

userTable = {}
#ヘルパーメソッド
helpers do

  def login?
    if session[:userid].nil?
      return false
    else
      return true
    end
  end

  def log_in(user)
    session[:user_id] = user.id
  end

end

#コントローラー、ルーティング
#ユーザー一覧
get "/" do
  erb :index
end

#アカウント登録
get '/users/new' do
  if session[:user_id]
    @user = User.find(session[:user_id])
    redirect "/users/#{@user.id}"
  else
    erb :register
  end
end

post '/users/new' do
  　@user = User.new(userid: params[:userid], name: params[:name], email: params[:email])
    @user.password = params[:password_plaintext]
    if @user.save
      session[:user_id] = @user.id
      redirect '/'
    else
      @errors = @user.errors.full_messages
      erb :register
    end
  end

  get '/users/:user_id' do
    @logged_in_as = User.find(session[:user_id]) if session[:user_id]
    @viewing_user = User.find(params[:user_id])

    if @logged_in_as && @logged_in_as.id == @viewing_user.id
      erb :user
    else
      erb :not_authorized
    end
  end

#ログイン
get '/sessions/new' do
  if session[:user_id]
    @user = User.find(session[:user_id])
    redirect "/users/#{@user.id}"
  else
    erb :login
  end
end

post '/sessions/new' do
  @user = User.find_by_email(params[:email])
  if @user && @user.authenticate(params[:password_plaintext])
    session[:user_id] = @user.id
    redirect "/users/#{@user.id}"
  else
    session.delete(:user_id)
        @error = "ユーザーIDかパスワードが間違っています"
            erb :login
          end
        end

#ログアウト
        get '/logout' do
          session.delete(:user_id)
          redirect '/'
        end

#view
__END__
@@layout
<!DOCTYPE html>
<html lang="ja">
<head>
  <link rel="stylesheet" href="/css/normalize.css?app=skills">
  <link rel="stylesheet" href="/css/application.css?app=skills">

  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
  <script src="/js/application.js?app=skills"></script>

  <title></title>
</head>
<nav>
  <center><br><a href="/">Home</a> | <a href="/users/new">新規登録</a> | <a href="/sessions/new">ログイン</a>  </center>
</nav>
<body>
  <%= yield %>
</body>
</html>


@@index
<h1>ユーザー一覧</h1>
      <div class="profile_list">
  <div class="container">
    <div class="table-responsive">
      <table class="table table-bordered">
        <tbody>
          <tr>
            <td>名前:</td>
            <td><%= @user.name %></td>
          </tr>
          <tr>
            <td>メールアドレス:</td>
            <td><%= @user.email %></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</div>

@@login
<h1>ログイン</h1>

<% if @error %>
      <span>Login failed:</span>
<% end %>

<form action="/sessions/new" method="POST">
    <div>
    <label for="userid">ユーザーID</label>
    <input id="userid" name="ユーザーID" type="text" required="">
    </div>
    <div>
    <label for="password_plaintext">パスワード</label>
    <input id="password_plaintext" name="パスワード" type="password" required="">
</div>
    <button id="login" name="送信" type="email" >送信</button>
</form>

@@register
<h1>新規登録</h1>
<form action="/users/new" method="POST">
<div>
<label for="userid">ユーザーID</label>
  <input id="userid" name="ユーザーID" type="text" required="">
</div>
  <div>
  <label for="name">名前</label>
    <input id="name" name="名前" type="text" required="">
</div>
<div>
<label for="email">メールアドレス</label>
<input id="email" name="メールアドレス" type="email" required="">
</div>
<div>
<label for="password_plaintext">パスワード</label>
<input id="password_plaintext" name="パスワード" type="password" required="">
</div>
<div>
 <button id="register" name="登録">送信</button>
</div>
