require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  # ログイン画面でエラー発生させ
  # フラッシュメッセージ表示後
  # 別画面へ遷移しログイン画面へ戻ってきたときに
  # フラッシュメッセージが消えていることを検証
  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    # フラッシュメッセージは別画面に遷移し、戻ってきたときに消えているべき
    assert flash.empty?
  end

  # ログイン画面でsetupで作成したユーザのメールアドレスとパスワードを入力し
  # ユーザーページへ遷移することを確認
  test "login with valid information" do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }

    # リダイレクト先が正しいかどうかをチェック
    assert_redirected_to @user
    # リダイレクト実行
    follow_redirect!
    assert_template 'users/show'

    # ログイン用のリンクがなくなったことをチェック
    assert_select "a[href=?]", login_path, count: 0
    # ログアウト用のリンクが存在することをチェック
    assert_select "a[href=?]", logout_path
    # ユーザーページへのリンクが存在することをチェック
    assert_select "a[href=?]", user_path(@user)
  end

  # ログアウトの検証
  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    # ログアウト実行
    delete logout_path
    # ユーザーがログインしていないことをチェック
    assert_not is_logged_in?
    # リダイレクト先（ルートページ）が正しいかどうかをチェック
    assert_redirected_to root_url


    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path

    # リダイレクト実行
    follow_redirect!

    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  # ログインユーザーをブラウザに記憶するテスト
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    # cookieが作成されていることを確認
    # assert_not_empty cookies['remember_token']

    # cookieのトークンとセッションコントローラで扱うuserのトークンが同一であることを確認
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end


  # ログインユーザーをブラウザに記憶しないテスト
  test "login without remembering" do
    # クッキーを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # クッキーを削除してログイン
    log_in_as(@user, remember_me: '0')
    # cookieが作成されていないことを確認
    assert_empty cookies['remember_token']
  end
end
