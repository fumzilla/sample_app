# By using ':user' symbol, we do than
# Factory Girl simulates a User model

FactoryGirl.define do
  factory :user do |user|
    user.name                   "Romain Michel"
    user.email                  "michemuch@example.com"
    user.password               "foobar"
    user.password_confirmation  "foobar"
  end

  sequence :email do |n|
    "person-#{n}@example.com"
  end

  factory :micropost do |micropost|
    micropost.content "Foo Bar"
    micropost.association :user
  end
end

