require 'spec_helper'

describe "LayoutLinks" do

    it "should find a Home page at '/'" do
        get '/'
        response.should have_selector('title', :content => "Home")
    end

    it "should find a Contact page at '/contact'" do
        get '/contact'
        response.should have_selector('title', :content => "Contact")
    end

    it "should find a About page at '/about'" do
        get '/about'
        response.should have_selector('title', :content => "About")
    end

    it "should find a Help page at '/help'" do
        get '/help'
        response.should have_selector('title', :content => "Help")
    end

    it "should find a Register page at '/signup'" do
        get '/signup'
        response.should have_selector('title', :content => "Register")
    end

    it "should have the good link on the layout" do
        visit root_path
        click_link "About"
        response.should have_selector('title', :content => "About")
        click_link "Help"
        response.should have_selector('title', :content => "Help")
        click_link "Contact"
        response.should have_selector('title', :content => "Contact")
        click_link "Home"
        response.should have_selector('title', :content => "Home")
        click_link "Sign Up"
        response.should have_selector('title', :content => "Register")
    end

    describe "when not logged in" do

      it "should have a connection link" do
        visit root_path
        response.should have_selector("a", :href    => signin_path,
                                           :content => "Login")
      end
    end

    describe "when logged in" do
        
      before(:each) do
        @user = FactoryGirl.create(:user)
        visit signin_path
        fill_in :email, :with => @user.email
        fill_in "Password", :with => @user.password
        click_button
       end   

      it "should have a disconnection link" do
        visit root_path
        response.should have_selector("a", :href => signout_path,
                                           :content => "Logout")
      end

      it "should have a profile link" do
        visit root_path
        response.should have_selector("a", :href    => user_path(@user),
                                           :content => "Profile")
      end
    end
end
