class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      # セッションにユーザーIDを保存
      log_in @user

      # チェックボックスにチェックが入っている場合は「永続的なセッション情報をDBとCookieへ保存」
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)

      # ユーザーページへ遷移
      # redirect_to @user

      # セッションにフレンドリフォワーディング用の遷移先が保存されている場合そちらにリダイレクト
      # そうでない場合はユーザーページにリダイレクト
      redirect_back_or @user

    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
