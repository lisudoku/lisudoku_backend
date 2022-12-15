FactoryBot.define do
  factory :user do
    username { 'normaluser' }
    email  { 'user@email.com' }
    password { 'password' }
    admin { false }
    confirmed_at { DateTime.now }
  end
end
