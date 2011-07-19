class UsersController < ApplicationController
  
  before_filter :authenticate , :only => [:index,:edit,:update, :destroy]
  before_filter :correct_user , :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  
  def index
    @title = "All users"
    @users = User.all.paginate(:page => params[:page])
  end
  
  def show
    @user = User.find(params[:id])
#   apparently there are problems with will_paginate and rails 3
#   I can check this out later
#    @microposts = @user.microposts.paginate(:page => params[:page])
    @microposts = @user.microposts
    @title = @user.name
  end
  
  def new
    @user = User.new
    @title = "Sign Up"
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      redirect_to @user, :flash => { :success => "Welcome to the Sample App!"}
    else
      @title = "Sign Up"
      render 'new'
    end
  end
  
  def edit
    @title = "Edit User"
  end
  
  def update
    
    if @user.update_attributes(params[:user])
      redirect_to @user , :flash => { :success => "Profile updated"}
    else
      @title = "Edit User"
      render 'edit'
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "destroyed"
    redirect_to users_path
  end

private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
  
  def admin_user
    @user = User.find(params[:id])
    redirect_to(root_path) if !current_user.admin? || current_user?(@user)
  end


end
