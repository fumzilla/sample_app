require 'spec_helper'

describe MicropostsController do
  render_views

  describe "access control" do

    it "should deny access for 'create'" do  
      post :create
      response.should redirect_to(signin_path)
    end

    it "should deny access for 'destroy'" do
      post :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(FactoryGirl.create(:user))
    end

    describe "fail" do

      before(:each) do
        @attr = { :content => "" }
      end

      it "should not create micro-message" do
        lambda do
          post :create, :micropost => @attr
        end.should_not change(Micropost, :count)
      end

      it "should render home page" do
        post :create, :micropost => @attr
        response.should render_template('pages/home')
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :content => "Lorem ipsum" }
      end

      it "should create a micro-message" do
        lambda do
          post :create, :micropost => @attr
        end.should change(Micropost, :count).by(1)
      end

      it "should redirect to Home page" do
        post :create, :micropost => @attr
        response.should redirect_to(root_path)
      end

      it "should flash a message" do
        post :create, :micropost => @attr
        flash[:success].should =~ /Micropost created/i
      end
    end
  end

  describe "DELETE 'destroy'" do

    describe "for user which is not micro-message's owner" do
      
      before(:each) do
        @user = FactoryGirl.create(:user)
        wrong_user = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
        test_sign_in(wrong_user)
        @micropost = FactoryGirl.create(:micropost, :user => @user)
      end

      it "should not delete micro-message" do
        delete :destroy, :id => @micropost
        response.should redirect_to(root_path)
      end
    end

    describe "for user which is micro-message's owner" do

      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        @micropost = FactoryGirl.create(:micropost, :user => @user)
      end

      it "should delete micro-message" do
        lambda do
          delete :destroy, :id => @micropost
        end.should change(Micropost, :count).by(-1)
      end
    end
  end
end
