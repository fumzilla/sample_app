require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'show'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it "should success" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the good user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
  end

  describe "GET 'new'" do
      
    it "returns http success" do
      get 'new'
      response.should be_success
    end

    it "should have the good title" do
      get 'new'
      response.should have_selector('title', :content => "Register")
    end
  end
end
