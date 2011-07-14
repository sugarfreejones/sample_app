module SessionsHelper
  
  def sign_in(user)
    # use salt to create a encrypted cookie that keeps user signed in
    # apparently, this used to be very hard to do.
    # encrypts the user id too
    cookies.permanent.signed[:remember_token] = [user.id , user.salt]
    
    current_user = user
    
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    # the ||= operator avoids calling user_from_remember_token if there is a current user 
    @current_user ||= user_from_remember_token
  end
  
  def signed_in?
    !current_user.nil?
  end
  
  private 
  
    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
  
end
