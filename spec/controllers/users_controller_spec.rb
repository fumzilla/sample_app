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
      get :new
      response.should be_success
    end

    it "should have the good title" do
      get :new
      response.should have_selector('title', :content => "Register")
    end
  end

  describe "POST 'create'" do

    describe "fail" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => ""}
      end

      it "shouldn't create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the good title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Register")
      end

      it "should render the page 'new'" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com", :password => "foobar", :password_confirmation => "foobar"}
      end

      it "should create an user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count ).by(1)
      end

      it "should redirect to user's profile page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should display a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /Welcome to the Sample Application/i
      end
    end
  end
end
