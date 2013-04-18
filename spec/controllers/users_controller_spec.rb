require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index" do

    describe "for non logged users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /login/i
      end
    end

    describe "for logged users" do

      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        second = FactoryGirl.create(:user, :email => "another@example.com")
        third = FactoryGirl.create(:user, :email => "another@example.net")
        @users = [@user, second, third]
        30.times do
          @users << FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
        end
      end

      it "should success" do
        get :index
        response.should be_success
      end

      it "should have the good title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have one element for each users" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "Next")
      end
    end
  end

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

    it "should display users's micro-messages" do
      mp1 = FactoryGirl.create(:micropost, :user => @user, :content => "Foo bar")
      mp2 = FactoryGirl.create(:micropost, :user => @user, :content => "Baz quux")
      get :show, :id => @user
      response.should have_selector("span.content", :content => mp1.content )
      response.should have_selector("span.content", :content => mp2.content )
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

    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
    end

    it "should have an email field" do
      get :new
      response.should have_selector("input[name='user[email]'][type='text']")
    end

    it "should have a password field" do
      get :new
      response.should have_selector("input[name='user[password]'][type='password']")
    end

    it "should have a confirmation password field" do
      get :new
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
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

      it "should identify the user" do
        post :create, :user => @attr
        controller.should be_signed_in
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

  describe "GET 'edit'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    it "should success" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the good title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Profile edition")
    end

    it "should have a link to change Gravatar image" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href    => gravatar_url,
                                         :content => "Change")
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    describe "Fail" do

      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should return to edition page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the good title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Profile edition")
      end
    end

    describe "Success" do

      before(:each) do
        @attr = { :email => "user@example.org", :name => "New Name", :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should modify user's settings" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to user'show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should display a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /Updated/
      end
    end
  end

  describe "authenticate for edit/update pages" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "for a non-loged user" do

      it "should block access to 'edit' action" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should block access to 'update' action" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for a loged user" do

      before(:each) do
        wrong_user = FactoryGirl.create(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should match user to edit" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should match user to update" do
        get :edit, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "for non loged user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "for default user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "for administartor" do

      before(:each) do
        admin = FactoryGirl.create(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
      end

      it "should destroy user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to users page" do
        delete :destroy, :id => @user
        response.should redirect_to(user_path)
      end
    end
  end
end
