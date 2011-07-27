class RelationshipsController < ApplicationController

  before_filter :authenticate
  
  def create
    # this gets the parameter followed_id from the request, which looks like
    # "relationship"=>{"followed_id"=>"94"}
    # check out _follow.html.erb - this seems a bit complicated. why not just send
    # followed_id =>"94"
    @user = User.find(params[:relationship][:followed_id])
    # now make the current user follow the followed user
    current_user.follow!(@user)
    
    respond_to do |format|
      format.html { redirect_to @user }
      # this will look for a create.js.erb by default (in the controller's (relationship) view folder)
      format.js 
    end
    
    
  end
  
  def destroy
    # the id we get is the relationship itself; we know both users
    # on the client side, so it sends back the relationship between them
    # so Relationship.find knows the current user; send it the id of the 
    # user to unfollow, add .followed, and get the user object to unfollow
    @user = Relationship.find(params[:id]).followed
    
    current_user.unfollow!(@user)
    
    respond_to do |format|
      format.html { redirect_to @user }
      # this will look for a destroy.js.erb by default (in the controller's (relationship) view folder)
       format.js 
    end
    
  end

end