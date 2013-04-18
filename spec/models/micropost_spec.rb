require 'spec_helper'

describe Micropost do
  
  before(:each) do
    @user = FactoryGirl.create(:user)
    @attr = { :content => "Blabla, Some post content" }
  end

  it "should create micro-message instance with good attribute" do
    @user.microposts.create!(@attr)
  end

  describe "associate with the user" do

    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end

    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the good user associated" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end

  describe "validations" do

    it "resquires a user id" do
      Micropost.new(@attr).should_not be_valid
    end

    it "requires a non void content" do
      @user.microposts.build(:content => " ").should_not be_valid
    end

    it "should reject a too long content" do
      @user.microposts.build(:content => "a" *141).should_not be_valid
    end
  end
end

