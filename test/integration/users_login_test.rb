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
    # リダイレクト実行
    follow_redirect!

    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

end
