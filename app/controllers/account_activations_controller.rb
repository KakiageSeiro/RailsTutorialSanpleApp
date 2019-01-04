class AccountActivationsController < ApplicationController
  attr_accessor :remember_token, :activation_token
  before_save   :downcase_email
  before_create :create_activation_digest





  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    # self.email = email.downcase
    email.downcase!
  end

  def create_activation_digest
    # 有効化トークンとダイジェストを作成および代入する
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
