class User < ApplicationRecord
  # コールバック関数。DBにコミット前？でブロック引数を実行
  before_save { email.downcase! }

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
            uniqueness: { case_sensitive: false }

  # パスワードのハッシュ化
  has_secure_password

  # バリデーション。パスワードの最小文字数
  validates :password, presence: true, length: { minimum: 6 }

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
