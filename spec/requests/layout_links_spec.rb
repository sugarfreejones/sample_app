require 'spec_helper'

describe "LayoutLinks" do
  
  it "should have a Home Page at '/'  "  do
    get '/'
    response.should have_selector('title', :content => "Home")
  end
  
  it "should have a Contact Page at '/contacts'  "  do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end
  
  it "should have a About Page at '/about'  "  do
    get '/about'
    response.should have_selector('title', :content => "About")
  end
  
  it "should have a Help Page at '/help'  "  do
    get '/help'
    response.should have_selector('title', :content => "Help")
  end
 
  it "should have a signup page at '/signup'  "  do
    get '/signup'
    response.should have_selector('title', :content => "Sign Up")
  end

  it "should have a signin page at '/signin'  "  do
    get '/signin'
    response.should have_selector('title', :content => "Sign in")
  end

  it "should have the right links on the layout" do
      visit root_path
      click_link "About"
      response.should have_selector('title', :content => "About")
      click_link "Help"
      response.should have_selector('title', :content => "Help")
      click_link "Contact"
      response.should have_selector('title', :content => "Contact")
      click_link "Home"
      response.should have_selector('title', :content => "Home")
      click_link "Sign up now!"
      response.should have_selector('title', :content => "Sign Up")
    end
    
    describe "when not signed in" do
      it "should have a sign in link" do
        visit root_path
        response.should have_selector("a",  :href => signin_path,
                                            :content => "Sign In")   
      end
    end
    
    describe "when signed in" do
      before(:each) do
        @user = Factory(:user)
        visit signin_path
        # for some reason can't use test_sign_in in spec_helper
        fill_in :email , :with => @user.email
        fill_in :password, :with => @user.password
        click_button
      end
      
      it "should have a sign out link" do
        visit root_path
        response.should have_selector("a",  :href => signout_path,
                                             :content => "Sign Out")    
      end
      it "should have a profile link" do
        visit root_path
        response.should have_selector("a",  :href => user_path(@user),
                                             :content => "Profile")    
      end
    end
    
    describe "sign in/out" do

      describe "failure" do
        it "should not sign a user in" do
          visit signin_path
          fill_in :email,    :with => ""
          fill_in :password, :with => ""
          click_button
          response.should have_selector("div.flash.error", :content => "Invalid")
        end
      end

      describe "success" do
        it "should sign a user in and out" do
          user = Factory(:user)
          visit signin_path
          fill_in :email,    :with => user.email
          fill_in :password, :with => user.password
          click_button
          controller.should be_signed_in
          click_link "Sign out"
          controller.should_not be_signed_in
        end
      end
    end
end
