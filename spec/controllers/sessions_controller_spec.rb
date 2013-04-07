require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do

    it "should success" do
      get :new
      response.should be_success
    end

    it "should have the good title" do
      get :new
      response.should have_selector("title", :content => "Login")
    end
  end

  describe "POST 'create'" do

    describe "invalid signin" do

      before(:each) do
        @attr = { :email => "email@example.com", :password => "invalid" }
      end

      it "should render again the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
       
      it "should have the good title" do
        post :create, :session => @attr
        response.should have_selector("title", :content => "Login")
      end

      it "should have a flash.now message" do
        post :create, :session => @attr
        flash.now[:error].should =~ /invalid/i
      end
    end

    describe "valid signin" do

      before(:each) do
        @user = FactoryGirl.create(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end
      
      it "should identify the user" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_signed_in
      end

      it "should redirect user to user's page" do
        post :create, :session => @attr
        response.should redirect_to(user_path(@user))
      end
    end
  end

  describe "DELETE 'destroy'" do

    it "should disconnect an user" do
      test_sign_in(FactoryGirl.build(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end
end
