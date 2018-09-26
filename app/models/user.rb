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
end
