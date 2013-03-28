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
        response.should have_selector('title', :content => "register")
    end
end
