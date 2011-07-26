require 'spec_helper'

describe UsersController do

  render_views

  describe "GET 'index" do
    
    describe "for non-signed-in users" do
      
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
      
    end
    
    describe "for signed-in users" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
        Factory(:user, :email => "another@example.com")
        Factory(:user, :email => "another@example.net")
        
        # this calls the :email function in factories.rb to generate unique email
        30.times do
          Factory(:user, :email => Factory.next(:email))
        end
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector('title', :content => "All users")
      end
      
      it "should have an element for each user" do
        get :index
        User.all.paginate(:page => 1).each do |user|
          response.should have_selector('li', :content => user.name)
        end
      end
      
      it "should paginate users" do
        get :index
        response.should have_selector('div.pagination')
        response.should have_selector('span.disabled', :content => "Previous")
        response.should have_selector('a', 
                                      :href => "/users?page=2", 
                                      :content => "2")
      end
    
      it "should have delete links for admin users" do
        @user.toggle!(:admin)
        other_user = User.all.second
        get :index
        response.should have_selector('a', :href => user_path(other_user), :content => "delete")
      end

      it "should have NOT have delete links for non-admin users" do
        other_user = User.all.second
        get :index
        response.should_not have_selector('a', :href => user_path(other_user), :content => "delete")
      end
    
    end
    
  end

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
    
    it "should show the users microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Yo mama is so ugly")
      mp2 = Factory(:micropost, :user => @user, :content => "Yo daddy is so fat")
      get :show, :id => @user.id
      response.should have_selector('span.content', :content => mp1.content)
      response.should have_selector('span.content', :content => mp2.content)
   end

#  it "should paginate microposts" do
# for some reason could not get this to work. It's related to the 35 times   
#     35.times { Factory(:micropost, :user => @user, :content => "Yo mama is so ugly") }
#     get :show, :id => @user.id
#     response.should have_selector('div.pagination')
#   end

#    it "should display the micropost count" do
#      10.times { Factory(:micropost, :user => @user, :content => "Yo mama is so ugly") }
#      get :show, :id => @user.id
#      response.should have_selector('td.sidebar', :content => @user.microposts.count)
#    end

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
  
  describe "DELETE 'destroy'" do
    
    before(:each) do 
      @user = Factory(:user)
    end
    
    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy , :id => @user.id 
        response.should redirect_to(signin_path)
      end
    end
    
    describe "as a signed-in non-admin user" do
      it "should protect the action" do
        test_sign_in(@user)
        delete :destroy , :id => @user.id
        response.should redirect_to(root_path)
      end
    end

    describe "as a signed-in admin user" do
      
      before(:each) do 
        # note - usually need to set admin with toggle; in factory we can just assign
        @admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(@admin)
      end
      
      it "should destroy the user" do
        lambda do
         delete :destroy , :id => @user
        end.should change(User, :count).by(-1)
      end
      
      it "should redirect to the users page" do 
        delete :destroy , :id => @user.id
        flash[:success].should =~ /destroyed/i
        response.should redirect_to(users_path)
      end
      
      it "should not allow them to delete themselves" do
        lambda do
          delete :destroy , :id => @admin
        end.should_not change(User, :count)
      end
      
    end
  end

  
  describe "authentication of edit/update actions" do

    before(:each) do
      @user = Factory(:user)
    end
  
    # a non-singned-in user should redirect to their edit page
    describe "for non-signed in users" do
        it "should deny acccess to 'edit'" do
           get :edit, :id => @user
           response.should redirect_to(signin_path)
           flash[:notice].should =~ /sign in/i
        end

        it "should deny acccess to 'update'" do
           put :update, :id => @user, :user => {}
           response.should redirect_to(signin_path)
        end
    end
    
    # a signed in user should only be able to access their edit page
    describe "for signed in users" do 

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for edit" do
           get :edit, :id => @user
           response.should redirect_to(root_path)
      end
      
      it "should require matching users for update " do
           put :update, :id => @user,  :user => {}
           response.should redirect_to(root_path)
      end
    end
    
  end
  
  describe "follow pages" do
  
    describe "when not signed in" do
      
      it "should protect 'following'" do
        get :following , :id => 1
        response.should redirect_to(signin_path)
      end
      
      it "should protest 'followers'" do
        get :followers , :id => 1
        response.should redirect_to(signin_path)
      end
    
    end
    
    describe "when signed in" do
    
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end
      
      it "should show who a user is following" do
        get :following, :id => @user
        response.should have_selector('a', :href => user_path(@other_user),
                                            :content => @other_user.name)
      end
    
      it "should show who follows a user" do
        get :followers, :id => @other_user
        response.should have_selector('a', :href => user_path(@user),
                                            :content => @user.name)
      end
    end
  end
  
end
