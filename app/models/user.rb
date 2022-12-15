class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :confirmable, :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist,
         authentication_keys: [:username]

  # TODO: do not allow @ in username, automatically lowercase email

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    username = conditions.delete(:username)
    query = where(conditions)

    if username
      query = query.where([
        "username = :value OR email = :value",
        { value: username.downcase }
      ])
    end

    query.first
  end
end
