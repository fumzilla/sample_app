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
    @attr = {
        :name => "Exemple User", 
        :email => "user@example.com", 
        :password => "foobar",
        :password_confirmation => "foobar"
    }
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

  describe "password validation" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => ""))
        should_not be_valid
    end

    it "should require a password confirmation that corresponds" do
      User.new(@attr.merge(:password_confirmation => "invalid"))
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "Password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? Method" do

      it "should return true if passwords are matching" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should return false is passwords are different" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "Authenticate method" do

      it "should return nil if email/password combination is wrong" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil when an email doesn't match any users" do
        nonexistant_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistant_user.should be_nil
      end

      it "should return user if email/password combination matches" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "Admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should confirm admin is avalaible" do
      @user.should respond_to(:admin)
    end

    it "shouldn't be admin by default" do
      @user.should_not be_admin
    end

    it "could become and admin" do
        @user.toggle!(:admin)
        @user.should be_admin
    end
  end

  describe "micropost association" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a `microposts` attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have microposts in good order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "should  destroy micro-messages associated" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "feed state" do

      it "should have a method `feed`" do
        @user.should respond_to(:feed)
      end

      it "should include user's micro-messages" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end

      it "should not include other user's micro-messages" do
        mp3 = FactoryGirl.create(:micropost,
                                 :user => FactoryGirl.create(:user, :email => FactoryGirl.generate(:email)))
        @user.feed.include?(mp3).should be_false
      end
    end
  end
end
