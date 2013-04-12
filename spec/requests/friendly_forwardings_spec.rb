require 'spec_helper'

describe "FriendlyForwardings" do

  it "should redirect to wanted page after identification" do
    user = FactoryGirl.create(:user)
    visit edit_user_path(user)
    # test auto fallows redirection after identification
    fill_in :email,     :with => user.email
    fill_in :password,  :with => user.password
    click_button
    # test fallows again redirection, that time to user/edit
    response.should render_template('users/edit')
  end
end
