require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get users_new_url
    assert_response :success
  end

  # 間違ったユーザでログインした状態で、ユーザー固有のページを見ようとした場合
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  # 別のユーザー情報をアップデートしようとし場合
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  # ログインしていない場合はログインページに遷移
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  # adminカラムをtrueにするpatchを受け付けないテスト
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
        user: { password:              @other_user.password,
                password_confirmation: @other_user.password,
                admin: true } }
    assert_not @other_user.reload.admin?
  end

  # ログインしていないユーザーが、ユーザーを削除するテスト
  test "should redirect destroy when not logged in" do
    # ユーザーの数に変化がないことを確認
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  # 管理者ではないユーザーが、ユーザーを削除するテスト
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    # ユーザーの数に変化がないことを確認
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
end
