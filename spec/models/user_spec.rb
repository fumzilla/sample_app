# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = { :name => "Exemple User", :email => "user@example.com" }
  end

  it "should create a new user instance with valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    bad_guy = User.new(@attr.merge(:name => ""))
    bad_guy.should_not be_valid
  end

  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject too long name" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name ))
    long_name_user.should_not be_valid
  end

  it "should accept a valid email" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject an invalid email" do
    addresses = %w[user@foo,com user_at_foo.org example.last@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject a duped email" do
    # Create a new user with an email in DB
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject a duped email without case sensibility" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

end
