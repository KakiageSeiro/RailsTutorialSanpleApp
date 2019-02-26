class User < ApplicationRecord
  #
  # # cookieの保存場所
  # attr_accessor :remember_token
  #
  # # コールバック関数。DBにコミット前？でブロック引数を実行
  # before_save {email.downcase!}

  attr_accessor :remember_token, :activation_token
  before_save   :downcase_email
  before_create :create_activation_digest

  # バリデーション。必須チェックと長さチェック
  validates :name,
            presence: true,
            length: {maximum: 50}

  # バリデーション。必須チェックと長さチェックと正規表現と一意制約（大文字小文字を区別しない）
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  # パスワードのハッシュ化
  has_secure_password

  # バリデーション。パスワードの最小文字数
  validates :password,
            presence: true,
            length: {minimum: 6},
            allow_nil: true

  # 渡された文字列のハッシュ値を返す
  # railsの中のアルゴリズムをパクってきた
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    # トークン生成
    self.remember_token = User.new_token
    # トークン文字列のハッシュを生成し、カラム「remember_digest」を更新
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    if remember_digest.nil?
      false
    else
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # メールアドレスをすべて小文字にする
  def downcase_email
    # self.email = email.downcase
    email.downcase!
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end