require 'spec_helper'

describe UsersController do

  render_views

  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should be successful" do
      get :show , :id => @user.id
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user.id
      # I did not understand this assigns thing
      assigns(:user).should == @user
    end

    it "should find the right title" do
      get :show, :id => @user.id
      response.should have_selector('title', :content => @user.name)
    end 

    it "should find the users name" do
      get :show, :id => @user.id
      response.should have_selector('h1', :content => @user.name)
    end
    
    it "should have a profile image" do
      get :show, :id => @user.id
      response.should have_selector('h1>img' , :class => "gravatar" )
    end
    
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign Up")
    end
  end
  
  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign Up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
      
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end 
      
      it "should have a welcome message" do
        post :create, :user => @attr
        # =~ is a reg exp
        flash[:success].should =~ /Welcome to the sample app/i
      end
      
      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
         
    end
    

  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector('title', :content => "Edit User")
    end
    
    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
                                         :content => "change")
    end
    
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do 
      
      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end
      
      it "should re-render the edit page" do
        put :update , :id => @user , :user => @attr
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update , :id => @user , :user => @attr
        response.should have_selector('title', :content => "Edit User")
      end

    end
    
    describe "success" do
      
      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end
      
      it "should change the users attributes" do
         put :update , :id => @user , :user => @attr
         # get the user from the controller and put in a local var
         user = assigns[:user]
         @user.reload
         @user.name.should == user.name
         @user.email.should == user.email
         @user.encrypted_password.should == user.encrypted_password
      end
      
      it "should have a success flash message" do
        put :update , :id => @user , :user => @attr
        # =~ is a reg exp
        flash[:success].should =~ /updated/
      end
    
    end
    
  end
  
  describe "authentication of edit/update actions" do

    before(:each) do
      @user = Factory(:user)
    end
  
    it "should deny acccess to 'edit'" do
       get :edit, :id => @user
       response.should redirect_to(signin_path)
       flash[:notice].should =~ /sign in/i
    end
    
    it "should deny acccess to 'edit'" do
       put :update, :id => @user, :user => {}
       response.should redirect_to(signin_path)
    end

  end
  
end
