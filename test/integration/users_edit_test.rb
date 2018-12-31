require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  # 編集失敗時テスト
  test "unsuccessful edit" do
    # ログイン
    log_in_as(@user)

    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_template 'users/edit'

    # エラーが４つ表示されることを確認
    assert_select 'div', 'The form contains 4 errors.'
  end

  # 編集成功時テスト
  test "successful edit" do
    # ログイン
    log_in_as(@user)

    # 編集ページ取得
    get edit_user_path(@user)
    assert_template 'users/edit'
    # フォームの値設定、リクエスト送信
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    # フラッシュメッセージが存在しないことを確認
    assert_not flash.empty?
    # ユーザーごとのページに遷移したとこを確認
    assert_redirected_to @user
    # DBからユーザー情報を取得し直し、ローカル変数に設定
    @user.reload
    # 変更されていることを確認
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  # 未ログイン状態でeditページに遷移
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # 未ログイン状態でupdateページに遷移
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # フレンドリフォワーディングのテスト
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)

    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user

    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  # 初回のみフレンドリフォワーディングがされることのテスト
  test "first friendly forwarding" do
    get edit_user_path(@user)
    # この時点では編集画面のURLが保存されている
    assert_equal session[:forwarding_url], edit_user_url(@user)
    # ログイン
    log_in_as(@user)
    # ログイン後は上記で保存していたURLに遷移し、セッションに保存していた値が削除されている
    assert_nil session[:forwarding_url]
    assert_redirected_to edit_user_url(@user)
  end

end