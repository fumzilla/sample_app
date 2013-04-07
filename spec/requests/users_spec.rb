require 'spec_helper'

describe "Users" do

  describe "registering" do

    describe "failed" do

      it "shouldn't create a new user" do
        lambda do
          visit signup_path
          fill_in "Name",                     :with => ""
          fill_in "Email",                    :with => ""
          fill_in "Password",                 :with => ""
          fill_in "Password confirmation",    :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end
    end

    describe "successed" do

      it "should create a new user" do
        lambda do
          visit signup_path
          fill_in "Name",                     :with => "Example User"
          fill_in "Email",                    :with => "user@example.org"
          fill_in "Password",                 :with => "foobar"
          fill_in "Password confirmation",    :with => "foobar"
          click_button
          response.should have_selector("div.flash.success", :content => "Welcome")
          response.should render_template('users/show')
        end.should change(User, :count ).by(1)
      end
    end
  end

  describe "login/logout" do

    describe "fail" do
      it "shouldn't identify user" do
        visit signin_path
        fill_in "Email", :with => ""
        fill_in "Password", :with => ""
        click_button
        response.should have_selector("div.flash.error", :content => "Invalid")
      end
    end

    describe "success" do

      it "should identify an user than disconnect it" do
        user = FactoryGirl.create(:user)
        visit signin_path
        fill_in "Email", :with => user.email
        fill_in "Password", :with => user.password
        click_button
        controller.should be_signed_in
        click_link "Logout"
        controller.should_not be_signed_in
      end
    end
  end
end
