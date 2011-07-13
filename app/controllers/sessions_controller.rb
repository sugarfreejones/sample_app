class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])
    if user.nil?
        flash.now[:error] = "Invalid email/password combination"
        render 'new'
    else
        # handle successful signin here
    end
    
  end
  
  def destroy
  
  end

end
